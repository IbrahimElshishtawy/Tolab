import '../../../core/helpers/json_types.dart';

enum CourseOfferingStatus { draft, active, completed, cancelled }

enum CourseOfferingDetailsTab { overview, students, schedule, content, staff }

enum CourseOfferingQuickActionKind { lecture, upload, assignment, announcement }

CourseOfferingStatus courseOfferingStatusFromValue(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'active' || 'live' => CourseOfferingStatus.active,
    'completed' || 'closed' => CourseOfferingStatus.completed,
    'cancelled' || 'canceled' => CourseOfferingStatus.cancelled,
    _ => CourseOfferingStatus.draft,
  };
}

extension CourseOfferingStatusX on CourseOfferingStatus {
  String get label => switch (this) {
    CourseOfferingStatus.draft => 'Draft',
    CourseOfferingStatus.active => 'Active',
    CourseOfferingStatus.completed => 'Completed',
    CourseOfferingStatus.cancelled => 'Cancelled',
  };

  String get apiValue => switch (this) {
    CourseOfferingStatus.draft => 'draft',
    CourseOfferingStatus.active => 'active',
    CourseOfferingStatus.completed => 'completed',
    CourseOfferingStatus.cancelled => 'cancelled',
  };
}

extension CourseOfferingDetailsTabX on CourseOfferingDetailsTab {
  String get label => switch (this) {
    CourseOfferingDetailsTab.overview => 'Overview',
    CourseOfferingDetailsTab.students => 'Students',
    CourseOfferingDetailsTab.schedule => 'Schedule',
    CourseOfferingDetailsTab.content => 'Content',
    CourseOfferingDetailsTab.staff => 'Staff',
  };
}

class CourseOfferingLookupOption {
  const CourseOfferingLookupOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.group,
  });

  final String id;
  final String label;
  final String? subtitle;
  final String? group;
}

class CourseOfferingStaffMember {
  const CourseOfferingStaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.department,
  });

  final String id;
  final String name;
  final String role;
  final String email;
  final String department;

  factory CourseOfferingStaffMember.fromJson(
    JsonMap json, {
    required String role,
    String? department,
  }) {
    return CourseOfferingStaffMember(
      id: _stringOrFallback(json['id'], 'unknown-staff'),
      name:
          _stringOrNull(json['name']) ??
          _stringOrNull(json['full_name']) ??
          _stringOrNull(json['username']) ??
          'Unassigned',
      role: role,
      email:
          _stringOrNull(json['email']) ??
          '${_slugify(_stringOrNull(json['username']) ?? 'staff')}@tolab.edu',
      department: department ?? _stringOrNull(json['department']) ?? 'General',
    );
  }
}

class CourseOfferingStudent {
  const CourseOfferingStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.sectionName,
    required this.status,
    required this.enrolledAt,
  });

  final String id;
  final String name;
  final String email;
  final String sectionName;
  final String status;
  final DateTime enrolledAt;

  factory CourseOfferingStudent.fromJson(JsonMap json) {
    return CourseOfferingStudent(
      id: _stringOrFallback(json['id'], 'student'),
      name: _stringOrFallback(json['name'], 'Unknown student'),
      email: _stringOrFallback(json['email'], 'student@tolab.edu'),
      sectionName:
          _stringOrNull(json['section_name']) ??
          _stringOrNull(json['section']) ??
          'Section',
      status: _stringOrNull(json['status']) ?? 'Enrolled',
      enrolledAt: _readDate(json['enrolled_at'], DateTime.now()),
    );
  }
}

class CourseOfferingScheduleItem {
  const CourseOfferingScheduleItem({
    required this.id,
    required this.title,
    required this.dayLabel,
    required this.timeLabel,
    required this.location,
    required this.type,
    required this.status,
  });

  final String id;
  final String title;
  final String dayLabel;
  final String timeLabel;
  final String location;
  final String type;
  final String status;
}

class CourseOfferingQuickAction {
  const CourseOfferingQuickAction({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final CourseOfferingQuickActionKind kind;
  final String title;
  final String subtitle;
}

class CourseOfferingModel {
  const CourseOfferingModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.code,
    required this.departmentId,
    required this.departmentName,
    required this.sectionId,
    required this.sectionName,
    required this.doctor,
    required this.assistants,
    required this.semester,
    required this.academicYear,
    required this.capacity,
    required this.enrolledCount,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.students = const <CourseOfferingStudent>[],
    this.schedule = const <CourseOfferingScheduleItem>[],
    this.contentActions = const <CourseOfferingQuickAction>[],
  });

  final String id;
  final String subjectId;
  final String subjectName;
  final String code;
  final String departmentId;
  final String departmentName;
  final String sectionId;
  final String sectionName;
  final CourseOfferingStaffMember doctor;
  final List<CourseOfferingStaffMember> assistants;
  final String semester;
  final String academicYear;
  final int capacity;
  final int enrolledCount;
  final CourseOfferingStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final List<CourseOfferingStudent> students;
  final List<CourseOfferingScheduleItem> schedule;
  final List<CourseOfferingQuickAction> contentActions;

  double get fillRate {
    if (capacity <= 0) return 0;
    return enrolledCount / capacity;
  }

  int get seatsRemaining => capacity - enrolledCount;

  bool get isOverCapacity => enrolledCount > capacity;

  factory CourseOfferingModel.fromJson(
    JsonMap json, {
    CourseOfferingModel? fallback,
  }) {
    final subject = _mapOrNull(json['subject']);
    final section = _mapOrNull(json['section']);
    final doctorMap = _mapOrNull(json['doctor']);
    final taMap = _mapOrNull(json['ta']);
    final assistantsList = _mapListOrEmpty(json['assistants']);
    final subjectId =
        _stringOrNull(json['subject_id']) ??
        _stringOrNull(json['subjectId']) ??
        _stringOrNull(subject?['id']) ??
        fallback?.subjectId ??
        '';
    final departmentId =
        _stringOrNull(json['department_id']) ??
        _stringOrNull(json['departmentId']) ??
        fallback?.departmentId ??
        _slugify(
          _stringOrNull(json['department_name']) ??
              _stringOrNull(json['departmentName']) ??
              fallback?.departmentName ??
              'department',
        );

    return CourseOfferingModel(
      id: _stringOrFallback(json['id'], fallback?.id ?? 'offering'),
      subjectId: subjectId,
      subjectName:
          _stringOrNull(json['subject_name']) ??
          _stringOrNull(json['subjectName']) ??
          _stringOrNull(subject?['name']) ??
          fallback?.subjectName ??
          'Untitled subject',
      code:
          _stringOrNull(json['code']) ??
          _stringOrNull(subject?['code']) ??
          fallback?.code ??
          'SUBJ',
      departmentId: departmentId,
      departmentName:
          _stringOrNull(json['department_name']) ??
          _stringOrNull(json['departmentName']) ??
          fallback?.departmentName ??
          'Department',
      sectionId:
          _stringOrNull(json['section_id']) ??
          _stringOrNull(json['sectionId']) ??
          _stringOrNull(section?['id']) ??
          fallback?.sectionId ??
          '',
      sectionName:
          _stringOrNull(json['section_name']) ??
          _stringOrNull(json['sectionName']) ??
          _stringOrNull(section?['name']) ??
          fallback?.sectionName ??
          'Section',
      doctor: doctorMap != null
          ? CourseOfferingStaffMember.fromJson(
              doctorMap,
              role: 'Doctor',
              department: fallback?.departmentName,
            )
          : fallback?.doctor ??
                const CourseOfferingStaffMember(
                  id: 'doctor-unassigned',
                  name: 'Unassigned doctor',
                  role: 'Doctor',
                  email: 'doctor@tolab.edu',
                  department: 'General',
                ),
      assistants: assistantsList.isNotEmpty
          ? assistantsList
                .map(
                  (item) => CourseOfferingStaffMember.fromJson(
                    item,
                    role: 'Assistant',
                    department: fallback?.departmentName,
                  ),
                )
                .toList(growable: false)
          : taMap != null
          ? [
              CourseOfferingStaffMember.fromJson(
                taMap,
                role: 'Assistant',
                department: fallback?.departmentName,
              ),
            ]
          : fallback?.assistants ?? const <CourseOfferingStaffMember>[],
      semester:
          _stringOrNull(json['semester']) ?? fallback?.semester ?? 'Spring',
      academicYear:
          _stringOrNull(json['academic_year']) ??
          _stringOrNull(json['academicYear']) ??
          fallback?.academicYear ??
          '2025/2026',
      capacity: _readInt(json['capacity'], fallback: fallback?.capacity ?? 120),
      enrolledCount: _readInt(
        json['enrolled_count'] ?? json['enrolledCount'],
        fallback: fallback?.enrolledCount ?? 0,
      ),
      status: courseOfferingStatusFromValue(
        _stringOrNull(json['status']) ?? fallback?.status.apiValue,
      ),
      startDate: _readDate(
        json['start_date'] ?? json['startDate'],
        fallback?.startDate ?? DateTime.now(),
      ),
      endDate: _readDate(
        json['end_date'] ?? json['endDate'],
        fallback?.endDate ?? DateTime.now().add(const Duration(days: 90)),
      ),
      createdAt: _readDate(
        json['created_at'] ?? json['createdAt'],
        fallback?.createdAt ?? DateTime.now(),
      ),
      students: _mapListOrEmpty(
        json['students'],
      ).map(CourseOfferingStudent.fromJson).toList(growable: false),
      schedule: (_mapListOrEmpty(json['schedule']))
          .map(
            (item) => CourseOfferingScheduleItem(
              id: _stringOrFallback(item['id'], 'schedule'),
              title: _stringOrFallback(item['title'], 'Session'),
              dayLabel: _stringOrFallback(item['day_label'], 'Day'),
              timeLabel: _stringOrFallback(item['time_label'], 'Time'),
              location: _stringOrFallback(item['location'], 'TBA'),
              type: _stringOrFallback(item['type'], 'Class'),
              status: _stringOrFallback(item['status'], 'Planned'),
            ),
          )
          .toList(growable: false),
      contentActions:
          fallback?.contentActions ?? const <CourseOfferingQuickAction>[],
    );
  }

  CourseOfferingModel copyWith({
    String? id,
    String? subjectId,
    String? subjectName,
    String? code,
    String? departmentId,
    String? departmentName,
    String? sectionId,
    String? sectionName,
    CourseOfferingStaffMember? doctor,
    List<CourseOfferingStaffMember>? assistants,
    String? semester,
    String? academicYear,
    int? capacity,
    int? enrolledCount,
    CourseOfferingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    List<CourseOfferingStudent>? students,
    List<CourseOfferingScheduleItem>? schedule,
    List<CourseOfferingQuickAction>? contentActions,
  }) {
    return CourseOfferingModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
      doctor: doctor ?? this.doctor,
      assistants: List<CourseOfferingStaffMember>.unmodifiable(
        assistants ?? this.assistants,
      ),
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      capacity: capacity ?? this.capacity,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      students: List<CourseOfferingStudent>.unmodifiable(
        students ?? this.students,
      ),
      schedule: List<CourseOfferingScheduleItem>.unmodifiable(
        schedule ?? this.schedule,
      ),
      contentActions: List<CourseOfferingQuickAction>.unmodifiable(
        contentActions ?? this.contentActions,
      ),
    );
  }
}

class CourseOfferingUpsertPayload {
  const CourseOfferingUpsertPayload({
    required this.subjectId,
    required this.departmentId,
    required this.sectionId,
    required this.doctorId,
    required this.assistantIds,
    required this.semester,
    required this.academicYear,
    required this.capacity,
    required this.enrolledCount,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  final String subjectId;
  final String departmentId;
  final String sectionId;
  final String doctorId;
  final List<String> assistantIds;
  final String semester;
  final String academicYear;
  final int capacity;
  final int enrolledCount;
  final CourseOfferingStatus status;
  final DateTime startDate;
  final DateTime endDate;

  factory CourseOfferingUpsertPayload.fromOffering(
    CourseOfferingModel offering,
  ) {
    return CourseOfferingUpsertPayload(
      subjectId: offering.subjectId,
      departmentId: offering.departmentId,
      sectionId: offering.sectionId,
      doctorId: offering.doctor.id,
      assistantIds: offering.assistants.map((item) => item.id).toList(),
      semester: offering.semester,
      academicYear: offering.academicYear,
      capacity: offering.capacity,
      enrolledCount: offering.enrolledCount,
      status: offering.status,
      startDate: offering.startDate,
      endDate: offering.endDate,
    );
  }

  JsonMap toJson() {
    return <String, dynamic>{
      'subject_id': subjectId,
      'department_id': departmentId,
      'section_id': sectionId,
      'doctor_user_id': doctorId,
      'ta_user_id': assistantIds.isEmpty ? null : assistantIds.first,
      'assistant_user_ids': assistantIds,
      'semester': semester.toLowerCase(),
      'academic_year': academicYear,
      'capacity': capacity,
      'enrolled_count': enrolledCount,
      'status': status.apiValue,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}

class CourseOfferingsFilters {
  const CourseOfferingsFilters({
    this.searchQuery = '',
    this.semester,
    this.departmentId,
    this.status,
  });

  final String searchQuery;
  final String? semester;
  final String? departmentId;
  final CourseOfferingStatus? status;

  CourseOfferingsFilters copyWith({
    String? searchQuery,
    String? semester,
    bool clearSemester = false,
    String? departmentId,
    bool clearDepartmentId = false,
    CourseOfferingStatus? status,
    bool clearStatus = false,
  }) {
    return CourseOfferingsFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      semester: clearSemester ? null : semester ?? this.semester,
      departmentId: clearDepartmentId
          ? null
          : departmentId ?? this.departmentId,
      status: clearStatus ? null : status ?? this.status,
    );
  }
}

class CourseOfferingsPagination {
  const CourseOfferingsPagination({
    this.page = 1,
    this.perPage = 8,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;

  CourseOfferingsPagination copyWith({
    int? page,
    int? perPage,
    int? totalItems,
    int? totalPages,
  }) {
    return CourseOfferingsPagination(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class CourseOfferingsBundle {
  const CourseOfferingsBundle({
    required this.offerings,
    required this.subjects,
    required this.doctors,
    required this.assistants,
    required this.departments,
    required this.sections,
    required this.pagination,
  });

  final List<CourseOfferingModel> offerings;
  final List<CourseOfferingLookupOption> subjects;
  final List<CourseOfferingLookupOption> doctors;
  final List<CourseOfferingLookupOption> assistants;
  final List<CourseOfferingLookupOption> departments;
  final List<CourseOfferingLookupOption> sections;
  final CourseOfferingsPagination pagination;
}

class CourseOfferingMutationResult {
  const CourseOfferingMutationResult({
    required this.offerings,
    required this.pagination,
    required this.message,
    this.updatedOfferingId,
  });

  final List<CourseOfferingModel> offerings;
  final CourseOfferingsPagination pagination;
  final String message;
  final String? updatedOfferingId;
}

JsonMap? _mapOrNull(dynamic value) {
  return value is JsonMap ? value : null;
}

List<JsonMap> _mapListOrEmpty(dynamic value) {
  if (value is List) {
    return value.whereType<JsonMap>().toList(growable: false);
  }
  return const <JsonMap>[];
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime _readDate(dynamic value, DateTime fallback) {
  if (value is DateTime) return value;
  final parsed = DateTime.tryParse(value?.toString() ?? '');
  return parsed ?? fallback;
}

String? _stringOrNull(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}

String _stringOrFallback(dynamic value, String fallback) {
  return _stringOrNull(value) ?? fallback;
}

String _slugify(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
