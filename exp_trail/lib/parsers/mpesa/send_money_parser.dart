import '/core/constants/mpesa_patterns.dart';
import '/core/constants/record_titles.dart';
import '/core/enums/party_type.dart';
import '/library/classifiers/message_classifier.dart';
import '/models/financial_records.dart';
import '/models/parse_result.dart';
import '/models/party.dart';
import '/models/raw_message.dart';
import '/parsers/common_field_parser.dart';
import '../parser.dart';
import '/core/mappers/financial_record_type_mapper.dart';

class SendMoneyParser implements Parser {
  @override
  ParseResult parse(RawMessage message, ClassificationResult classification) {
    try {
      // Parse fields common to all M-PESA transactions
      final common = CommonFieldsParser.parse(message.body);

      // Extract recipient name and phone
      final recipientMatch = MpesaPatterns.sendMoneyRecipient.firstMatch(
        message.body,
      );

      if (recipientMatch == null) {
        return const ParseResult.failure(
          'Unable to extract recipient information.',
        );
      }

      final party = Party(
        name: recipientMatch.group(1)!.trim(),
        phone: recipientMatch.group(2)!,
        type: PartyType.person,
      );

      final record = FinancialRecord(
        reference: common.reference,
        transactionDate: common.transactionDate,
        amount: common.amount,
        balance: common.balance,
        transactionCost: common.transactionCost,
        type: FinancialRecordTypeMapper.fromSubtype(classification.subtype),
        subtype: classification.subtype,
        status: classification.status,
        title: RecordTitles.sendMoney,
        party: party,
        rawMessage: message.body,
      );

      return ParseResult.success(record);
    } catch (e) {
      return ParseResult.failure('Failed to parse Send Money transaction: $e');
    }
  }
}
