class DashboardSnapshot {
  const DashboardSnapshot({
    required this.header,
    this.quickActions = const <DashboardQuickAction>[],
    required this.actionCenter,
    required this.todayFocus,
    required this.timeline,
    required this.subjectsOverview,
    required this.studentsAttention,
    required this.studentActivityInsights,
    required this.courseHealth,
    required this.groupActivityFeed,
    required this.notificationsPreview,
    required this.pendingGrading,
    required this.performanceAnalytics,
    required this.riskAlerts,
    required this.weeklySummary,
    required this.smartSuggestions,
  });

  final DashboardHeader header;
  final List<DashboardQuickAction> quickActions;
  final DashboardActionCenter actionCenter;
  final DashboardTodayFocus todayFocus;
  final DashboardTimeline timeline;
  final DashboardSubjectsOverview subjectsOverview;
  final DashboardStudentsAttention studentsAttention;
  final DashboardStudentActivityInsights studentActivityInsights;
  final DashboardCourseHealth courseHealth;
  final DashboardGroupActivityFeed groupActivityFeed;
  final DashboardNotificationsPreview notificationsPreview;
  final DashboardPendingGrading pendingGrading;
  final DashboardPerformanceAnalytics performanceAnalytics;
  final DashboardRiskAlerts riskAlerts;
  final DashboardWeeklySummary weeklySummary;
  final DashboardSmartSuggestions smartSuggestions;

  DashboardUserSummary get user => header.user;

  bool get hasContent =>
      quickActions.isNotEmpty ||
      actionCenter.items.isNotEmpty ||
      timeline.hasItems ||
      subjectsOverview.items.isNotEmpty ||
      studentsAttention.items.isNotEmpty ||
      groupActivityFeed.items.isNotEmpty ||
      notificationsPreview.items.isNotEmpty ||
      pendingGrading.items.isNotEmpty ||
      riskAlerts.items.isNotEmpty ||
      smartSuggestions.items.isNotEmpty;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) {
    return DashboardSnapshot(
      header: DashboardHeader.fromJson(_map(json['header'])),
      quickActions: _mapList(json['quick_actions'], DashboardQuickAction.fromJson),
      actionCenter: DashboardActionCenter.fromJson(_map(json['action_center'])),
      todayFocus: DashboardTodayFocus.fromJson(_map(json['today_focus'])),
      timeline: DashboardTimeline.fromJson(_map(json['timeline'])),
      subjectsOverview: DashboardSubjectsOverview.fromJson(
        _map(json['subjects_overview']),
      ),
      studentsAttention: DashboardStudentsAttention.fromJson(
        _map(json['students_attention']),
      ),
      studentActivityInsights: DashboardStudentActivityInsights.fromJson(
        _map(json['student_activity_insights']),
      ),
      courseHealth: DashboardCourseHealth.fromJson(_map(json['course_health'])),
      groupActivityFeed: DashboardGroupActivityFeed.fromJson(
        _map(json['group_activity_feed']),
      ),
      notificationsPreview: DashboardNotificationsPreview.fromJson(
        _map(json['notifications_preview']),
      ),
      pendingGrading: DashboardPendingGrading.fromJson(
        _map(json['pending_grading']),
      ),
      performanceAnalytics: DashboardPerformanceAnalytics.fromJson(
        _map(json['performance_analytics']),
      ),
      riskAlerts: DashboardRiskAlerts.fromJson(_map(json['risk_alerts'])),
      weeklySummary: DashboardWeeklySummary.fromJson(
        _map(json['weekly_summary']),
      ),
      smartSuggestions: DashboardSmartSuggestions.fromJson(
        _map(json['smart_suggestions']),
      ),
    );
  }
}

class DashboardHeader {
  const DashboardHeader({
    required this.user,
    required this.notificationBadge,
    this.generatedAt,
  });

  final DashboardUserSummary user;
  final int notificationBadge;
  final DateTime? generatedAt;

  factory DashboardHeader.fromJson(Map<String, dynamic> json) {
    return DashboardHeader(
      user: DashboardUserSummary.fromJson(_map(json['user'])),
      notificationBadge: _int(json['notification_badge']),
      generatedAt: _dateTime(json['generated_at']),
    );
  }
}

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

  bool get isDoctor => role == 'DOCTOR';

  factory DashboardUserSummary.fromJson(Map<String, dynamic> json) {
    return DashboardUserSummary(
      id: _int(json['id']),
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
    this.icon = 'bolt',
    this.tone = 'primary',
  });

  final String id;
  final String label;
  final String description;
  final String route;
  final String permission;
  final String icon;
  final String tone;

  factory DashboardQuickAction.fromJson(Map<String, dynamic> json) {
    return DashboardQuickAction(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      permission: json['permission']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'bolt',
      tone: json['tone']?.toString() ?? 'primary',
    );
  }
}

class DashboardActionCenter {
  const DashboardActionCenter({
    required this.summary,
    this.items = const <DashboardActionItem>[],
  });

  final String summary;
  final List<DashboardActionItem> items;

  factory DashboardActionCenter.fromJson(Map<String, dynamic> json) {
    return DashboardActionCenter(
      summary: json['summary']?.toString() ?? '',
      items: _mapList(json['items'], DashboardActionItem.fromJson),
    );
  }
}

class DashboardActionItem {
  const DashboardActionItem({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.explanation,
    required this.ctaLabel,
    required this.route,
    this.meta = const <String, dynamic>{},
  });

  final String id;
  final String type;
  final String priority;
  final String title;
  final String explanation;
  final String ctaLabel;
  final String route;
  final Map<String, dynamic> meta;

  factory DashboardActionItem.fromJson(Map<String, dynamic> json) {
    return DashboardActionItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'LOW',
      title: json['title']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      ctaLabel: json['cta_label']?.toString() ?? 'Open',
      route: json['route']?.toString() ?? '',
      meta: _map(json['meta']),
    );
  }
}

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    this.tone = 'primary',
    this.caption,
  });

  final String label;
  final String value;
  final String tone;
  final String? caption;

  factory DashboardMetric.fromJson(Map<String, dynamic> json) {
    return DashboardMetric(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      tone: json['tone']?.toString() ?? 'primary',
      caption: json['caption']?.toString(),
    );
  }
}

class DashboardTodayFocus {
  const DashboardTodayFocus({
    required this.headline,
    required this.summary,
    this.primaryAction,
    this.metrics = const <DashboardMetric>[],
  });

  final String headline;
  final String summary;
  final DashboardActionItem? primaryAction;
  final List<DashboardMetric> metrics;

  factory DashboardTodayFocus.fromJson(Map<String, dynamic> json) {
    final actionMap = _map(json['primary_action']);
    return DashboardTodayFocus(
      headline: json['headline']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      primaryAction: actionMap.isEmpty
          ? null
          : DashboardActionItem.fromJson(actionMap),
      metrics: _mapList(json['metrics'], DashboardMetric.fromJson),
    );
  }
}

class DashboardTimeline {
  const DashboardTimeline({this.groups = const <DashboardTimelineGroup>[]});

  final List<DashboardTimelineGroup> groups;

  bool get hasItems => groups.any((group) => group.items.isNotEmpty);

  factory DashboardTimeline.fromJson(Map<String, dynamic> json) {
    return DashboardTimeline(
      groups: _mapList(json['groups'], DashboardTimelineGroup.fromJson),
    );
  }
}

class DashboardTimelineGroup {
  const DashboardTimelineGroup({
    required this.id,
    required this.label,
    this.items = const <DashboardTimelineItem>[],
  });

  final String id;
  final String label;
  final List<DashboardTimelineItem> items;

  factory DashboardTimelineGroup.fromJson(Map<String, dynamic> json) {
    return DashboardTimelineGroup(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      items: _mapList(json['items'], DashboardTimelineItem.fromJson),
    );
  }
}

class DashboardTimelineItem {
  const DashboardTimelineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subjectName,
    required this.whenLabel,
    required this.status,
    required this.route,
  });

  final String id;
  final String type;
  final String title;
  final String subjectName;
  final String whenLabel;
  final String status;
  final String route;

  factory DashboardTimelineItem.fromJson(Map<String, dynamic> json) {
    return DashboardTimelineItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      whenLabel: json['when_label']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
    );
  }
}

class DashboardSubjectsOverview {
  const DashboardSubjectsOverview({
    required this.summary,
    this.items = const <DashboardSubjectOverviewItem>[],
  });

  final String summary;
  final List<DashboardSubjectOverviewItem> items;

  factory DashboardSubjectsOverview.fromJson(Map<String, dynamic> json) {
    return DashboardSubjectsOverview(
      summary: json['summary']?.toString() ?? '',
      items: _mapList(json['items'], DashboardSubjectOverviewItem.fromJson),
    );
  }
}

class DashboardSubjectOverviewItem {
  const DashboardSubjectOverviewItem({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.academicYear,
    required this.batch,
    required this.studentCount,
    required this.groupsCount,
    required this.sectionsCount,
    required this.healthScore,
    required this.riskLevel,
    this.quickActions = const <DashboardSubjectQuickAction>[],
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
  final int healthScore;
  final String riskLevel;
  final List<DashboardSubjectQuickAction> quickActions;

  factory DashboardSubjectOverviewItem.fromJson(Map<String, dynamic> json) {
    return DashboardSubjectOverviewItem(
      id: _int(json['id']),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      academicYear: json['academic_year']?.toString() ?? '',
      batch: json['batch']?.toString() ?? '',
      studentCount: _int(json['student_count']),
      groupsCount: _int(json['groups_count']),
      sectionsCount: _int(json['sections_count']),
      healthScore: _int(json['health_score']),
      riskLevel: json['risk_level']?.toString() ?? 'WATCH',
      quickActions: _mapList(
        json['quick_actions'],
        DashboardSubjectQuickAction.fromJson,
      ),
    );
  }
}

class DashboardSubjectQuickAction {
  const DashboardSubjectQuickAction({
    required this.label,
    required this.route,
  });

  final String label;
  final String route;

  factory DashboardSubjectQuickAction.fromJson(Map<String, dynamic> json) {
    return DashboardSubjectQuickAction(
      label: json['label']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
    );
  }
}

class DashboardStudentsAttention {
  const DashboardStudentsAttention({
    required this.count,
    this.items = const <DashboardStudentAttentionItem>[],
  });

  final int count;
  final List<DashboardStudentAttentionItem> items;

  factory DashboardStudentsAttention.fromJson(Map<String, dynamic> json) {
    return DashboardStudentsAttention(
      count: _int(json['count']),
      items: _mapList(json['items'], DashboardStudentAttentionItem.fromJson),
    );
  }
}

class DashboardStudentAttentionItem {
  const DashboardStudentAttentionItem({
    required this.studentId,
    required this.name,
    required this.reason,
    required this.severity,
    required this.ctaLabel,
    required this.route,
    this.details = const <String>[],
    this.lastSeen,
  });

  final int studentId;
  final String name;
  final String reason;
  final String severity;
  final String ctaLabel;
  final String route;
  final List<String> details;
  final DateTime? lastSeen;

  factory DashboardStudentAttentionItem.fromJson(Map<String, dynamic> json) {
    return DashboardStudentAttentionItem(
      studentId: _int(json['student_id']),
      name: json['name']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'LOW',
      ctaLabel: json['cta_label']?.toString() ?? 'Review',
      route: json['route']?.toString() ?? '',
      details: _stringList(json['details']),
      lastSeen: _dateTime(json['last_seen']),
    );
  }
}

class DashboardStudentActivityInsights {
  const DashboardStudentActivityInsights({
    required this.summary,
    required this.activeStudents,
    required this.inactiveStudents,
    required this.missingSubmissions,
    required this.newComments,
    required this.unreadMessages,
    required this.lowEngagementCount,
    required this.engagementRate,
    required this.studentsNeedingAttention,
    this.items = const <DashboardStudentAttentionItem>[],
  });

  final String summary;
  final int activeStudents;
  final int inactiveStudents;
  final int missingSubmissions;
  final int newComments;
  final int unreadMessages;
  final int lowEngagementCount;
  final int engagementRate;
  final int studentsNeedingAttention;
  final List<DashboardStudentAttentionItem> items;

  factory DashboardStudentActivityInsights.fromJson(Map<String, dynamic> json) {
    return DashboardStudentActivityInsights(
      summary: json['summary']?.toString() ?? '',
      activeStudents: _int(json['active_students']),
      inactiveStudents: _int(json['inactive_students']),
      missingSubmissions: _int(json['missing_submissions']),
      newComments: _int(json['new_comments']),
      unreadMessages: _int(json['unread_messages']),
      lowEngagementCount: _int(json['low_engagement_count']),
      engagementRate: _int(json['engagement_rate']),
      studentsNeedingAttention: _int(json['students_needing_attention']),
      items: _mapList(json['items'], DashboardStudentAttentionItem.fromJson),
    );
  }
}

class DashboardCourseHealth {
  const DashboardCourseHealth({
    required this.overallScore,
    required this.status,
    required this.summary,
    this.metrics = const <DashboardMetric>[],
    this.subjects = const <DashboardCourseHealthSubject>[],
  });

  final int overallScore;
  final String status;
  final String summary;
  final List<DashboardMetric> metrics;
  final List<DashboardCourseHealthSubject> subjects;

  factory DashboardCourseHealth.fromJson(Map<String, dynamic> json) {
    return DashboardCourseHealth(
      overallScore: _int(json['overall_score']),
      status: json['status']?.toString() ?? 'HEALTHY',
      summary: json['summary']?.toString() ?? '',
      metrics: _mapList(json['metrics'], DashboardMetric.fromJson),
      subjects: _mapList(
        json['subjects'],
        DashboardCourseHealthSubject.fromJson,
      ),
    );
  }
}

class DashboardCourseHealthSubject {
  const DashboardCourseHealthSubject({
    required this.subjectId,
    required this.subjectName,
    required this.score,
    required this.status,
  });

  final int subjectId;
  final String subjectName;
  final int score;
  final String status;

  factory DashboardCourseHealthSubject.fromJson(Map<String, dynamic> json) {
    return DashboardCourseHealthSubject(
      subjectId: _int(json['subject_id']),
      subjectName: json['subject_name']?.toString() ?? '',
      score: _int(json['score']),
      status: json['status']?.toString() ?? 'WATCH',
    );
  }
}

class DashboardGroupActivityFeed {
  const DashboardGroupActivityFeed({
    this.items = const <DashboardGroupActivityItem>[],
  });

  final List<DashboardGroupActivityItem> items;

  factory DashboardGroupActivityFeed.fromJson(Map<String, dynamic> json) {
    return DashboardGroupActivityFeed(
      items: _mapList(json['items'], DashboardGroupActivityItem.fromJson),
    );
  }
}

class DashboardGroupActivityItem {
  const DashboardGroupActivityItem({
    required this.id,
    required this.activityType,
    required this.subjectName,
    required this.groupName,
    required this.authorName,
    required this.content,
    required this.route,
    this.timestamp,
  });

  final String id;
  final String activityType;
  final String subjectName;
  final String groupName;
  final String authorName;
  final String content;
  final String route;
  final DateTime? timestamp;

  factory DashboardGroupActivityItem.fromJson(Map<String, dynamic> json) {
    return DashboardGroupActivityItem(
      id: json['id']?.toString() ?? '',
      activityType: json['activity_type']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      groupName: json['group_name']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      timestamp: _dateTime(json['timestamp']),
    );
  }
}

class DashboardNotificationsPreview {
  const DashboardNotificationsPreview({
    required this.unreadCount,
    this.items = const <DashboardNotificationItem>[],
  });

  final int unreadCount;
  final List<DashboardNotificationItem> items;

  factory DashboardNotificationsPreview.fromJson(Map<String, dynamic> json) {
    return DashboardNotificationsPreview(
      unreadCount: _int(json['unread_count']),
      items: _mapList(json['items'], DashboardNotificationItem.fromJson),
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
      id: _int(json['id']),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      route: json['route']?.toString() ?? '',
      time: _dateTime(json['time']),
      isUnread: json['is_unread'] == true,
    );
  }
}

class DashboardPendingGrading {
  const DashboardPendingGrading({
    required this.canManage,
    required this.count,
    required this.summary,
    this.items = const <DashboardPendingGradingItem>[],
  });

  final bool canManage;
  final int count;
  final String summary;
  final List<DashboardPendingGradingItem> items;

  factory DashboardPendingGrading.fromJson(Map<String, dynamic> json) {
    return DashboardPendingGrading(
      canManage: json['can_manage'] == true,
      count: _int(json['count']),
      summary: json['summary']?.toString() ?? '',
      items: _mapList(json['items'], DashboardPendingGradingItem.fromJson),
    );
  }
}

class DashboardPendingGradingItem {
  const DashboardPendingGradingItem({
    required this.taskId,
    required this.title,
    required this.subjectName,
    required this.pendingCount,
    required this.ctaLabel,
    required this.route,
  });

  final int taskId;
  final String title;
  final String subjectName;
  final int pendingCount;
  final String ctaLabel;
  final String route;

  factory DashboardPendingGradingItem.fromJson(Map<String, dynamic> json) {
    return DashboardPendingGradingItem(
      taskId: _int(json['task_id']),
      title: json['title']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      pendingCount: _int(json['pending_count']),
      ctaLabel: json['cta_label']?.toString() ?? 'Grade',
      route: json['route']?.toString() ?? '',
    );
  }
}

class DashboardPerformanceAnalytics {
  const DashboardPerformanceAnalytics({
    required this.isLimited,
    required this.summary,
    this.averageScore,
    this.trend = const <DashboardChartPoint>[],
    this.topPerformers = const <DashboardStudentPerformance>[],
    this.lowPerformers = const <DashboardStudentPerformance>[],
  });

  final bool isLimited;
  final String summary;
  final double? averageScore;
  final List<DashboardChartPoint> trend;
  final List<DashboardStudentPerformance> topPerformers;
  final List<DashboardStudentPerformance> lowPerformers;

  factory DashboardPerformanceAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardPerformanceAnalytics(
      isLimited: json['is_limited'] == true,
      summary: json['summary']?.toString() ?? '',
      averageScore: _doubleNullable(json['average_score']),
      trend: _mapList(json['trend'], DashboardChartPoint.fromJson),
      topPerformers: _mapList(
        json['top_performers'],
        DashboardStudentPerformance.fromJson,
      ),
      lowPerformers: _mapList(
        json['low_performers'],
        DashboardStudentPerformance.fromJson,
      ),
    );
  }
}

class DashboardChartPoint {
  const DashboardChartPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  factory DashboardChartPoint.fromJson(Map<String, dynamic> json) {
    return DashboardChartPoint(
      label: json['label']?.toString() ?? '',
      value: _double(json['value']),
    );
  }
}

class DashboardStudentPerformance {
  const DashboardStudentPerformance({
    required this.studentName,
    required this.averageScore,
  });

  final String studentName;
  final double averageScore;

  factory DashboardStudentPerformance.fromJson(Map<String, dynamic> json) {
    return DashboardStudentPerformance(
      studentName: json['student_name']?.toString() ?? '',
      averageScore: _double(json['average_score']),
    );
  }
}

class DashboardRiskAlerts {
  const DashboardRiskAlerts({
    required this.count,
    this.items = const <DashboardRiskAlertItem>[],
  });

  final int count;
  final List<DashboardRiskAlertItem> items;

  factory DashboardRiskAlerts.fromJson(Map<String, dynamic> json) {
    return DashboardRiskAlerts(
      count: _int(json['count']),
      items: _mapList(json['items'], DashboardRiskAlertItem.fromJson),
    );
  }
}

class DashboardRiskAlertItem {
  const DashboardRiskAlertItem({
    required this.id,
    required this.severity,
    required this.title,
    required this.explanation,
    required this.ctaLabel,
    required this.route,
  });

  final String id;
  final String severity;
  final String title;
  final String explanation;
  final String ctaLabel;
  final String route;

  factory DashboardRiskAlertItem.fromJson(Map<String, dynamic> json) {
    return DashboardRiskAlertItem(
      id: json['id']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'MEDIUM',
      title: json['title']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      ctaLabel: json['cta_label']?.toString() ?? 'Review',
      route: json['route']?.toString() ?? '',
    );
  }
}

class DashboardWeeklySummary {
  const DashboardWeeklySummary({
    required this.headline,
    this.items = const <DashboardMetric>[],
  });

  final String headline;
  final List<DashboardMetric> items;

  factory DashboardWeeklySummary.fromJson(Map<String, dynamic> json) {
    return DashboardWeeklySummary(
      headline: json['headline']?.toString() ?? '',
      items: _mapList(json['items'], DashboardMetric.fromJson),
    );
  }
}

class DashboardSmartSuggestions {
  const DashboardSmartSuggestions({
    this.items = const <DashboardSuggestionItem>[],
  });

  final List<DashboardSuggestionItem> items;

  factory DashboardSmartSuggestions.fromJson(Map<String, dynamic> json) {
    return DashboardSmartSuggestions(
      items: _mapList(json['items'], DashboardSuggestionItem.fromJson),
    );
  }
}

class DashboardSuggestionItem {
  const DashboardSuggestionItem({
    required this.id,
    required this.title,
    required this.explanation,
    required this.ctaLabel,
    required this.route,
  });

  final String id;
  final String title;
  final String explanation;
  final String ctaLabel;
  final String route;

  factory DashboardSuggestionItem.fromJson(Map<String, dynamic> json) {
    return DashboardSuggestionItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      ctaLabel: json['cta_label']?.toString() ?? 'Open',
      route: json['route']?.toString() ?? '',
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

List<T> _mapList<T>(
  Object? value,
  T Function(Map<String, dynamic> json) mapper,
) {
  return (value as List? ?? const <Object>[])
      .map((item) => mapper(_map(item)))
      .toList();
}

List<String> _stringList(Object? value) {
  return (value as List? ?? const <Object>[])
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}

int _int(Object? value) {
  return (value as num?)?.toInt() ?? int.tryParse(value?.toString() ?? '') ?? 0;
}

double _double(Object? value) {
  return (value as num?)?.toDouble() ??
      double.tryParse(value?.toString() ?? '') ??
      0;
}

double? _doubleNullable(Object? value) {
  if (value == null) {
    return null;
  }
  return (value as num?)?.toDouble() ?? double.tryParse(value.toString());
}

DateTime? _dateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
