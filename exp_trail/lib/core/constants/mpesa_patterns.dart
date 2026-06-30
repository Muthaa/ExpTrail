class MpesaPatterns {
  MpesaPatterns._();

  /// Transaction code
  static final reference = RegExp(r'^([A-Z0-9]{10})');

  /// Amount
  static final amount = RegExp(r'Ksh\s?([\d,]+\.\d{2})');

  /// Date and time
  static final date = RegExp(
    r'on (\d{1,2}/\d{1,2}/\d{2}) at (\d{1,2}:\d{2}\s?(?:AM|PM))',
    caseSensitive: false,
  );

  /// Balance
  static final balance = RegExp(
    r'New M-PESA balance is Ksh([\d,]+\.\d{2})',
    caseSensitive: false,
  );

  /// Transaction Cost
  static final transactionCost = RegExp(
    r'Transaction cost,?\s*Ksh\.?([\d,]+\.\d{2})',
    caseSensitive: false,
  );

  /// Phone Number
  static final phone = RegExp(r'(07\d{8}|01\d{8})');

  /// Account Number
  static final account = RegExp(
    r'for account\s+([A-Za-z0-9:-]+)',
    caseSensitive: false,
  );

  /// Recipient after "sent to"
  static final recipient = RegExp(
    r'sent to\s+(.*?)\s+(?:07\d{8}|01\d{8})',
    caseSensitive: false,
  );

  /// Merchant after "paid to"
  static final merchant = RegExp(r'paid to\s+(.*?)\s+on', caseSensitive: false);

  static final sendMoneyRecipient = RegExp(
    r'sent to\s+(.*?)\s+(07\d{8}|01\d{8})',
    caseSensitive: false,
  );

  static final receiveMoneySender = RegExp(
    r'from\s+(.+?)\s+on\s',
    caseSensitive: false,
  );

  /// Ksh30.00 paid to SUPER METRO.
  static final buyGoodsMerchant = RegExp(
    r'paid\s+to\s+(.+?)\.',
    caseSensitive: false,
  );

  /// sent to KCB M-PESA for account 123456 on 01/01/2023 at 12:00 PM.
  static final payBill = RegExp(
    r'sent\s+to\s+(.+?)\s+for\s+account\s+(.+?)\s+on',
    caseSensitive: false,
  );
}
