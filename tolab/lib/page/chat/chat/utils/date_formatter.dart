import 'package:intl/intl.dart';

class DateFormatter {
  // تنسيق الوقت بشكل مختصر (مثلاً: 2:45 م)
  static String formatTime(DateTime dateTime) {
    return DateFormat.jm('ar_EG').format(dateTime);
  }

  // تنسيق التاريخ بشكل مثل: 29 يوليو، 2025
  static String formatFullDate(DateTime dateTime) {
    return DateFormat.yMMMMd('ar_EG').format(dateTime);
  }

  // عرض الوقت أو التاريخ بناءً على الفرق الزمني
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return formatFullDate(dateTime); // fallback
    }
  }

  // معرفة إذا كانت الرسالة اليوم
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
  }

  // معرفة إذا كانت الرسالة أمس
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.year == dateTime.year &&
        yesterday.month == dateTime.month &&
        yesterday.day == dateTime.day;
  }
}
