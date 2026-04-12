import 'package:intl/intl.dart';

String maskNationalId(String value) {
  if (value.length <= 4) {
    return value;
  }
  final visibleDigits = value.substring(value.length - 4);
  return '${'*' * (value.length - 4)}$visibleDigits';
}

String formatNow(String pattern) => DateFormat(pattern).format(DateTime.now());
