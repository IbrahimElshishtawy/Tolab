class DashboardUserSummary {
  const DashboardUserSummary({
    required this.id,
    required this.name,
    required this.role,
    required this.greeting,
    required this.subtitle,
    this.avatar,
    this.departments = const <String>[],
    this.academicYears = const <String>[],
  });

  final int id;
  final String name;
  final String role;
  final String greeting;
  final String subtitle;
  final String? avatar;
  final List<String> departments;
  final List<String> academicYears;

  factory DashboardUserSummary.fromJson(Map<String, dynamic> json) {
    return DashboardUserSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'ASSISTANT',
      greeting: json['greeting']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      departments: _stringList(json['departments']),
      academicYears: _stringList(json['academic_years']),
    );
  }
}

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.id,
    required this.label,
    required this.description,
    required this.route,
    required this.permission,
  });

  final String id;
  final String label;
  final String description;
  final String route;
  final String permission;

  factory DashboardQuickAction.fromJson(Map<String, dynamic> json) {
    return DashboardQuickAction(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      permission: json['permission']?.toString() ?? '',
    );
  }
}

class DashboardNotificationItem {
  const DashboardNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.route,
    this.time,
    this.isUnread = false,
  });

  final int id;
  final String title;
  final String body;
  final String category;
  final String route;
  final DateTime? time;
  final bool isUnread;

  factory DashboardNotificationItem.fromJson(Map<String, dynamic> json) {
    return DashboardNotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      time: _dateTime(json['time']),
      isUnread: json['is_unread'] == true,
    );
  }
}

class DashboardNotificationsSummary {
  const DashboardNotificationsSummary({
    required this.unreadCount,
    this.latest = const <DashboardNotificationItem>[],
  });

  final int unreadCount;
  final List<DashboardNotificationItem> latest;

  factory DashboardNotificationsSummary.fromJson(Map<String, dynamic> json) {
    return DashboardNotificationsSummary(
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      latest: _mapList(json['latest'], DashboardNotificationItem.fromJson),
    );
  }
}

class DashboardTodayStats {
  const DashboardTodayStats({
    required this.lectures,
    required this.sections,
    required this.quizzes,
    required this.tasks,
  });

  final int lectures;
  final int sections;
  final int quizzes;
  final int tasks;

  factory DashboardTodayStats.fromJson(Map<String, dynamic> json) {
    return DashboardTodayStats(
      lectures: (json['lectures'] as num?)?.toInt() ?? 0,
      sections: (json['sections'] as num?)?.toInt() ?? 0,
      quizzes: (json['quizzes'] as num?)?.toInt() ?? 0,
      tasks: (json['tasks'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardActionRequiredItem {
  const DashboardActionRequiredItem({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.cta,
    required this.route,
    this.routeMeta = const <String, dynamic>{},
  });

  final String id;
  final String type;
  final String priority;
  final String title;
  final String description;
  final String cta;
  final String route;
  final Map<String, dynamic> routeMeta;

  factory DashboardActionRequiredItem.fromJson(Map<String, dynamic> json) {
    return DashboardActionRequiredItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'LOW',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cta: json['cta']?.toString() ?? 'Open',
      route: json['route']?.toString() ?? '',
      routeMeta: _map(json['route_meta']),
    );
  }
}

class DashboardScheduleItem {
  const DashboardScheduleItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subjectName,
    required this.time,
    required this.location,
    required this.status,
    required this.route,
    this.date,
  });

  final int id;
  final String type;
  final String title;
  final String subjectName;
  final String time;
  final String location;
  final String status;
  final String route;
  final String? date;

  factory DashboardScheduleItem.fromJson(Map<String, dynamic> json) {
    return DashboardScheduleItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      date: json['date']?.toString(),
    );
  }
}

class DashboardUpcomingItem {
  const DashboardUpcomingItem({
    required this.id,
    required this.type,
    required this.subjectName,
    required this.title,
    required this.status,
    required this.cta,
    required this.route,
    this.dateTime,
  });

  final String id;
  final String type;
  final String subjectName;
  final String title;
  final String status;
  final String cta;
  final String route;
  final DateTime? dateTime;

  factory DashboardUpcomingItem.fromJson(Map<String, dynamic> json) {
    return DashboardUpcomingItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      cta: json['cta']?.toString() ?? 'Open',
      route: json['route']?.toString() ?? '',
      dateTime: _dateTime(json['date_time']),
    );
  }
}

class DashboardSubjectLink {
  const DashboardSubjectLink({required this.label, required this.route});

  final String label;
  final String route;

  factory DashboardSubjectLink.fromJson(Map<String, dynamic> json) {
    return DashboardSubjectLink(
      label: json['label']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
    );
  }
}

class DashboardSubjectPreview {
  const DashboardSubjectPreview({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.academicYear,
    required this.batch,
    required this.studentCount,
    required this.groupsCount,
    required this.sectionsCount,
    this.routes = const <DashboardSubjectLink>[],
  });

  final int id;
  final String name;
  final String code;
  final String department;
  final String academicYear;
  final String batch;
  final int studentCount;
  final int groupsCount;
  final int sectionsCount;
  final List<DashboardSubjectLink> routes;

  factory DashboardSubjectPreview.fromJson(Map<String, dynamic> json) {
    return DashboardSubjectPreview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      academicYear: json['academic_year']?.toString() ?? '',
      batch: json['batch']?.toString() ?? '',
      studentCount: (json['student_count'] as num?)?.toInt() ?? 0,
      groupsCount: (json['groups_count'] as num?)?.toInt() ?? 0,
      sectionsCount: (json['sections_count'] as num?)?.toInt() ?? 0,
      routes: _mapList(json['routes'], DashboardSubjectLink.fromJson),
    );
  }
}

class DashboardGroupActivityItem {
  const DashboardGroupActivityItem({
    required this.id,
    required this.activityType,
    required this.content,
    required this.route,
    this.subjectName,
    this.groupName,
    this.authorName,
    this.timestamp,
  });

  final String id;
  final String activityType;
  final String content;
  final String route;
  final String? subjectName;
  final String? groupName;
  final String? authorName;
  final DateTime? timestamp;

  factory DashboardGroupActivityItem.fromJson(Map<String, dynamic> json) {
    return DashboardGroupActivityItem(
      id: json['id']?.toString() ?? '',
      activityType: json['activity_type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      subjectName: json['subject_name']?.toString(),
      groupName: json['group_name']?.toString(),
      authorName: json['author_name']?.toString(),
      timestamp: _dateTime(json['timestamp']),
    );
  }
}

class DashboardStudentAttentionItem {
  const DashboardStudentAttentionItem({
    required this.studentId,
    required this.name,
    required this.reason,
    this.details = const <String>[],
  });

  final int studentId;
  final String name;
  final String reason;
  final List<String> details;

  factory DashboardStudentAttentionItem.fromJson(Map<String, dynamic> json) {
    return DashboardStudentAttentionItem(
      studentId: (json['student_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      details: _stringList(json['details']),
    );
  }
}

class DashboardStudentInsights {
  const DashboardStudentInsights({
    required this.activeStudents,
    required this.inactiveStudents,
    required this.missingSubmissions,
    required this.newComments,
    required this.unreadMessages,
    required this.lowEngagementCount,
    required this.studentsNeedingAttention,
    this.needsAttention = const <DashboardStudentAttentionItem>[],
  });

  final int activeStudents;
  final int inactiveStudents;
  final int missingSubmissions;
  final int newComments;
  final int unreadMessages;
  final int lowEngagementCount;
  final int studentsNeedingAttention;
  final List<DashboardStudentAttentionItem> needsAttention;

  factory DashboardStudentInsights.fromJson(Map<String, dynamic> json) {
    return DashboardStudentInsights(
      activeStudents: (json['active_students'] as num?)?.toInt() ?? 0,
      inactiveStudents: (json['inactive_students'] as num?)?.toInt() ?? 0,
      missingSubmissions: (json['missing_submissions'] as num?)?.toInt() ?? 0,
      newComments: (json['new_comments'] as num?)?.toInt() ?? 0,
      unreadMessages: (json['unread_messages'] as num?)?.toInt() ?? 0,
      lowEngagementCount: (json['low_engagement_count'] as num?)?.toInt() ?? 0,
      studentsNeedingAttention:
          (json['students_needing_attention'] as num?)?.toInt() ?? 0,
      needsAttention: _mapList(
        json['needs_attention'],
        DashboardStudentAttentionItem.fromJson,
      ),
    );
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.user,
    required this.notifications,
    required this.todayStats,
    this.quickActions = const <DashboardQuickAction>[],
    this.actionRequired = const <DashboardActionRequiredItem>[],
    this.todaySchedule = const <DashboardScheduleItem>[],
    this.upcoming = const <DashboardUpcomingItem>[],
    this.subjectsPreview = const <DashboardSubjectPreview>[],
    this.groupActivity = const <DashboardGroupActivityItem>[],
    required this.studentInsights,
  });

  final DashboardUserSummary user;
  final DashboardNotificationsSummary notifications;
  final DashboardTodayStats todayStats;
  final List<DashboardQuickAction> quickActions;
  final List<DashboardActionRequiredItem> actionRequired;
  final List<DashboardScheduleItem> todaySchedule;
  final List<DashboardUpcomingItem> upcoming;
  final List<DashboardSubjectPreview> subjectsPreview;
  final List<DashboardGroupActivityItem> groupActivity;
  final DashboardStudentInsights studentInsights;

  bool get hasContent =>
      quickActions.isNotEmpty ||
      actionRequired.isNotEmpty ||
      todaySchedule.isNotEmpty ||
      upcoming.isNotEmpty ||
      subjectsPreview.isNotEmpty ||
      groupActivity.isNotEmpty;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshot(
      user: DashboardUserSummary.fromJson(_map(json['user'])),
      quickActions: _mapList(
        json['quick_actions'],
        DashboardQuickAction.fromJson,
      ),
      notifications: DashboardNotificationsSummary.fromJson(
        _map(json['notifications']),
      ),
      todayStats: DashboardTodayStats.fromJson(_map(json['today_stats'])),
      actionRequired: _mapList(
        json['action_required'],
        DashboardActionRequiredItem.fromJson,
      ),
      todaySchedule: _mapList(
        json['today_schedule'],
        DashboardScheduleItem.fromJson,
      ),
      upcoming: _mapList(json['upcoming'], DashboardUpcomingItem.fromJson),
      subjectsPreview: _mapList(
        json['subjects_preview'],
        DashboardSubjectPreview.fromJson,
      ),
      groupActivity: _mapList(
        json['group_activity'],
        DashboardGroupActivityItem.fromJson,
      ),
      studentInsights: DashboardStudentInsights.fromJson(
        _map(json['student_insights']),
      ),
    );
  }
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, dynamic>{};
}

List<String> _stringList(Object? value) {
  return (value as List? ?? const <Object>[])
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<T> _mapList<T>(
  Object? value,
  T Function(Map<String, dynamic> json) mapper,
) {
  return (value as List? ?? const <Object>[])
      .map((item) => mapper(_map(item)))
      .toList();
}

DateTime? _dateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
