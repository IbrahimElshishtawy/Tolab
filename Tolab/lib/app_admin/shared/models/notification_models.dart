import 'package:intl/intl.dart';

import '../../../app/localization/current_locale_state.dart';

enum AdminNotificationCategory { academic, messages, system, announcements }

enum NotificationQuickActionType { approve, open, reply }

enum NotificationRealtimeStatus {
  idle,
  connecting,
  live,
  polling,
  disconnected,
  error,
}

enum NotificationHistoryDateFilter { all, today, last7Days, last30Days }

enum NotificationAudienceType {
  general,
  cohorts,
  doctors,
  students,
  staff,
  departments,
}

enum NotificationDeliveryMode { instant, scheduled }

enum NotificationTone { message, alert, warning }

extension AdminNotificationCategoryX on AdminNotificationCategory {
  String get label => switch (this) {
    AdminNotificationCategory.academic =>
      CurrentLocaleState.isArabic ? 'أكاديمي' : 'Academic',
    AdminNotificationCategory.messages =>
      CurrentLocaleState.isArabic ? 'رسائل' : 'Messages',
    AdminNotificationCategory.system =>
      CurrentLocaleState.isArabic ? 'النظام' : 'System',
    AdminNotificationCategory.announcements =>
      CurrentLocaleState.isArabic ? 'إعلانات' : 'Announcements',
  };

  String get backendType => switch (this) {
    AdminNotificationCategory.academic => 'GRADE',
    AdminNotificationCategory.messages => 'MODERATION',
    AdminNotificationCategory.system => 'SYSTEM',
    AdminNotificationCategory.announcements => 'CONTENT',
  };

  static AdminNotificationCategory fromRemoteType(String rawType) {
    final normalized = rawType.trim().toUpperCase();
    return switch (normalized) {
      'GRADE' ||
      'ACADEMIC' ||
      'REGISTRATION' ||
      'SCHEDULE' => AdminNotificationCategory.academic,
      'MESSAGE' ||
      'MESSAGES' ||
      'CHAT' ||
      'MODERATION' => AdminNotificationCategory.messages,
      'ANNOUNCEMENT' ||
      'ANNOUNCEMENTS' ||
      'CONTENT' ||
      'BROADCAST' => AdminNotificationCategory.announcements,
      _ => AdminNotificationCategory.system,
    };
  }
}

extension NotificationQuickActionTypeX on NotificationQuickActionType {
  String get label => switch (this) {
    NotificationQuickActionType.approve =>
      CurrentLocaleState.isArabic ? 'اعتماد' : 'Approve',
    NotificationQuickActionType.open =>
      CurrentLocaleState.isArabic ? 'فتح' : 'Open',
    NotificationQuickActionType.reply =>
      CurrentLocaleState.isArabic ? 'رد' : 'Reply',
  };
}

extension NotificationRealtimeStatusX on NotificationRealtimeStatus {
  String get label => switch (this) {
    NotificationRealtimeStatus.idle =>
      CurrentLocaleState.isArabic ? 'متوقف' : 'Idle',
    NotificationRealtimeStatus.connecting =>
      CurrentLocaleState.isArabic ? 'جاري الاتصال' : 'Connecting',
    NotificationRealtimeStatus.live =>
      CurrentLocaleState.isArabic ? 'مباشر الآن' : 'Realtime live',
    NotificationRealtimeStatus.polling =>
      CurrentLocaleState.isArabic ? 'تحديث احتياطي' : 'Polling backup',
    NotificationRealtimeStatus.disconnected =>
      CurrentLocaleState.isArabic ? 'غير متصل' : 'Disconnected',
    NotificationRealtimeStatus.error =>
      CurrentLocaleState.isArabic ? 'مشكلة اتصال' : 'Connection issue',
  };
}

extension NotificationHistoryDateFilterX on NotificationHistoryDateFilter {
  String get label => switch (this) {
    NotificationHistoryDateFilter.all =>
      CurrentLocaleState.isArabic ? 'كل الوقت' : 'All time',
    NotificationHistoryDateFilter.today =>
      CurrentLocaleState.isArabic ? 'اليوم' : 'Today',
    NotificationHistoryDateFilter.last7Days =>
      CurrentLocaleState.isArabic ? 'آخر 7 أيام' : 'Last 7 days',
    NotificationHistoryDateFilter.last30Days =>
      CurrentLocaleState.isArabic ? 'آخر 30 يوم' : 'Last 30 days',
  };

  bool matches(DateTime value, DateTime now) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    return switch (this) {
      NotificationHistoryDateFilter.all => true,
      NotificationHistoryDateFilter.today =>
        !value.isBefore(startOfToday) &&
            value.isBefore(startOfToday.add(const Duration(days: 1))),
      NotificationHistoryDateFilter.last7Days => !value.isBefore(
        startOfToday.subtract(const Duration(days: 6)),
      ),
      NotificationHistoryDateFilter.last30Days => !value.isBefore(
        startOfToday.subtract(const Duration(days: 29)),
      ),
    };
  }
}

extension NotificationAudienceTypeX on NotificationAudienceType {
  String get label => switch (this) {
    NotificationAudienceType.general =>
      CurrentLocaleState.isArabic ? 'عام' : 'General',
    NotificationAudienceType.cohorts =>
      CurrentLocaleState.isArabic ? 'دفعات' : 'Cohorts',
    NotificationAudienceType.doctors =>
      CurrentLocaleState.isArabic ? 'دكاترة' : 'Doctors',
    NotificationAudienceType.students =>
      CurrentLocaleState.isArabic ? 'طلاب' : 'Students',
    NotificationAudienceType.staff =>
      CurrentLocaleState.isArabic ? 'طاقم' : 'Staff',
    NotificationAudienceType.departments =>
      CurrentLocaleState.isArabic ? 'أقسام' : 'Departments',
  };

  String get backendValue => switch (this) {
    NotificationAudienceType.general => 'general',
    NotificationAudienceType.cohorts => 'cohorts',
    NotificationAudienceType.doctors => 'doctors',
    NotificationAudienceType.students => 'students',
    NotificationAudienceType.staff => 'staff',
    NotificationAudienceType.departments => 'departments',
  };

  static NotificationAudienceType? fromRaw(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'cohort' ||
      'cohorts' ||
      'batch' ||
      'batches' => NotificationAudienceType.cohorts,
      'doctor' ||
      'doctors' ||
      'instructor' ||
      'instructors' => NotificationAudienceType.doctors,
      'student' || 'students' => NotificationAudienceType.students,
      'staff' => NotificationAudienceType.staff,
      'department' || 'departments' => NotificationAudienceType.departments,
      'general' || 'all' || 'everyone' => NotificationAudienceType.general,
      _ => null,
    };
  }
}

extension NotificationDeliveryModeX on NotificationDeliveryMode {
  String get label => switch (this) {
    NotificationDeliveryMode.instant =>
      CurrentLocaleState.isArabic ? 'إرسال الآن' : 'Send now',
    NotificationDeliveryMode.scheduled =>
      CurrentLocaleState.isArabic ? 'جدولة' : 'Schedule',
  };
}

extension NotificationToneX on NotificationTone {
  String get label => switch (this) {
    NotificationTone.message =>
      CurrentLocaleState.isArabic ? 'رسالة' : 'Message',
    NotificationTone.alert => CurrentLocaleState.isArabic ? 'تنبيه' : 'Alert',
    NotificationTone.warning =>
      CurrentLocaleState.isArabic ? 'تحذير' : 'Warning',
  };

  String get backendValue => switch (this) {
    NotificationTone.message => 'message',
    NotificationTone.alert => 'alert',
    NotificationTone.warning => 'warning',
  };

  static NotificationTone? fromRaw(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'alert' => NotificationTone.alert,
      'warning' => NotificationTone.warning,
      'message' => NotificationTone.message,
      _ => null,
    };
  }
}

class NotificationQuickAction {
  const NotificationQuickAction({required this.type, this.route});

  final NotificationQuickActionType type;
  final String? route;
}

class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.isRead,
    required this.rawType,
    this.refType,
    this.refId,
    this.source = 'api',
    this.audienceLabel,
    this.audienceType,
    this.tone,
    this.scheduledAt,
  });

  final String id;
  final String title;
  final String body;
  final AdminNotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final String rawType;
  final String? refType;
  final String? refId;
  final String source;
  final String? audienceLabel;
  final NotificationAudienceType? audienceType;
  final NotificationTone? tone;
  final DateTime? scheduledAt;

  bool get isScheduled =>
      scheduledAt != null && scheduledAt!.isAfter(DateTime.now());

  String get createdAtLabel {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));

    if (!createdAt.isBefore(startOfToday)) {
      return CurrentLocaleState.isArabic
          ? 'اليوم، ${DateFormat('HH:mm').format(createdAt)}'
          : 'Today, ${DateFormat('HH:mm').format(createdAt)}';
    }
    if (!createdAt.isBefore(startOfYesterday)) {
      return CurrentLocaleState.isArabic
          ? 'أمس، ${DateFormat('HH:mm').format(createdAt)}'
          : 'Yesterday, ${DateFormat('HH:mm').format(createdAt)}';
    }
    if (createdAt.year == now.year) {
      return DateFormat('MMM d, HH:mm').format(createdAt);
    }
    return DateFormat('MMM d, yyyy').format(createdAt);
  }

  List<NotificationQuickAction> get quickActions => switch (category) {
    AdminNotificationCategory.academic => const [
      NotificationQuickAction(type: NotificationQuickActionType.approve),
      NotificationQuickAction(type: NotificationQuickActionType.open),
    ],
    AdminNotificationCategory.messages => const [
      NotificationQuickAction(type: NotificationQuickActionType.reply),
      NotificationQuickAction(type: NotificationQuickActionType.open),
    ],
    AdminNotificationCategory.announcements => const [
      NotificationQuickAction(type: NotificationQuickActionType.open),
      NotificationQuickAction(type: NotificationQuickActionType.approve),
    ],
    AdminNotificationCategory.system => const [
      NotificationQuickAction(type: NotificationQuickActionType.open),
    ],
  };

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return title.toLowerCase().contains(normalized) ||
        body.toLowerCase().contains(normalized) ||
        category.label.toLowerCase().contains(normalized) ||
        (audienceLabel?.toLowerCase().contains(normalized) ?? false);
  }

  AdminNotification copyWith({
    String? id,
    String? title,
    String? body,
    AdminNotificationCategory? category,
    DateTime? createdAt,
    bool? isRead,
    String? rawType,
    String? refType,
    String? refId,
    String? source,
    String? audienceLabel,
    NotificationAudienceType? audienceType,
    NotificationTone? tone,
    DateTime? scheduledAt,
    bool clearRefType = false,
    bool clearRefId = false,
    bool clearAudienceLabel = false,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      rawType: rawType ?? this.rawType,
      refType: clearRefType ? null : refType ?? this.refType,
      refId: clearRefId ? null : refId ?? this.refId,
      source: source ?? this.source,
      audienceLabel: clearAudienceLabel
          ? null
          : audienceLabel ?? this.audienceLabel,
      audienceType: audienceType ?? this.audienceType,
      tone: tone ?? this.tone,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  AdminNotification markRead() => copyWith(isRead: true);

  static AdminNotification fromJson(Map<String, dynamic> json) {
    final rawType =
        json['type']?.toString() ??
        json['category']?.toString() ??
        json['kind']?.toString() ??
        'SYSTEM';
    return AdminNotification(
      id:
          json['id']?.toString() ??
          json['notification_id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Notification',
      body:
          json['body']?.toString() ??
          json['message']?.toString() ??
          json['subtitle']?.toString() ??
          '',
      category: AdminNotificationCategoryX.fromRemoteType(rawType),
      createdAt: _parseDateTime(
        json['created_at'] ??
            json['createdAt'] ??
            json['timestamp'] ??
            json['sent_at'],
      ),
      isRead: _parseBool(json['is_read'] ?? json['isRead']),
      rawType: rawType,
      refType: json['ref_type']?.toString() ?? json['refType']?.toString(),
      refId: json['ref_id']?.toString() ?? json['refId']?.toString(),
      source: json['source']?.toString() ?? 'api',
      audienceLabel:
          json['audience_label']?.toString() ??
          json['audience']?.toString() ??
          json['target']?.toString(),
      audienceType: NotificationAudienceTypeX.fromRaw(
        json['audience_type']?.toString() ?? json['audienceType']?.toString(),
      ),
      tone: NotificationToneX.fromRaw(
        json['tone']?.toString() ?? json['priority']?.toString(),
      ),
      scheduledAt: _parseOptionalDateTime(
        json['scheduled_at'] ?? json['scheduledAt'] ?? json['deliver_at'],
      ),
    );
  }

  static AdminNotification fromMessagePayload(
    Map<String, dynamic> payload, {
    required String source,
  }) {
    final normalized = Map<String, dynamic>.from(payload);
    normalized['source'] = source;
    if (!normalized.containsKey('created_at')) {
      normalized['created_at'] = DateTime.now().toIso8601String();
    }
    return fromJson(normalized);
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value.toLocal();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return _parseDateTime(value);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }
}
