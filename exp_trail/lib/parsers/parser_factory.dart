import '/core/enums/record_subtype.dart';
import '/parsers/mpesa/send_money_parser.dart';
import '/parsers/parser.dart';
import '/parsers/mpesa/receive_money_parser.dart';
import '/parsers/mpesa/buy_goods_parser.dart';
import '/parsers/mpesa/paybill_parser.dart';

class ParserFactory {
  ParserFactory._();

  static Parser? getParser(RecordSubtype subtype) {
    switch (subtype) {
      case RecordSubtype.sendMoney:
        return SendMoneyParser();

      case RecordSubtype.receiveMoney:
        return ReceiveMoneyParser();

      case RecordSubtype.buyGoods:
        return BuyGoodsParser();

      case RecordSubtype.payBill:
        return PayBillParser();

      default:
        return null;
    }
  }
}
