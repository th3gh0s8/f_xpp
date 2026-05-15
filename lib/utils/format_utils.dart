import 'package:intl/intl.dart';

class FormatUtils {
  static final NumberFormat _currencyFormat = NumberFormat("#,##0.00", "en_LK");
  static final NumberFormat _intCurrencyFormat = NumberFormat("#,##0", "en_LK");

  static String formatCurrency(double amount, {bool showDecimals = true}) {
    return 'LKR ${showDecimals ? _currencyFormat.format(amount) : _intCurrencyFormat.format(amount)}';
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }
}
