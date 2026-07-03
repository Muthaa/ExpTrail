import 'package:exp_trail/core/constants/record_titles.dart';
import 'package:exp_trail/core/enums/party_type.dart';
import 'package:exp_trail/core/enums/record_subtype.dart';
import 'package:exp_trail/library/classifiers/message_classifier.dart';
import 'package:exp_trail/models/parse_result.dart';
import 'package:exp_trail/models/party.dart';
import 'package:exp_trail/models/raw_message.dart';
import 'package:exp_trail/parsers/common_field_parser.dart';
import 'package:exp_trail/parsers/parser.dart';
import '/builders/financial_record_builder.dart';

class FulizaParser implements Parser {
  @override
  ParseResult parse(RawMessage message, ClassificationResult classification) {
    final common = CommonFieldsParser.parse(message.body);

    late String title;

    switch (classification.subtype) {
      case RecordSubtype.fulizaLoan:
        title = RecordTitles.fulizaLoan;
        break;

      case RecordSubtype.fulizaRepayment:
        title = RecordTitles.fulizaRepayment;
        break;

      default:
        return const ParseResult.failure('Unsupported Fuliza transaction.');
    }

    final party = const Party(name: 'Fuliza', type: PartyType.self);

    final record = FinancialRecordBuilder.build(
      common: common,
      classification: classification,
      title: title,
      rawMessage: message.body,
      party: party,
    );

    return ParseResult.success(record);
  }
}
