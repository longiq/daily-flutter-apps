import 'package:intl/intl.dart';

/// Định dạng số tiền dùng chung toàn app (VNĐ, không thập phân).
class CurrencyUtils {
  CurrencyUtils._();

  static final _formatter = NumberFormat.decimalPattern('vi_VN');

  static String format(double value) => '${_formatter.format(value.round())}đ';

  static String formatSigned(double value, {required bool isIncome}) {
    final sign = isIncome ? '+' : '-';
    return '$sign${format(value.abs())}';
  }
}
