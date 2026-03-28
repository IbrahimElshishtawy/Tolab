import 'package:flutter/material.dart';

import '../../../core/helpers/json_types.dart';

enum DashboardMetricTone { primary, secondary, info, success, warning, danger }

DashboardMetricTone dashboardMetricToneFromValue(String? value) {
  return switch (value?.toLowerCase().trim()) {
    'secondary' => DashboardMetricTone.secondary,
    'info' => DashboardMetricTone.info,
    'success' => DashboardMetricTone.success,
    'warning' => DashboardMetricTone.warning,
    'danger' || 'critical' => DashboardMetricTone.danger,
    _ => DashboardMetricTone.primary,
  };
}

enum DashboardTrendDirection { up, down, neutral }

DashboardTrendDirection dashboardTrendDirectionFromValue(String? value) {
  return switch (value?.toLowerCase().trim()) {
    'down' || 'negative' => DashboardTrendDirection.down,
    'neutral' || 'flat' => DashboardTrendDirection.neutral,
    _ => DashboardTrendDirection.up,
  };
}

enum DashboardActivityType {
  student,
  staff,
  subject,
  enrollment,
  moderation,
  schedule,
  system,
}

DashboardActivityType dashboardActivityTypeFromValue(String? value) {
  return switch (value?.toLowerCase().trim()) {
    'student' => DashboardActivityType.student,
    'staff' => DashboardActivityType.staff,
    'subject' || 'course' => DashboardActivityType.subject,
    'enrollment' => DashboardActivityType.enrollment,
    'moderation' => DashboardActivityType.moderation,
    'schedule' => DashboardActivityType.schedule,
    _ => DashboardActivityType.system,
  };
}

enum DashboardScheduleType { lecture, exam, task, meeting, review }

DashboardScheduleType dashboardScheduleTypeFromValue(String? value) {
  return switch (value?.toLowerCase().trim()) {
    'lecture' => DashboardScheduleType.lecture,
    'exam' => DashboardScheduleType.exam,
    'task' || 'assignment' => DashboardScheduleType.task,
    'meeting' => DashboardScheduleType.meeting,
    _ => DashboardScheduleType.review,
  };
}

enum DashboardAlertSeverity { low, medium, high, critical }

DashboardAlertSeverity dashboardAlertSeverityFromValue(String? value) {
  return switch (value?.toLowerCase().trim()) {
    'low' => DashboardAlertSeverity.low,
    'medium' => DashboardAlertSeverity.medium,
    'critical' => DashboardAlertSeverity.critical,
    _ => DashboardAlertSeverity.high,
  };
}

class DashboardFilters {
  const DashboardFilters({
    this.semesterId,
    this.departmentId,
    this.courseId,
    this.instructorId,
  });

  final String? semesterId;
  final String? departmentId;
  final String? courseId;
  final String? instructorId;

  bool get isEmpty =>
      semesterId == null &&
      departmentId == null &&
      courseId == null &&
      instructorId == null;

  DashboardFilters copyWith({
    String? semesterId,
    String? departmentId,
    String? courseId,
    String? instructorId,
    bool clearSemester = false,
    bool clearDepartment = false,
    bool clearCourse = false,
    bool clearInstructor = false,
  }) {
    return DashboardFilters(
      semesterId: clearSemester ? null : semesterId ?? this.semesterId,
      departmentId: clearDepartment ? null : departmentId ?? this.departmentId,
      courseId: clearCourse ? null : courseId ?? this.courseId,
      instructorId: clearInstructor ? null : instructorId ?? this.instructorId,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (semesterId != null) 'semester': semesterId,
      if (departmentId != null) 'department': departmentId,
      if (courseId != null) 'course': courseId,
      if (instructorId != null) 'instructor': instructorId,
    };
  }

  factory DashboardFilters.fromJson(
    JsonMap json, {
    DashboardFilters fallback = const DashboardFilters(),
  }) {
    return DashboardFilters(
      semesterId: _stringOrNull(json['semester']) ?? fallback.semesterId,
      departmentId: _stringOrNull(json['department']) ?? fallback.departmentId,
      courseId: _stringOrNull(json['course']) ?? fallback.courseId,
      instructorId: _stringOrNull(json['instructor']) ?? fallback.instructorId,
    );
  }
}

class DashboardLookupOption {
  const DashboardLookupOption({
    required this.id,
    required this.label,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? subtitle;

  factory DashboardLookupOption.fromJson(JsonMap json) {
    return DashboardLookupOption(
      id: _stringOrNull(json['id']) ?? '',
      label: _stringOrNull(json['label']) ?? 'Unknown',
      subtitle: _stringOrNull(json['subtitle']),
    );
  }
}

class DashboardLookups {
  const DashboardLookups({
    this.semesters = const <DashboardLookupOption>[],
    this.departments = const <DashboardLookupOption>[],
    this.courses = const <DashboardLookupOption>[],
    this.instructors = const <DashboardLookupOption>[],
  });

  final List<DashboardLookupOption> semesters;
  final List<DashboardLookupOption> departments;
  final List<DashboardLookupOption> courses;
  final List<DashboardLookupOption> instructors;

  factory DashboardLookups.fromJson(JsonMap json) {
    return DashboardLookups(
      semesters: _decodeOptions(json['semesters']),
      departments: _decodeOptions(json['departments']),
      courses: _decodeOptions(json['courses']),
      instructors: _decodeOptions(json['instructors']),
    );
  }

  static List<DashboardLookupOption> _decodeOptions(dynamic value) {
    if (value is! List) {
      return const <DashboardLookupOption>[];
    }
    return value
        .whereType<JsonMap>()
        .map(DashboardLookupOption.fromJson)
        .toList(growable: false);
  }
}

class DashboardKpiMetric {
  const DashboardKpiMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.deltaLabel,
    required this.deltaValue,
    required this.progress,
    required this.tone,
    required this.direction,
    required this.caption,
  });

  final String id;
  final String label;
  final int value;
  final String deltaLabel;
  final double deltaValue;
  final double progress;
  final DashboardMetricTone tone;
  final DashboardTrendDirection direction;
  final String caption;

  factory DashboardKpiMetric.fromJson(JsonMap json) {
    return DashboardKpiMetric(
      id: _stringOrNull(json['id']) ?? 'metric',
      label: _stringOrNull(json['label']) ?? 'Metric',
      value: _intOrNull(json['value']) ?? 0,
      deltaLabel: _stringOrNull(json['delta_label']) ?? 'Stable',
      deltaValue: _doubleOrNull(json['delta_value']) ?? 0,
      progress: (_doubleOrNull(json['progress']) ?? 0).clamp(0, 1),
      tone: dashboardMetricToneFromValue(_stringOrNull(json['tone'])),
      direction: dashboardTrendDirectionFromValue(
        _stringOrNull(json['direction']),
      ),
      caption: _stringOrNull(json['caption']) ?? '',
    );
  }
}

class DashboardLinePoint {
  const DashboardLinePoint({required this.label, required this.value});

  final String label;
  final double value;

  factory DashboardLinePoint.fromJson(JsonMap json) {
    return DashboardLinePoint(
      label: _stringOrNull(json['label']) ?? '',
      value: _doubleOrNull(json['value']) ?? 0,
    );
  }
}

class DashboardBarPoint {
  const DashboardBarPoint({
    required this.label,
    required this.value,
    this.target,
  });

  final String label;
  final double value;
  final double? target;

  factory DashboardBarPoint.fromJson(JsonMap json) {
    return DashboardBarPoint(
      label: _stringOrNull(json['label']) ?? '',
      value: _doubleOrNull(json['value']) ?? 0,
      target: _doubleOrNull(json['target']),
    );
  }
}

class DashboardPieSlice {
  const DashboardPieSlice({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final double value;
  final DashboardMetricTone tone;

  factory DashboardPieSlice.fromJson(JsonMap json) {
    return DashboardPieSlice(
      label: _stringOrNull(json['label']) ?? '',
      value: _doubleOrNull(json['value']) ?? 0,
      tone: dashboardMetricToneFromValue(_stringOrNull(json['tone'])),
    );
  }
}

class DashboardActivityItem {
  const DashboardActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actorName,
    required this.timeLabel,
    required this.type,
    required this.highlighted,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actorName;
  final String timeLabel;
  final DashboardActivityType type;
  final bool highlighted;

  factory DashboardActivityItem.fromJson(JsonMap json) {
    return DashboardActivityItem(
      id: _stringOrNull(json['id']) ?? '',
      title: _stringOrNull(json['title']) ?? 'Activity',
      subtitle: _stringOrNull(json['subtitle']) ?? '',
      actorName: _stringOrNull(json['actor_name']) ?? 'System',
      timeLabel: _stringOrNull(json['time_label']) ?? 'Now',
      type: dashboardActivityTypeFromValue(_stringOrNull(json['type'])),
      highlighted: json['highlighted'] == true,
    );
  }
}

class DashboardModerationAlert {
  const DashboardModerationAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.scopeLabel,
    required this.flaggedCount,
    required this.severity,
  });

  final String id;
  final String title;
  final String subtitle;
  final String scopeLabel;
  final int flaggedCount;
  final DashboardAlertSeverity severity;

  factory DashboardModerationAlert.fromJson(JsonMap json) {
    return DashboardModerationAlert(
      id: _stringOrNull(json['id']) ?? '',
      title: _stringOrNull(json['title']) ?? 'Alert',
      subtitle: _stringOrNull(json['subtitle']) ?? '',
      scopeLabel: _stringOrNull(json['scope_label']) ?? '',
      flaggedCount: _intOrNull(json['flagged_count']) ?? 0,
      severity: dashboardAlertSeverityFromValue(
        _stringOrNull(json['severity']),
      ),
    );
  }
}

class DashboardScheduleItem {
  const DashboardScheduleItem({
    required this.id,
    required this.title,
    required this.dayLabel,
    required this.timeLabel,
    required this.location,
    required this.owner,
    required this.type,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final String dayLabel;
  final String timeLabel;
  final String location;
  final String owner;
  final DashboardScheduleType type;
  final String statusLabel;

  factory DashboardScheduleItem.fromJson(JsonMap json) {
    return DashboardScheduleItem(
      id: _stringOrNull(json['id']) ?? '',
      title: _stringOrNull(json['title']) ?? 'Schedule item',
      dayLabel: _stringOrNull(json['day_label']) ?? '',
      timeLabel: _stringOrNull(json['time_label']) ?? '',
      location: _stringOrNull(json['location']) ?? '',
      owner: _stringOrNull(json['owner']) ?? '',
      type: dashboardScheduleTypeFromValue(_stringOrNull(json['type'])),
      statusLabel: _stringOrNull(json['status_label']) ?? 'Scheduled',
    );
  }
}

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.route,
    this.enabled = true,
  });

  final String id;
  final String label;
  final String subtitle;
  final String route;
  final bool enabled;

  factory DashboardQuickAction.fromJson(JsonMap json) {
    return DashboardQuickAction(
      id: _stringOrNull(json['id']) ?? '',
      label: _stringOrNull(json['label']) ?? 'Action',
      subtitle: _stringOrNull(json['subtitle']) ?? '',
      route: _stringOrNull(json['route']) ?? '',
      enabled: json['enabled'] != false,
    );
  }
}

class DashboardBundle {
  const DashboardBundle({
    required this.filters,
    required this.lookups,
    required this.kpis,
    required this.enrollmentTrend,
    required this.studentDistribution,
    required this.attendanceOverview,
    required this.staffPerformance,
    required this.recentActivity,
    required this.moderationAlerts,
    required this.scheduleSummary,
    required this.quickActions,
    required this.isFallback,
    required this.sourceLabel,
    required this.refreshedAt,
  });

  final DashboardFilters filters;
  final DashboardLookups lookups;
  final List<DashboardKpiMetric> kpis;
  final List<DashboardLinePoint> enrollmentTrend;
  final List<DashboardPieSlice> studentDistribution;
  final List<DashboardBarPoint> attendanceOverview;
  final List<DashboardBarPoint> staffPerformance;
  final List<DashboardActivityItem> recentActivity;
  final List<DashboardModerationAlert> moderationAlerts;
  final List<DashboardScheduleItem> scheduleSummary;
  final List<DashboardQuickAction> quickActions;
  final bool isFallback;
  final String sourceLabel;
  final DateTime refreshedAt;

  bool get isEmpty =>
      kpis.isEmpty &&
      enrollmentTrend.isEmpty &&
      studentDistribution.isEmpty &&
      attendanceOverview.isEmpty &&
      staffPerformance.isEmpty &&
      recentActivity.isEmpty &&
      moderationAlerts.isEmpty &&
      scheduleSummary.isEmpty;

  factory DashboardBundle.fromJson(
    JsonMap json, {
    DashboardFilters fallbackFilters = const DashboardFilters(),
  }) {
    return DashboardBundle(
      filters: DashboardFilters.fromJson(
        _jsonMapOrEmpty(json['filters']),
        fallback: fallbackFilters,
      ),
      lookups: DashboardLookups.fromJson(_jsonMapOrEmpty(json['lookups'])),
      kpis: _decodeList(json['kpis'], DashboardKpiMetric.fromJson),
      enrollmentTrend: _decodeList(
        json['enrollment_trend'],
        DashboardLinePoint.fromJson,
      ),
      studentDistribution: _decodeList(
        json['student_distribution'],
        DashboardPieSlice.fromJson,
      ),
      attendanceOverview: _decodeList(
        json['attendance_overview'],
        DashboardBarPoint.fromJson,
      ),
      staffPerformance: _decodeList(
        json['staff_performance'],
        DashboardBarPoint.fromJson,
      ),
      recentActivity: _decodeList(
        json['recent_activity'],
        DashboardActivityItem.fromJson,
      ),
      moderationAlerts: _decodeList(
        json['moderation_alerts'],
        DashboardModerationAlert.fromJson,
      ),
      scheduleSummary: _decodeList(
        json['schedule_summary'],
        DashboardScheduleItem.fromJson,
      ),
      quickActions: _decodeList(
        json['quick_actions'],
        DashboardQuickAction.fromJson,
      ),
      isFallback: json['is_fallback'] == true,
      sourceLabel: _stringOrNull(json['source_label']) ?? 'Campus API',
      refreshedAt: _dateTimeOrNull(json['refreshed_at']) ?? DateTime.now(),
    );
  }

  static List<T> _decodeList<T>(
    dynamic value,
    T Function(JsonMap json) decoder,
  ) {
    if (value is! List) {
      return const <T>[];
    }
    return value.whereType<JsonMap>().map(decoder).toList(growable: false);
  }
}

String? _stringOrNull(dynamic value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty) {
    return null;
  }
  return text.trim();
}

int? _intOrNull(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _doubleOrNull(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value?.toString() ?? '');
}

JsonMap _jsonMapOrEmpty(dynamic value) {
  return value is JsonMap ? value : <String, dynamic>{};
}
