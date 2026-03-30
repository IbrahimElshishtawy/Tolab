import 'dart:convert';

import 'package:intl/intl.dart';

import '../../../core/helpers/json_types.dart';

enum DashboardMetricTone { primary, info, success, warning, danger }

DashboardMetricTone dashboardMetricToneFromValue(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'info' => DashboardMetricTone.info,
    'success' => DashboardMetricTone.success,
    'warning' => DashboardMetricTone.warning,
    'danger' || 'critical' => DashboardMetricTone.danger,
    _ => DashboardMetricTone.primary,
  };
}

enum DashboardTimeRange {
  last7Days('7d', 'Last 7 days'),
  last30Days('30d', 'Last 30 days'),
  semester('semester', 'This semester');

  const DashboardTimeRange(this.backendValue, this.label);

  final String backendValue;
  final String label;

  static DashboardTimeRange fromValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      '7d' || 'last7days' => DashboardTimeRange.last7Days,
      'semester' || 'term' => DashboardTimeRange.semester,
      _ => DashboardTimeRange.last30Days,
    };
  }
}

enum DashboardSearchScope {
  all('All', null),
  student('Student', 'STUDENT'),
  doctor('Doctor', 'DOCTOR'),
  assistant('Assistant', 'TA');

  const DashboardSearchScope(this.label, this.backendRole);

  final String label;
  final String? backendRole;

  static DashboardSearchScope fromValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'student' || 'students' => DashboardSearchScope.student,
      'doctor' || 'doctors' => DashboardSearchScope.doctor,
      'assistant' || 'assistants' || 'ta' => DashboardSearchScope.assistant,
      _ => DashboardSearchScope.all,
    };
  }
}

enum DashboardDirectoryRole { student, doctor, assistant }

DashboardDirectoryRole dashboardDirectoryRoleFromValue(String? value) {
  return switch (value?.trim().toUpperCase()) {
    'DOCTOR' => DashboardDirectoryRole.doctor,
    'TA' || 'ASSISTANT' => DashboardDirectoryRole.assistant,
    _ => DashboardDirectoryRole.student,
  };
}

extension DashboardDirectoryRoleX on DashboardDirectoryRole {
  String get label => switch (this) {
    DashboardDirectoryRole.student => 'Student',
    DashboardDirectoryRole.doctor => 'Doctor',
    DashboardDirectoryRole.assistant => 'Assistant',
  };

  DashboardSearchScope get scope => switch (this) {
    DashboardDirectoryRole.student => DashboardSearchScope.student,
    DashboardDirectoryRole.doctor => DashboardSearchScope.doctor,
    DashboardDirectoryRole.assistant => DashboardSearchScope.assistant,
  };
}

enum DashboardActivityCategory {
  all('All activity'),
  registrations('Registrations'),
  uploads('Content uploads'),
  reviews('Review queue');

  const DashboardActivityCategory(this.label);

  final String label;
}

enum DashboardActivityType { registration, upload, review }

DashboardActivityType dashboardActivityTypeFromValue(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'upload' || 'uploads' || 'content' => DashboardActivityType.upload,
    'review' || 'reviews' || 'moderation' || 'message' =>
      DashboardActivityType.review,
    _ => DashboardActivityType.registration,
  };
}

extension DashboardActivityTypeX on DashboardActivityType {
  String get label => switch (this) {
    DashboardActivityType.registration => 'Registration',
    DashboardActivityType.upload => 'Upload',
    DashboardActivityType.review => 'Review',
  };

  DashboardActivityCategory get category => switch (this) {
    DashboardActivityType.registration =>
      DashboardActivityCategory.registrations,
    DashboardActivityType.upload => DashboardActivityCategory.uploads,
    DashboardActivityType.review => DashboardActivityCategory.reviews,
  };
}

class DashboardFilters {
  const DashboardFilters({
    this.timeRange = DashboardTimeRange.last30Days,
  });

  final DashboardTimeRange timeRange;

  DashboardFilters copyWith({DashboardTimeRange? timeRange}) {
    return DashboardFilters(timeRange: timeRange ?? this.timeRange);
  }

  Map<String, dynamic> toQueryParameters() => {
    'range': timeRange.backendValue,
  };

  factory DashboardFilters.fromJson(
    JsonMap json, {
    DashboardFilters fallback = const DashboardFilters(),
  }) {
    return DashboardFilters(
      timeRange: DashboardTimeRange.fromValue(
        _stringOrNull(json['range']) ?? fallback.timeRange.backendValue,
      ),
    );
  }
}

class DashboardStatCard {
  const DashboardStatCard({
    required this.id,
    required this.label,
    required this.value,
    required this.deltaLabel,
    required this.deltaValue,
    required this.caption,
    required this.tone,
  });

  final String id;
  final String label;
  final String value;
  final String deltaLabel;
  final double deltaValue;
  final String caption;
  final DashboardMetricTone tone;

  factory DashboardStatCard.fromJson(JsonMap json) {
    return DashboardStatCard(
      id: _stringOrNull(json['id']) ?? 'metric',
      label: _stringOrNull(json['label']) ?? 'Metric',
      value: _stringOrNull(json['value']) ?? '0',
      deltaLabel: _stringOrNull(json['delta_label']) ?? 'Stable',
      deltaValue: _doubleOrNull(json['delta_value']) ?? 0,
      caption: _stringOrNull(json['caption']) ?? '',
      tone: dashboardMetricToneFromValue(_stringOrNull(json['tone'])),
    );
  }
}

class DashboardTrendPoint {
  const DashboardTrendPoint({
    required this.label,
    required this.totalStudents,
    required this.activeCourses,
  });

  final String label;
  final double totalStudents;
  final double activeCourses;

  factory DashboardTrendPoint.fromJson(JsonMap json) {
    return DashboardTrendPoint(
      label: _stringOrNull(json['label']) ?? '',
      totalStudents: _doubleOrNull(
            json['students'] ?? json['total_students'] ?? json['value'],
          ) ??
          0,
      activeCourses:
          _doubleOrNull(json['courses'] ?? json['active_courses']) ?? 0,
    );
  }
}

class DashboardDepartmentStat {
  const DashboardDepartmentStat({
    required this.department,
    required this.enrollments,
    required this.tone,
  });

  final String department;
  final double enrollments;
  final DashboardMetricTone tone;

  factory DashboardDepartmentStat.fromJson(JsonMap json) {
    return DashboardDepartmentStat(
      department: _stringOrNull(
            json['department'] ?? json['label'] ?? json['name'],
          ) ??
          'Department',
      enrollments: _doubleOrNull(
            json['enrollments'] ?? json['value'] ?? json['count'],
          ) ??
          0,
      tone: dashboardMetricToneFromValue(_stringOrNull(json['tone'])),
    );
  }
}

class DashboardTaskSlice {
  const DashboardTaskSlice({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final double value;
  final DashboardMetricTone tone;

  factory DashboardTaskSlice.fromJson(JsonMap json) {
    return DashboardTaskSlice(
      label: _stringOrNull(json['label']) ?? 'Task',
      value: _doubleOrNull(json['value'] ?? json['count']) ?? 0,
      tone: dashboardMetricToneFromValue(_stringOrNull(json['tone'])),
    );
  }
}

class DashboardDirectoryEntry {
  const DashboardDirectoryEntry({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.departmentLabel,
    required this.statusLabel,
    required this.lastSeenLabel,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String displayName;
  final String email;
  final DashboardDirectoryRole role;
  final String departmentLabel;
  final String statusLabel;
  final String lastSeenLabel;
  final bool isActive;
  final DateTime createdAt;

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((segment) => segment.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'AD';
    }
    if (parts.length == 1) {
      final end = parts.first.length < 2 ? parts.first.length : 2;
      return parts.first.substring(0, end).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return displayName.toLowerCase().contains(normalized) ||
        email.toLowerCase().contains(normalized) ||
        role.label.toLowerCase().contains(normalized) ||
        departmentLabel.toLowerCase().contains(normalized) ||
        statusLabel.toLowerCase().contains(normalized);
  }

  bool matchesScope(DashboardSearchScope scope) {
    return scope == DashboardSearchScope.all || role.scope == scope;
  }

  factory DashboardDirectoryEntry.fromJson(JsonMap json) {
    final createdAt = _dateTimeOrNull(json['created_at']) ?? DateTime.now();
    final isActive = _boolOrNull(json['is_active']) ?? true;
    final department = _resolveDepartmentLabel(json);
    return DashboardDirectoryEntry(
      id:
          _stringOrNull(json['id']) ??
          _stringOrNull(json['user_id']) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      displayName:
          _stringOrNull(json['display_name']) ??
          _stringOrNull(json['name']) ??
          _stringOrNull(json['username']) ??
          'Academy User',
      email: _stringOrNull(json['email']) ?? 'no-email@tolab.edu',
      role: dashboardDirectoryRoleFromValue(_stringOrNull(json['role'])),
      departmentLabel: department,
      statusLabel: _stringOrNull(json['status_label']) ??
          (isActive ? 'Active' : 'Disabled'),
      lastSeenLabel: _stringOrNull(json['last_seen_label']) ??
          'Created ${DateFormat('d MMM').format(createdAt)}',
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

class DashboardActivityRow {
  const DashboardActivityRow({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.actor,
    required this.department,
    required this.statusLabel,
    required this.createdAt,
    required this.tone,
  });

  final String id;
  final DashboardActivityType type;
  final String title;
  final String subtitle;
  final String actor;
  final String department;
  final String statusLabel;
  final DateTime createdAt;
  final DashboardMetricTone tone;

  String get createdAtLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!createdAt.isBefore(today)) {
      return DateFormat('HH:mm').format(createdAt);
    }
    return DateFormat('d MMM, HH:mm').format(createdAt);
  }

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return title.toLowerCase().contains(normalized) ||
        subtitle.toLowerCase().contains(normalized) ||
        actor.toLowerCase().contains(normalized) ||
        department.toLowerCase().contains(normalized) ||
        statusLabel.toLowerCase().contains(normalized) ||
        type.label.toLowerCase().contains(normalized);
  }

  bool matchesCategory(DashboardActivityCategory category) {
    return category == DashboardActivityCategory.all ||
        type.category == category;
  }

  factory DashboardActivityRow.fromJson(JsonMap json) {
    return DashboardActivityRow(
      id:
          _stringOrNull(json['id']) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: dashboardActivityTypeFromValue(
        _stringOrNull(json['type'] ?? json['category']),
      ),
      title: _stringOrNull(json['title']) ?? 'Activity',
      subtitle: _stringOrNull(json['subtitle']) ?? '',
      actor: _stringOrNull(
            json['actor'] ?? json['actor_name'] ?? json['owner'],
          ) ??
          'System',
      department: _stringOrNull(
            json['department'] ?? json['department_label'],
          ) ??
          'Academy',
      statusLabel: _stringOrNull(json['status'] ?? json['status_label']) ??
          'Pending',
      createdAt: _dateTimeOrNull(json['created_at']) ?? DateTime.now(),
      tone: dashboardMetricToneFromValue(
        _stringOrNull(json['tone'] ?? json['severity']),
      ),
    );
  }
}

class DashboardAlertItem {
  const DashboardAlertItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.counterLabel,
    required this.tone,
  });

  final String id;
  final String title;
  final String subtitle;
  final String counterLabel;
  final DashboardMetricTone tone;

  factory DashboardAlertItem.fromJson(JsonMap json) {
    return DashboardAlertItem(
      id:
          _stringOrNull(json['id']) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _stringOrNull(json['title']) ?? 'Alert',
      subtitle: _stringOrNull(json['subtitle']) ?? '',
      counterLabel: _stringOrNull(json['counter_label'] ?? json['badge']) ??
          'Pending',
      tone: dashboardMetricToneFromValue(_stringOrNull(json['tone'])),
    );
  }
}

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.tone,
  });

  final String id;
  final String label;
  final String subtitle;
  final String route;
  final DashboardMetricTone tone;

  factory DashboardQuickAction.fromJson(JsonMap json) {
    return DashboardQuickAction(
      id: _stringOrNull(json['id']) ?? 'action',
      label: _stringOrNull(json['label']) ?? 'Action',
      subtitle: _stringOrNull(json['subtitle']) ?? '',
      route: _stringOrNull(json['route']) ?? '',
      tone: dashboardMetricToneFromValue(_stringOrNull(json['tone'])),
    );
  }
}

class DashboardBundle {
  const DashboardBundle({
    required this.filters,
    required this.stats,
    required this.trendPoints,
    required this.departmentStats,
    required this.taskBreakdown,
    required this.directoryEntries,
    required this.activityRows,
    required this.alerts,
    required this.quickActions,
    required this.sourceLabel,
    required this.refreshedAt,
    required this.isFallback,
  });

  final DashboardFilters filters;
  final List<DashboardStatCard> stats;
  final List<DashboardTrendPoint> trendPoints;
  final List<DashboardDepartmentStat> departmentStats;
  final List<DashboardTaskSlice> taskBreakdown;
  final List<DashboardDirectoryEntry> directoryEntries;
  final List<DashboardActivityRow> activityRows;
  final List<DashboardAlertItem> alerts;
  final List<DashboardQuickAction> quickActions;
  final String sourceLabel;
  final DateTime refreshedAt;
  final bool isFallback;

  bool get isEmpty =>
      stats.isEmpty &&
      trendPoints.isEmpty &&
      departmentStats.isEmpty &&
      taskBreakdown.isEmpty &&
      directoryEntries.isEmpty &&
      activityRows.isEmpty;

  List<DashboardDirectoryEntry> searchDirectory({
    required String query,
    required DashboardSearchScope scope,
    int limit = 8,
  }) {
    final matches = directoryEntries
        .where((entry) => entry.matchesScope(scope) && entry.matchesQuery(query))
        .take(limit)
        .toList(growable: false);
    return matches;
  }

  List<DashboardDirectoryEntry> get directoryPreview =>
      directoryEntries.take(8).toList(growable: false);

  factory DashboardBundle.fromJson(
    JsonMap json, {
    DashboardFilters fallbackFilters = const DashboardFilters(),
  }) {
    return DashboardBundle(
      filters: DashboardFilters.fromJson(
        _jsonMapOrEmpty(json['filters']),
        fallback: fallbackFilters,
      ),
      stats: _decodeList(
        json['stats'] ?? json['kpis'],
        DashboardStatCard.fromJson,
      ),
      trendPoints: _decodeList(
        json['trend'] ?? json['students_courses_trend'],
        DashboardTrendPoint.fromJson,
      ),
      departmentStats: _decodeList(
        json['department_enrollments'] ?? json['departments'],
        DashboardDepartmentStat.fromJson,
      ),
      taskBreakdown: _decodeList(
        json['pending_breakdown'] ?? json['tasks'],
        DashboardTaskSlice.fromJson,
      ),
      directoryEntries: _decodeList(
        json['directory'] ?? json['search_index'] ?? json['people'],
        DashboardDirectoryEntry.fromJson,
      ),
      activityRows: _decodeList(
        json['activity'] ?? json['recent_activity'],
        DashboardActivityRow.fromJson,
      ),
      alerts: _decodeList(json['alerts'], DashboardAlertItem.fromJson),
      quickActions: _decodeList(
        json['quick_actions'],
        DashboardQuickAction.fromJson,
      ),
      sourceLabel: _stringOrNull(json['source_label']) ?? 'Academy API',
      refreshedAt: _dateTimeOrNull(json['refreshed_at']) ?? DateTime.now(),
      isFallback: json['is_fallback'] == true,
    );
  }

  static List<T> _decodeList<T>(
    dynamic value,
    T Function(JsonMap json) decoder,
  ) {
    final resolved = switch (value) {
      List<dynamic>() => value,
      JsonMap() when value['data'] is List<dynamic> =>
        value['data'] as List<dynamic>,
      JsonMap() when value['items'] is List<dynamic> =>
        value['items'] as List<dynamic>,
      _ => const <dynamic>[],
    };
    return resolved
        .whereType<JsonMap>()
        .map(decoder)
        .toList(growable: false);
  }
}

class DashboardRealtimeSignal {
  const DashboardRealtimeSignal({
    required this.type,
    required this.source,
    required this.receivedAt,
  });

  final String type;
  final String source;
  final DateTime receivedAt;

  factory DashboardRealtimeSignal.heartbeat(String source) {
    return DashboardRealtimeSignal(
      type: 'heartbeat',
      source: source,
      receivedAt: DateTime.now(),
    );
  }

  static DashboardRealtimeSignal? fromSocketEvent(dynamic event) {
    final payload = _mapFromEvent(event);
    if (payload == null) return null;
    return DashboardRealtimeSignal(
      type: _stringOrNull(payload['type']) ?? 'dashboard.updated',
      source: _stringOrNull(payload['source']) ?? 'socket',
      receivedAt: _dateTimeOrNull(payload['timestamp']) ?? DateTime.now(),
    );
  }

  static JsonMap? _mapFromEvent(dynamic event) {
    if (event is JsonMap) return event;
    if (event is String && event.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(event);
        if (decoded is JsonMap) {
          return decoded['event'] is JsonMap
              ? Map<String, dynamic>.from(decoded['event'] as JsonMap)
              : decoded;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

String? _stringOrNull(dynamic value) {
  final text = value?.toString();
  if (text == null || text.trim().isEmpty) {
    return null;
  }
  return text.trim();
}

double? _doubleOrNull(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value is DateTime) return value.toLocal();
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value)?.toLocal();
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
  }
  return null;
}

bool? _boolOrNull(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return null;
}

String _resolveDepartmentLabel(JsonMap json) {
  final directLabel = _stringOrNull(
    json['department_label'] ?? json['department'] ?? json['department_name'],
  );
  if (directLabel != null) {
    return directLabel;
  }

  final studentProfile =
      json['student_profile'] is JsonMap ? json['student_profile'] as JsonMap : null;
  final staffProfile =
      json['staff_profile'] is JsonMap ? json['staff_profile'] as JsonMap : null;
  final fromProfiles = _stringOrNull(
    studentProfile?['department_label'] ??
        staffProfile?['department_label'] ??
        studentProfile?['department_name'] ??
        staffProfile?['department_name'],
  );
  if (fromProfiles != null) {
    return fromProfiles;
  }

  final departmentId = _stringOrNull(
    studentProfile?['department_id'] ?? staffProfile?['department_id'],
  );
  if (departmentId != null) {
    return 'Department #$departmentId';
  }
  return 'General Administration';
}

JsonMap _jsonMapOrEmpty(dynamic value) {
  return value is JsonMap ? value : <String, dynamic>{};
}
