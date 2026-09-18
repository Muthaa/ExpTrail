import 'package:flutter/foundation.dart';

import '../library/classifiers/message_classifier.dart';
import '../models/raw_message.dart';
import '../parsers/parser_factory.dart';
import '../repositories/financial_records_repository.dart';
import '../repositories/raw_messages_repository.dart';
import '../sources/transaction_source.dart';

import '../models/financial_records.dart';

class TransactionImportService {
  final MessageClassifier classifier;
  final FinancialRecordsRepository financialRecordsRepository;
  final RawMessagesRepository rawMessagesRepository;

  TransactionImportService({
    required this.classifier,
    required this.financialRecordsRepository,
    required this.rawMessagesRepository,
  });

  Future<ImportResult> importMessages(List<RawMessage> messages) async {
    var skipped = 0;
    var failed = 0;
    var imported = 0;

    if (messages.isEmpty) {
      return const ImportResult(imported: 0, skipped: 0, failed: 0);
    }

    const batchSize = 500;

    final existingSourceIds = await rawMessagesRepository.getExistingSourceIds(
      messages.map((message) => message.id).toList(),
    );

    final existingSourceIdSet = existingSourceIds.toSet();

    final newMessages = messages
        .where((message) => !existingSourceIdSet.contains(message.id))
        .toList();

    await rawMessagesRepository.saveAll(newMessages);

    for (var start = 0; start < messages.length; start += batchSize) {
      final end = (start + batchSize < messages.length)
          ? start + batchSize
          : messages.length;

      final batchMessages = messages.sublist(start, end);

      final parsedRecords = <FinancialRecord>[];

      for (final message in batchMessages) {
        final classification = classifier.classify(message.body);

        if (classification.subtype.name == 'unknown') {
          skipped++;
          continue;
        }

        final parser = ParserFactory.getParser(classification.subtype);

        if (parser == null) {
          skipped++;
          continue;
        }

        final result = parser.parse(message, classification);

        if (!result.success || result.record == null) {
          failed++;
          continue;
        }

        parsedRecords.add(result.record!);
      }

      if (parsedRecords.isEmpty) {
        continue;
      }

      final references = parsedRecords
          .map((record) => record.reference)
          .toList();

      final existingReferences = await financialRecordsRepository
          .getExistingReferences(references);

      final existingReferenceSet = existingReferences.toSet();

      final newRecords = <FinancialRecord>[];
      final seenReferences = <String>{};

      for (final record in parsedRecords) {
        if (existingReferenceSet.contains(record.reference)) {
          skipped++;
          continue;
        }

        if (!seenReferences.add(record.reference)) {
          skipped++;
          continue;
        }

        newRecords.add(record);
      }

      await financialRecordsRepository.saveAll(newRecords);

      imported += newRecords.length;
    }

    debugPrint(
      'IMPORT COMPLETE '
      '$imported imported, '
      '$skipped skipped, '
      '$failed failed',
    );

    return ImportResult(imported: imported, skipped: skipped, failed: failed);
  }

  Future<ImportResult> importFromSource(TransactionSource source) async {
    final messages = await source.load();

    return importMessages(messages);
  }
}

class ImportResult {
  final int imported;
  final int skipped;
  final int failed;

  const ImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
  });
}
