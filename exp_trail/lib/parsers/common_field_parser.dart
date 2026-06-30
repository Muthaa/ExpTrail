import '/core/constants/mpesa_patterns.dart';
import '/core/extensions/string_extensions.dart';
import '/models/common_fields.dart';
import '/parsers/parser_utils.dart';

class CommonFieldsParser {
  CommonFieldsParser._();

  static CommonFields parse(String text) {
    final reference = ParserUtils.firstMatch(MpesaPatterns.reference, text, 1);

    if (reference == null) {
      throw Exception('Reference not found');
    }

    final amountText = ParserUtils.firstMatch(MpesaPatterns.amount, text, 1);

    if (amountText == null) {
      throw Exception('Amount not found');
    }

    final balanceText = ParserUtils.firstMatch(MpesaPatterns.balance, text, 1);

    if (balanceText == null) {
      throw Exception('Balance not found');
    }

    final costText = ParserUtils.firstMatch(
      MpesaPatterns.transactionCost,
      text,
      1,
    );

    final dateMatch = MpesaPatterns.date.firstMatch(text);

    if (dateMatch == null) {
      throw Exception('Date not found');
    }

    final date = ParserUtils.parseMpesaDate(
      dateMatch.group(1)!,
      dateMatch.group(2)!,
    );

    return CommonFields(
      reference: reference,
      amount: amountText.toMoney(),
      balance: balanceText.toMoney(),
      transactionCost: costText?.toMoney() ?? 0,
      transactionDate: date,
    );
  }
}
