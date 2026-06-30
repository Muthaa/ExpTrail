import 'package:another_telephony/telephony.dart';
import '../models/raw_message.dart';
import 'transaction_source.dart';

class SmsTransactionSource implements TransactionSource {
  final Telephony _telephony = Telephony.instance;

  @override
  Future<List<RawMessage>> load() async {
    final messages = await _telephony.getInboxSms(
      columns: [
        SmsColumn.ID,
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
      ],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    return messages.map((sms) {
      return RawMessage(
        id: sms.id?.toString() ?? '',
        sender: sms.address ?? '',
        body: sms.body ?? '',
        receivedAt: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
      );
    }).toList();
  }
}
