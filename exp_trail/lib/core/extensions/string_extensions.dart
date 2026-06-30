extension StringExtensions on String {
  double toMoney() {
    return double.parse(replaceAll(',', ''));
  }
}
