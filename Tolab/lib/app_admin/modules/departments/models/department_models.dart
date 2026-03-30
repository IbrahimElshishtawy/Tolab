import '../../../core/helpers/json_types.dart';

enum DepartmentDetailTab { overview, students, staff, subjects, schedule }

enum DepartmentSortField { name, studentsCount, subjectsCount }

enum DepartmentStatusFilter { all, active, inactive }

enum DepartmentDensityFilter { all, light, balanced, dense }

class DepartmentFilters {
  const DepartmentFilters({
    this.searchQuery = '',
    this.status = DepartmentStatusFilter.all,
    this.faculty,
    this.density = DepartmentDensityFilter.all,
  });

  final String searchQuery;
  final DepartmentStatusFilter status;
  final String? faculty;
  final DepartmentDensityFilter density;

  DepartmentFilters copyWith({
    String? searchQuery,
    DepartmentStatusFilter? status,
    String? faculty,
    bool clearFaculty = false,
    DepartmentDensityFilter? density,
  }) {
    return DepartmentFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      faculty: clearFaculty ? null : faculty ?? this.faculty,
      density: density ?? this.density,
    );
  }
}

class DepartmentsSort {
  const DepartmentsSort({
    this.field = DepartmentSortField.name,
    this.ascending = true,
  });

  final DepartmentSortField field;
  final bool ascending;

  DepartmentsSort copyWith({DepartmentSortField? field, bool? ascending}) {
    return DepartmentsSort(
      field: field ?? this.field,
      ascending: ascending ?? this.ascending,
    );
  }
}

class DepartmentsPagination {
  const DepartmentsPagination({this.page = 1, this.perPage = 6});

  final int page;
  final int perPage;

  DepartmentsPagination copyWith({int? page, int? perPage}) {
    return DepartmentsPagination(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

class DepartmentUpsertPayload {
  const DepartmentUpsertPayload({
    required this.name,
    required this.code,
    required this.description,
    required this.isActive,
    this.faculty,
  });

  final String name;
  final String code;
  final String description;
  final bool isActive;
  final String? faculty;

  JsonMap toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
      if (faculty != null) 'faculty': faculty,
    };
  }
}

class DepartmentMutationResult {
  const DepartmentMutationResult({
    required this.items,
    required this.message,
    this.selectedDepartmentId,
  });

  final List<DepartmentRecord> items;
  final String message;
  final String? selectedDepartmentId;
}

class DepartmentRecord {
  const DepartmentRecord({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.faculty,
    required this.headName,
    required this.coverImageUrl,
    required this.isActive,
    required this.isArchived,
    required this.studentsCount,
    required this.staffCount,
    required this.subjectsCount,
    required this.sectionsCount,
    required this.activeCoursesCount,
    required this.successRate,
    required this.createdAt,
    required this.updatedAt,
    required this.activityFeed,
    required this.schedulePreview,
    required this.studentDistribution,
    required this.subjectLoad,
    required this.staffUtilization,
    required this.performanceMetrics,
    required this.successTrend,
    required this.years,
    required this.students,
    required this.staff,
    required this.subjects,
    required this.courseOfferings,
    required this.permissions,
  });

  final String id;
  final String name;
  final String code;
  final String description;
  final String faculty;
  final String headName;
  final String coverImageUrl;
  final bool isActive;
  final bool isArchived;
  final int studentsCount;
  final int staffCount;
  final int subjectsCount;
  final int sectionsCount;
  final int activeCoursesCount;
  final double successRate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DepartmentActivityItem> activityFeed;
  final List<DepartmentScheduleItem> schedulePreview;
  final List<DepartmentChartPoint> studentDistribution;
  final List<DepartmentChartPoint> subjectLoad;
  final List<DepartmentChartPoint> staffUtilization;
  final List<DepartmentPerformanceMetric> performanceMetrics;
  final List<DepartmentChartPoint> successTrend;
  final List<DepartmentYearPlan> years;
  final List<DepartmentStudentRecord> students;
  final List<DepartmentStaffRecord> staff;
  final List<DepartmentSubjectRecord> subjects;
  final List<DepartmentCourseOfferingRecord> courseOfferings;
  final List<DepartmentPermissionRule> permissions;

  String get statusLabel {
    if (isArchived) {
      return 'Archived';
    }
    return isActive ? 'Active' : 'Inactive';
  }

  double get studentDensity =>
      sectionsCount == 0 ? 0 : studentsCount / sectionsCount;

  DepartmentRecord copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? faculty,
    String? headName,
    String? coverImageUrl,
    bool? isActive,
    bool? isArchived,
    int? studentsCount,
    int? staffCount,
    int? subjectsCount,
    int? sectionsCount,
    int? activeCoursesCount,
    double? successRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DepartmentActivityItem>? activityFeed,
    List<DepartmentScheduleItem>? schedulePreview,
    List<DepartmentChartPoint>? studentDistribution,
    List<DepartmentChartPoint>? subjectLoad,
    List<DepartmentChartPoint>? staffUtilization,
    List<DepartmentPerformanceMetric>? performanceMetrics,
    List<DepartmentChartPoint>? successTrend,
    List<DepartmentYearPlan>? years,
    List<DepartmentStudentRecord>? students,
    List<DepartmentStaffRecord>? staff,
    List<DepartmentSubjectRecord>? subjects,
    List<DepartmentCourseOfferingRecord>? courseOfferings,
    List<DepartmentPermissionRule>? permissions,
  }) {
    return DepartmentRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      faculty: faculty ?? this.faculty,
      headName: headName ?? this.headName,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      studentsCount: studentsCount ?? this.studentsCount,
      staffCount: staffCount ?? this.staffCount,
      subjectsCount: subjectsCount ?? this.subjectsCount,
      sectionsCount: sectionsCount ?? this.sectionsCount,
      activeCoursesCount: activeCoursesCount ?? this.activeCoursesCount,
      successRate: successRate ?? this.successRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activityFeed: activityFeed ?? this.activityFeed,
      schedulePreview: schedulePreview ?? this.schedulePreview,
      studentDistribution: studentDistribution ?? this.studentDistribution,
      subjectLoad: subjectLoad ?? this.subjectLoad,
      staffUtilization: staffUtilization ?? this.staffUtilization,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      successTrend: successTrend ?? this.successTrend,
      years: years ?? this.years,
      students: students ?? this.students,
      staff: staff ?? this.staff,
      subjects: subjects ?? this.subjects,
      courseOfferings: courseOfferings ?? this.courseOfferings,
      permissions: permissions ?? this.permissions,
    );
  }

  factory DepartmentRecord.fromJson(
    JsonMap json, {
    DepartmentRecord? fallback,
  }) {
    return DepartmentRecord(
      id: _stringValue(json, 'id', fallback?.id ?? ''),
      name: _stringValue(json, 'name', fallback?.name ?? ''),
      code: _stringValue(json, 'code', fallback?.code ?? ''),
      description: _stringValue(
        json,
        'description',
        fallback?.description ?? '',
      ),
      faculty: _stringValue(json, 'faculty', fallback?.faculty ?? 'General'),
      headName: _stringValue(json, 'head_name', fallback?.headName ?? 'TBA'),
      coverImageUrl: _stringValue(
        json,
        'cover_image_url',
        fallback?.coverImageUrl ?? '',
      ),
      isActive: _boolValue(json, 'is_active', fallback?.isActive ?? true),
      isArchived: _boolValue(
        json,
        'is_archived',
        fallback?.isArchived ?? false,
      ),
      studentsCount: _intValue(
        json,
        'students_count',
        fallback?.studentsCount ?? 0,
      ),
      staffCount: _intValue(json, 'staff_count', fallback?.staffCount ?? 0),
      subjectsCount: _intValue(
        json,
        'subjects_count',
        fallback?.subjectsCount ?? 0,
      ),
      sectionsCount: _intValue(
        json,
        'sections_count',
        fallback?.sectionsCount ?? 0,
      ),
      activeCoursesCount: _intValue(
        json,
        'active_courses_count',
        fallback?.activeCoursesCount ?? 0,
      ),
      successRate: _doubleValue(
        json,
        'success_rate',
        fallback?.successRate ?? 0,
      ),
      createdAt: _dateValue(json, 'created_at', fallback?.createdAt),
      updatedAt: _dateValue(json, 'updated_at', fallback?.updatedAt),
      activityFeed: _listValue(
        json,
        'activity_feed',
        fallback?.activityFeed,
        DepartmentActivityItem.fromJson,
      ),
      schedulePreview: _listValue(
        json,
        'schedule_preview',
        fallback?.schedulePreview,
        DepartmentScheduleItem.fromJson,
      ),
      studentDistribution: _listValue(
        json,
        'student_distribution',
        fallback?.studentDistribution,
        DepartmentChartPoint.fromJson,
      ),
      subjectLoad: _listValue(
        json,
        'subject_load',
        fallback?.subjectLoad,
        DepartmentChartPoint.fromJson,
      ),
      staffUtilization: _listValue(
        json,
        'staff_utilization',
        fallback?.staffUtilization,
        DepartmentChartPoint.fromJson,
      ),
      performanceMetrics: _listValue(
        json,
        'performance_metrics',
        fallback?.performanceMetrics,
        DepartmentPerformanceMetric.fromJson,
      ),
      successTrend: _listValue(
        json,
        'success_trend',
        fallback?.successTrend,
        DepartmentChartPoint.fromJson,
      ),
      years: _listValue(
        json,
        'years',
        fallback?.years,
        DepartmentYearPlan.fromJson,
      ),
      students: _listValue(
        json,
        'students',
        fallback?.students,
        DepartmentStudentRecord.fromJson,
      ),
      staff: _listValue(
        json,
        'staff',
        fallback?.staff,
        DepartmentStaffRecord.fromJson,
      ),
      subjects: _listValue(
        json,
        'subjects',
        fallback?.subjects,
        DepartmentSubjectRecord.fromJson,
      ),
      courseOfferings: _listValue(
        json,
        'course_offerings',
        fallback?.courseOfferings,
        DepartmentCourseOfferingRecord.fromJson,
      ),
      permissions: _listValue(
        json,
        'permissions',
        fallback?.permissions,
        DepartmentPermissionRule.fromJson,
      ),
    );
  }
}

class DepartmentActivityItem {
  const DepartmentActivityItem({
    required this.title,
    required this.subtitle,
    required this.timestampLabel,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String timestampLabel;
  final String tone;

  factory DepartmentActivityItem.fromJson(JsonMap json) {
    return DepartmentActivityItem(
      title: _stringValue(json, 'title', ''),
      subtitle: _stringValue(json, 'subtitle', ''),
      timestampLabel: _stringValue(json, 'timestamp_label', ''),
      tone: _stringValue(json, 'tone', 'neutral'),
    );
  }
}

class DepartmentScheduleItem {
  const DepartmentScheduleItem({
    required this.dayLabel,
    required this.slotLabel,
    required this.title,
    required this.location,
    required this.type,
    required this.staffName,
  });

  final String dayLabel;
  final String slotLabel;
  final String title;
  final String location;
  final String type;
  final String staffName;

  factory DepartmentScheduleItem.fromJson(JsonMap json) {
    return DepartmentScheduleItem(
      dayLabel: _stringValue(json, 'day_label', ''),
      slotLabel: _stringValue(json, 'slot_label', ''),
      title: _stringValue(json, 'title', ''),
      location: _stringValue(json, 'location', ''),
      type: _stringValue(json, 'type', ''),
      staffName: _stringValue(json, 'staff_name', ''),
    );
  }
}

class DepartmentChartPoint {
  const DepartmentChartPoint({required this.label, required this.value});

  final String label;
  final double value;

  factory DepartmentChartPoint.fromJson(JsonMap json) {
    return DepartmentChartPoint(
      label: _stringValue(json, 'label', ''),
      value: _doubleValue(json, 'value', 0),
    );
  }
}

class DepartmentPerformanceMetric {
  const DepartmentPerformanceMetric({
    required this.label,
    required this.valueLabel,
    required this.deltaLabel,
    required this.tone,
  });

  final String label;
  final String valueLabel;
  final String deltaLabel;
  final String tone;

  factory DepartmentPerformanceMetric.fromJson(JsonMap json) {
    return DepartmentPerformanceMetric(
      label: _stringValue(json, 'label', ''),
      valueLabel: _stringValue(json, 'value_label', ''),
      deltaLabel: _stringValue(json, 'delta_label', ''),
      tone: _stringValue(json, 'tone', 'neutral'),
    );
  }
}

class DepartmentYearPlan {
  const DepartmentYearPlan({
    required this.yearLabel,
    required this.sectionsCount,
    required this.studentsCount,
    required this.subjects,
  });

  final String yearLabel;
  final int sectionsCount;
  final int studentsCount;
  final List<DepartmentYearSubject> subjects;

  factory DepartmentYearPlan.fromJson(JsonMap json) {
    return DepartmentYearPlan(
      yearLabel: _stringValue(json, 'year_label', ''),
      sectionsCount: _intValue(json, 'sections_count', 0),
      studentsCount: _intValue(json, 'students_count', 0),
      subjects: _listValue(
        json,
        'subjects',
        null,
        DepartmentYearSubject.fromJson,
      ),
    );
  }
}

class DepartmentYearSubject {
  const DepartmentYearSubject({
    required this.code,
    required this.name,
    required this.creditHours,
    required this.overloaded,
  });

  final String code;
  final String name;
  final int creditHours;
  final bool overloaded;

  factory DepartmentYearSubject.fromJson(JsonMap json) {
    return DepartmentYearSubject(
      code: _stringValue(json, 'code', ''),
      name: _stringValue(json, 'name', ''),
      creditHours: _intValue(json, 'credit_hours', 0),
      overloaded: _boolValue(json, 'overloaded', false),
    );
  }
}

class DepartmentStudentRecord {
  const DepartmentStudentRecord({
    required this.id,
    required this.name,
    required this.yearLabel,
    required this.sectionLabel,
    required this.status,
    required this.gpa,
  });

  final String id;
  final String name;
  final String yearLabel;
  final String sectionLabel;
  final String status;
  final double gpa;

  factory DepartmentStudentRecord.fromJson(JsonMap json) {
    return DepartmentStudentRecord(
      id: _stringValue(json, 'id', ''),
      name: _stringValue(json, 'name', ''),
      yearLabel: _stringValue(json, 'year_label', ''),
      sectionLabel: _stringValue(json, 'section_label', ''),
      status: _stringValue(json, 'status', ''),
      gpa: _doubleValue(json, 'gpa', 0),
    );
  }
}

class DepartmentStaffRecord {
  const DepartmentStaffRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.utilization,
    required this.avatarUrl,
    required this.activeSubjects,
  });

  final String id;
  final String name;
  final String role;
  final String status;
  final double utilization;
  final String avatarUrl;
  final int activeSubjects;

  factory DepartmentStaffRecord.fromJson(JsonMap json) {
    return DepartmentStaffRecord(
      id: _stringValue(json, 'id', ''),
      name: _stringValue(json, 'name', ''),
      role: _stringValue(json, 'role', ''),
      status: _stringValue(json, 'status', ''),
      utilization: _doubleValue(json, 'utilization', 0),
      avatarUrl: _stringValue(json, 'avatar_url', ''),
      activeSubjects: _intValue(json, 'active_subjects', 0),
    );
  }
}

class DepartmentSubjectRecord {
  const DepartmentSubjectRecord({
    required this.id,
    required this.code,
    required this.name,
    required this.yearLabel,
    required this.semesterLabel,
    required this.enrolledStudents,
    required this.weeklyHours,
    required this.status,
  });

  final String id;
  final String code;
  final String name;
  final String yearLabel;
  final String semesterLabel;
  final int enrolledStudents;
  final int weeklyHours;
  final String status;

  bool get overloaded => weeklyHours >= 5 || enrolledStudents >= 180;

  factory DepartmentSubjectRecord.fromJson(JsonMap json) {
    return DepartmentSubjectRecord(
      id: _stringValue(json, 'id', ''),
      code: _stringValue(json, 'code', ''),
      name: _stringValue(json, 'name', ''),
      yearLabel: _stringValue(json, 'year_label', ''),
      semesterLabel: _stringValue(json, 'semester_label', ''),
      enrolledStudents: _intValue(json, 'enrolled_students', 0),
      weeklyHours: _intValue(json, 'weekly_hours', 0),
      status: _stringValue(json, 'status', ''),
    );
  }
}

class DepartmentCourseOfferingRecord {
  const DepartmentCourseOfferingRecord({
    required this.id,
    required this.subjectCode,
    required this.sectionLabel,
    required this.instructor,
    required this.scheduleLabel,
    required this.enrolled,
    required this.capacity,
    required this.status,
  });

  final String id;
  final String subjectCode;
  final String sectionLabel;
  final String instructor;
  final String scheduleLabel;
  final int enrolled;
  final int capacity;
  final String status;

  factory DepartmentCourseOfferingRecord.fromJson(JsonMap json) {
    return DepartmentCourseOfferingRecord(
      id: _stringValue(json, 'id', ''),
      subjectCode: _stringValue(json, 'subject_code', ''),
      sectionLabel: _stringValue(json, 'section_label', ''),
      instructor: _stringValue(json, 'instructor', ''),
      scheduleLabel: _stringValue(json, 'schedule_label', ''),
      enrolled: _intValue(json, 'enrolled', 0),
      capacity: _intValue(json, 'capacity', 0),
      status: _stringValue(json, 'status', ''),
    );
  }
}

class DepartmentPermissionRule {
  const DepartmentPermissionRule({
    required this.code,
    required this.title,
    required this.description,
    required this.granted,
  });

  final String code;
  final String title;
  final String description;
  final bool granted;

  factory DepartmentPermissionRule.fromJson(JsonMap json) {
    return DepartmentPermissionRule(
      code: _stringValue(json, 'code', ''),
      title: _stringValue(json, 'title', ''),
      description: _stringValue(json, 'description', ''),
      granted: _boolValue(json, 'granted', false),
    );
  }
}

extension DepartmentPermissionRuleListX on List<DepartmentPermissionRule> {
  bool allows(String code) {
    return any((rule) => rule.code == code && rule.granted);
  }
}

String _stringValue(JsonMap json, String key, String fallback) {
  final value =
      json[key] ?? json[_camelCase(key)] ?? json[key.replaceAll('_', '')];
  return value?.toString() ?? fallback;
}

bool _boolValue(JsonMap json, String key, bool fallback) {
  final value = json[key] ?? json[_camelCase(key)];
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'active') {
      return true;
    }
    if (lower == 'false' || lower == '0' || lower == 'inactive') {
      return false;
    }
  }
  return fallback;
}

int _intValue(JsonMap json, String key, int fallback) {
  final value = json[key] ?? json[_camelCase(key)];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _doubleValue(JsonMap json, String key, double fallback) {
  final value = json[key] ?? json[_camelCase(key)];
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime _dateValue(JsonMap json, String key, DateTime? fallback) {
  final value = json[key] ?? json[_camelCase(key)];
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  }
  return fallback ?? DateTime.now();
}

List<T> _listValue<T>(
  JsonMap json,
  String key,
  List<T>? fallback,
  T Function(JsonMap json) decoder,
) {
  final value = json[key] ?? json[_camelCase(key)];
  if (value is List) {
    return value.whereType<JsonMap>().map(decoder).toList(growable: false);
  }
  return fallback ?? <T>[];
}

String _camelCase(String key) {
  final segments = key.split('_');
  if (segments.isEmpty) {
    return key;
  }
  return segments.first +
      segments
          .skip(1)
          .map(
            (segment) => segment.isEmpty
                ? segment
                : '${segment[0].toUpperCase()}${segment.substring(1)}',
          )
          .join();
}
