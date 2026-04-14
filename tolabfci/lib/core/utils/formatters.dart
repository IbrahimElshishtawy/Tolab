import 'package:intl/intl.dart';

String maskNationalId(String value) {
  if (value.length <= 4) {
    return value;
  }
  final visibleDigits = value.substring(value.length - 4);
  return '${'*' * (value.length - 4)}$visibleDigits';
}

String formatNow(String pattern, {String locale = 'ar'}) {
  return DateFormat(pattern, locale).format(DateTime.now());
}

String formatArabicDate(
  DateTime dateTime, {
  String pattern = 'd MMM',
}) {
  return DateFormat(pattern, 'ar').format(dateTime);
}

String formatArabicTime(DateTime dateTime) {
  return DateFormat('h:mm a', 'ar').format(dateTime);
}

String formatArabicSchedule(DateTime dateTime, {DateTime? reference}) {
  final now = reference ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final differenceInDays = target.difference(today).inDays;

  final prefix = switch (differenceInDays) {
    0 => 'اليوم',
    1 => 'غدًا',
    _ => DateFormat('EEE d MMM', 'ar').format(dateTime),
  };

  return '$prefix - ${formatArabicTime(dateTime)}';
}

String formatRelativeArabic(DateTime dateTime, {DateTime? reference}) {
  final now = reference ?? DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 60) {
    return 'منذ ${difference.inMinutes.clamp(1, 59)} دقيقة';
  }
  if (difference.inHours < 24) {
    return 'منذ ${difference.inHours} ساعة';
  }
  if (difference.inDays == 1) {
    return 'أمس';
  }
  return formatArabicDate(dateTime);
}

String formatTimeUntilArabic(DateTime? dateTime, {DateTime? reference}) {
  if (dateTime == null) {
    return 'قريبًا';
  }

  final now = reference ?? DateTime.now();
  final difference = dateTime.difference(now);
  if (difference.inMinutes <= 59) {
    return 'خلال ${difference.inMinutes.clamp(1, 59)} دقيقة';
  }
  if (difference.inHours <= 23) {
    return 'خلال ${difference.inHours} ساعة';
  }
  if (difference.inDays == 1) {
    return 'غدًا';
  }
  return 'خلال ${difference.inDays} يوم';
}

String formatDueLabelArabic(DateTime dueAt, {DateTime? reference}) {
  final now = reference ?? DateTime.now();
  final difference = dueAt.difference(now);

  if (difference.inHours < 24) {
    return 'التسليم خلال ${difference.inHours.clamp(1, 23)} ساعة';
  }
  if (difference.inDays == 1) {
    return 'آخر موعد غدًا';
  }
  return 'آخر موعد خلال ${difference.inDays} يوم';
}

String academicStandingLabel(double gpa) {
  if (gpa >= 3.5) {
    return 'ممتاز';
  }
  if (gpa >= 3.0) {
    return 'جيد جدًا';
  }
  if (gpa >= 2.0) {
    return 'جيد';
  }
  return 'يحتاج متابعة';
}
