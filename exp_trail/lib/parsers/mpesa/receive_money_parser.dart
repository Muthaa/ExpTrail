import '/core/constants/mpesa_patterns.dart';
import '/core/constants/record_titles.dart';
import '/core/enums/party_type.dart';
import '/library/classifiers/message_classifier.dart';
import '/models/parse_result.dart';
import '/models/party.dart';
import '/models/raw_message.dart';
import '/parsers/common_field_parser.dart';
import '../parser.dart';
import '/builders/financial_record_builder.dart';

class ReceiveMoneyParser implements Parser {
  @override
  ParseResult parse(RawMessage message, ClassificationResult classification) {
    try {
      final common = CommonFieldsParser.parse(message.body);

      final senderMatch = MpesaPatterns.receiveMoneySender.firstMatch(
        message.body,
      );

      if (senderMatch == null) {
        return const ParseResult.failure('Unable to extract sender.');
      }

      final sender = senderMatch.group(1)!.trim();

      final party = Party(name: sender, type: PartyType.unknown);

      final record = FinancialRecordBuilder.build(
        common: common,
        classification: classification,
        title: RecordTitles.receiveMoney,
        rawMessage: message.body,
        party: party,
      );

      return ParseResult.success(record);
    } catch (e) {
      return ParseResult.failure(
        'Failed to parse Receive Money transaction: $e',
      );
    }
  }
}
