import 'dart:ui';

class CurrencyFormatter {
  static String format(double amount) {
    return 'Rs. ${amount.toStringAsFixed(2)}';
  }

  static String formatWithSign(double amount, {bool isIncome = true}) {
    final sign = isIncome ? '+' : '-';
    return '$sign Rs. ${amount.toStringAsFixed(2)}';
  }

  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return 'Rs. ${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return 'Rs. ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return 'Rs. ${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return 'Rs. ${amount.toStringAsFixed(2)}';
    }
  }

  static String formatWithoutSymbol(double amount) {
    return amount.toStringAsFixed(2);
  }

  static Color getAmountColor(double amount, {bool isIncome = true}) {
    return isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
  }
}