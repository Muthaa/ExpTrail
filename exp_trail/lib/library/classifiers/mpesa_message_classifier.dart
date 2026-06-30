import '/core/constants/mpesa_keywords.dart';
import '/core/enums/message_type.dart';
import '/core/enums/record_subtype.dart';
import '/core/enums/transaction_status.dart';
import 'message_classifier.dart';
import '/core/extensions/string_extensions.dart';

class MpesaMessageClassifier implements MessageClassifier {
  @override
  ClassificationResult classify(String message) {
    final text = message.toLowerCase().trim();

    // --------------------------------------------------
    // Determine transaction status
    // --------------------------------------------------

    TransactionStatus status = TransactionStatus.unknown;

    if (text.contains(MpesaKeywords.failed)) {
      status = TransactionStatus.failed;
    } else if (text.contains(MpesaKeywords.pending)) {
      status = TransactionStatus.pending;
    } else if (text.contains(MpesaKeywords.confirmed)) {
      status = TransactionStatus.successful;
    }

    // --------------------------------------------------
    // Ignore non-transaction messages
    // --------------------------------------------------

    if (status == TransactionStatus.unknown) {
      return _result(MessageType.notification, RecordSubtype.unknown, status);
    }

    // --------------------------------------------------
    // PayBill
    // Must be checked before Send Money
    // --------------------------------------------------
    if (text.containsAll([MpesaKeywords.sentTo, MpesaKeywords.forAccount])) {
      return _result(MessageType.transaction, RecordSubtype.payBill, status);
    }

    // --------------------------------------------------
    // Buy Goods
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.paidTo)) {
      return _result(MessageType.transaction, RecordSubtype.buyGoods, status);
    }

    // --------------------------------------------------
    // Send Money
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.sentTo)) {
      return _result(MessageType.transaction, RecordSubtype.sendMoney, status);
    }

    // --------------------------------------------------
    // Receive Money
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.received)) {
      return _result(
        MessageType.transaction,
        RecordSubtype.receiveMoney,
        status,
      );
    }

    // --------------------------------------------------
    // Agent Deposit
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.give)) {
      return _result(MessageType.transaction, RecordSubtype.deposit, status);
    }

    // --------------------------------------------------
    // Agent Withdrawal
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.amWithdraw) ||
        text.contains(MpesaKeywords.withdraw)) {
      return _result(MessageType.transaction, RecordSubtype.withdrawal, status);
    }

    // --------------------------------------------------
    // M-Shwari Deposit
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.transferredToMShwari)) {
      return _result(
        MessageType.transaction,
        RecordSubtype.mshwariDeposit,
        status,
      );
    }

    // --------------------------------------------------
    // M-Shwari Withdrawal
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.transferredFromMShwari)) {
      return _result(
        MessageType.transaction,
        RecordSubtype.mshwariWithdrawal,
        status,
      );
    }

    // --------------------------------------------------
    // KCB Mpesa Deposit
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.transferredToKcb)) {
      return _result(MessageType.transaction, RecordSubtype.kcbDeposit, status);
    }

    // --------------------------------------------------
    // KCB Mpesa Withdrawal
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.transferredFromKcb)) {
      return _result(
        MessageType.transaction,
        RecordSubtype.kcbWithdrawal,
        status,
      );
    }

    // --------------------------------------------------
    // Fuliza Loan
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.fulizaLoan)) {
      return _result(MessageType.transaction, RecordSubtype.fulizaLoan, status);
    }

    // --------------------------------------------------
    // Fuliza Repayment
    // --------------------------------------------------

    if (text.contains(MpesaKeywords.fulizaRepayment)) {
      return _result(
        MessageType.transaction,
        RecordSubtype.fulizaRepayment,
        status,
      );
    }

    // --------------------------------------------------
    // Unknown Transaction
    // --------------------------------------------------

    return _result(MessageType.transaction, RecordSubtype.unknown, status);
  }

  ClassificationResult _result(
    MessageType messageType,
    RecordSubtype subtype,
    TransactionStatus status,
  ) {
    return ClassificationResult(
      messageType: messageType,
      subtype: subtype,
      status: status,
    );
  }
}
