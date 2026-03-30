import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/helpers/json_types.dart';

enum EnrollmentStatus { enrolled, pending, rejected }

enum EnrollmentSortField {
  studentName,
  studentId,
  course,
  section,
  semester,
  year,
  status,
  updatedAt,
}

enum EnrollmentMutationType { created, updated, deleted, bulkUploaded }

class EnrollmentStatusX {
  static EnrollmentStatus fromJson(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return switch (normalized) {
      'enrolled' || 'approved' || 'active' => EnrollmentStatus.enrolled,
      'pending' || 'queued' => EnrollmentStatus.pending,
      'rejected' || 'cancelled' || 'declined' => EnrollmentStatus.rejected,
      _ => EnrollmentStatus.pending,
    };
  }
}

extension EnrollmentStatusUi on EnrollmentStatus {
  String get label => switch (this) {
    EnrollmentStatus.enrolled => 'Enrolled',
    EnrollmentStatus.pending => 'Pending',
    EnrollmentStatus.rejected => 'Rejected',
  };

  String get apiValue => label.toLowerCase();

  Color get color => switch (this) {
    EnrollmentStatus.enrolled => AppColors.secondary,
    EnrollmentStatus.pending => AppColors.warning,
    EnrollmentStatus.rejected => AppColors.danger,
  };
}

extension EnrollmentSortFieldUi on EnrollmentSortField {
  String get label => switch (this) {
    EnrollmentSortField.studentName => 'Student name',
    EnrollmentSortField.studentId => 'Student ID',
    EnrollmentSortField.course => 'Course',
    EnrollmentSortField.section => 'Section',
    EnrollmentSortField.semester => 'Semester',
    EnrollmentSortField.year => 'Year',
    EnrollmentSortField.status => 'Status',
    EnrollmentSortField.updatedAt => 'Updated',
  };

  String get apiValue => switch (this) {
    EnrollmentSortField.studentName => 'student_name',
    EnrollmentSortField.studentId => 'student_id',
    EnrollmentSortField.course => 'course',
    EnrollmentSortField.section => 'section',
    EnrollmentSortField.semester => 'semester',
    EnrollmentSortField.year => 'year',
    EnrollmentSortField.status => 'status',
    EnrollmentSortField.updatedAt => 'updated_at',
  };
}

class EnrollmentRecord {
  const EnrollmentRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.courseOfferingId,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.sectionId,
    required this.sectionName,
    required this.departmentName,
    required this.semester,
    required this.academicYear,
    required this.status,
    required this.doctorId,
    required this.doctorName,
    required this.assistantId,
    required this.assistantName,
    required this.sectionCapacity,
    required this.sectionOccupancy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String courseOfferingId;
  final String courseId;
  final String courseCode;
  final String courseName;
  final String sectionId;
  final String sectionName;
  final String departmentName;
  final String semester;
  final String academicYear;
  final EnrollmentStatus status;
  final String doctorId;
  final String doctorName;
  final String assistantId;
  final String assistantName;
  final int sectionCapacity;
  final int sectionOccupancy;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get compositeCourseLabel => '$courseCode • $courseName';

  double get occupancyRate =>
      sectionCapacity == 0 ? 0 : sectionOccupancy / sectionCapacity;

  EnrollmentRecord copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? courseOfferingId,
    String? courseId,
    String? courseCode,
    String? courseName,
    String? sectionId,
    String? sectionName,
    String? departmentName,
    String? semester,
    String? academicYear,
    EnrollmentStatus? status,
    String? doctorId,
    String? doctorName,
    String? assistantId,
    String? assistantName,
    int? sectionCapacity,
    int? sectionOccupancy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnrollmentRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      courseOfferingId: courseOfferingId ?? this.courseOfferingId,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
      departmentName: departmentName ?? this.departmentName,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      status: status ?? this.status,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      assistantId: assistantId ?? this.assistantId,
      assistantName: assistantName ?? this.assistantName,
      sectionCapacity: sectionCapacity ?? this.sectionCapacity,
      sectionOccupancy: sectionOccupancy ?? this.sectionOccupancy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory EnrollmentRecord.fromJson(JsonMap json) {
    final student = _mapOf(json['student']);
    final course = _mapOf(json['course']);
    final section = _mapOf(json['section']);
    final doctor = _mapOf(json['doctor']);
    final assistant = _mapOf(json['assistant']);

    final courseCode =
        _stringOf(course['code']) ??
        _stringOf(json['course_code']) ??
        _stringOf(json['subject_code']) ??
        'COURSE';
    final courseName =
        _stringOf(course['name']) ??
        _stringOf(json['course_name']) ??
        _stringOf(json['subject_name']) ??
        'Untitled course';
    final sectionCapacity =
        _intOf(section['capacity']) ??
        _intOf(json['section_capacity']) ??
        _intOf(json['capacity']) ??
        0;
    final sectionOccupancy =
        _intOf(section['occupancy']) ??
        _intOf(json['section_occupancy']) ??
        _intOf(json['occupancy']) ??
        0;

    return EnrollmentRecord(
      id: _stringOf(json['id']) ?? '',
      studentId:
          _stringOf(student['id']) ??
          _stringOf(json['student_id']) ??
          _stringOf(json['student_user_id']) ??
          '',
      studentName:
          _stringOf(student['name']) ??
          _stringOf(student['username']) ??
          _stringOf(json['student_name']) ??
          'Student',
      studentEmail:
          _stringOf(student['email']) ?? _stringOf(json['student_email']) ?? '',
      courseOfferingId:
          _stringOf(json['course_offering_id']) ??
          _stringOf(course['offering_id']) ??
          _stringOf(course['id']) ??
          '',
      courseId:
          _stringOf(course['id']) ?? _stringOf(json['course_id']) ?? courseCode,
      courseCode: courseCode,
      courseName: courseName,
      sectionId:
          _stringOf(section['id']) ??
          _stringOf(json['section_id']) ??
          _stringOf(json['section']) ??
          '',
      sectionName:
          _stringOf(section['name']) ??
          _stringOf(json['section_name']) ??
          _stringOf(json['section']) ??
          'Section',
      departmentName:
          _stringOf(json['department_name']) ??
          _stringOf(section['department_name']) ??
          _stringOf(course['department_name']) ??
          'Department',
      semester:
          _stringOf(json['semester']) ??
          _stringOf(course['semester']) ??
          'Spring',
      academicYear:
          _stringOf(json['academic_year']) ??
          _stringOf(json['year']) ??
          _stringOf(course['academic_year']) ??
          '2025/2026',
      status: EnrollmentStatusX.fromJson(json['status']),
      doctorId:
          _stringOf(doctor['id']) ??
          _stringOf(json['doctor_id']) ??
          _stringOf(json['responsible_doctor_id']) ??
          '',
      doctorName:
          _stringOf(doctor['name']) ??
          _stringOf(doctor['username']) ??
          _stringOf(json['doctor_name']) ??
          _stringOf(json['responsible_doctor_name']) ??
          'Doctor',
      assistantId:
          _stringOf(assistant['id']) ??
          _stringOf(json['assistant_id']) ??
          _stringOf(json['responsible_assistant_id']) ??
          '',
      assistantName:
          _stringOf(assistant['name']) ??
          _stringOf(assistant['username']) ??
          _stringOf(json['assistant_name']) ??
          _stringOf(json['responsible_assistant_name']) ??
          'Assistant',
      sectionCapacity: sectionCapacity,
      sectionOccupancy: sectionOccupancy,
      createdAt:
          DateTime.tryParse(_stringOf(json['created_at']) ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(_stringOf(json['updated_at']) ?? '') ??
          DateTime.now(),
    );
  }

  JsonMap toJson() {
    return <String, dynamic>{
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'student_email': studentEmail,
      'course_offering_id': courseOfferingId,
      'course_id': courseId,
      'course_code': courseCode,
      'course_name': courseName,
      'section_id': sectionId,
      'section_name': sectionName,
      'department_name': departmentName,
      'semester': semester,
      'academic_year': academicYear,
      'status': status.apiValue,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'assistant_id': assistantId,
      'assistant_name': assistantName,
      'section_capacity': sectionCapacity,
      'section_occupancy': sectionOccupancy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class EnrollmentStudentOption {
  const EnrollmentStudentOption({
    required this.id,
    required this.name,
    required this.email,
    required this.departmentName,
    required this.sectionName,
    required this.levelLabel,
  });

  final String id;
  final String name;
  final String email;
  final String departmentName;
  final String sectionName;
  final String levelLabel;

  factory EnrollmentStudentOption.fromJson(JsonMap json) {
    return EnrollmentStudentOption(
      id: _stringOf(json['id']) ?? '',
      name: _stringOf(json['name']) ?? _stringOf(json['username']) ?? 'Student',
      email: _stringOf(json['email']) ?? '',
      departmentName:
          _stringOf(json['department_name']) ??
          _stringOf(json['department']) ??
          'Department',
      sectionName:
          _stringOf(json['section_name']) ??
          _stringOf(json['section']) ??
          'Section',
      levelLabel:
          _stringOf(json['level_label']) ?? _stringOf(json['level']) ?? 'Level',
    );
  }
}

class EnrollmentStaffOption {
  const EnrollmentStaffOption({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.departmentName,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String departmentName;

  factory EnrollmentStaffOption.fromJson(JsonMap json) {
    return EnrollmentStaffOption(
      id: _stringOf(json['id']) ?? '',
      name: _stringOf(json['name']) ?? _stringOf(json['username']) ?? 'Staff',
      email: _stringOf(json['email']) ?? '',
      role: _stringOf(json['role']) ?? 'Doctor',
      departmentName:
          _stringOf(json['department_name']) ??
          _stringOf(json['department']) ??
          'Department',
    );
  }
}

class EnrollmentOfferingOption {
  const EnrollmentOfferingOption({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.sectionId,
    required this.sectionName,
    required this.departmentName,
    required this.semester,
    required this.academicYear,
    required this.doctorId,
    required this.doctorName,
    required this.assistantId,
    required this.assistantName,
    required this.capacity,
    required this.occupancy,
  });

  final String id;
  final String courseId;
  final String courseCode;
  final String courseName;
  final String sectionId;
  final String sectionName;
  final String departmentName;
  final String semester;
  final String academicYear;
  final String doctorId;
  final String doctorName;
  final String assistantId;
  final String assistantName;
  final int capacity;
  final int occupancy;

  String get courseLabel => '$courseCode • $courseName';

  double get occupancyRate => capacity == 0 ? 0 : occupancy / capacity;

  factory EnrollmentOfferingOption.fromJson(JsonMap json) {
    final course = _mapOf(json['course']);
    final section = _mapOf(json['section']);
    final doctor = _mapOf(json['doctor']);
    final assistant = _mapOf(json['assistant']);
    return EnrollmentOfferingOption(
      id: _stringOf(json['id']) ?? _stringOf(json['course_offering_id']) ?? '',
      courseId:
          _stringOf(course['id']) ??
          _stringOf(json['course_id']) ??
          _stringOf(json['subject_id']) ??
          '',
      courseCode:
          _stringOf(course['code']) ??
          _stringOf(json['course_code']) ??
          _stringOf(json['subject_code']) ??
          'COURSE',
      courseName:
          _stringOf(course['name']) ??
          _stringOf(json['course_name']) ??
          _stringOf(json['subject_name']) ??
          'Untitled course',
      sectionId:
          _stringOf(section['id']) ?? _stringOf(json['section_id']) ?? '',
      sectionName:
          _stringOf(section['name']) ??
          _stringOf(json['section_name']) ??
          'Section',
      departmentName:
          _stringOf(json['department_name']) ??
          _stringOf(section['department_name']) ??
          _stringOf(course['department_name']) ??
          'Department',
      semester:
          _stringOf(json['semester']) ??
          _stringOf(course['semester']) ??
          'Spring',
      academicYear:
          _stringOf(json['academic_year']) ??
          _stringOf(json['year']) ??
          '2025/2026',
      doctorId: _stringOf(doctor['id']) ?? _stringOf(json['doctor_id']) ?? '',
      doctorName:
          _stringOf(doctor['name']) ??
          _stringOf(doctor['username']) ??
          _stringOf(json['doctor_name']) ??
          'Doctor',
      assistantId:
          _stringOf(assistant['id']) ?? _stringOf(json['assistant_id']) ?? '',
      assistantName:
          _stringOf(assistant['name']) ??
          _stringOf(assistant['username']) ??
          _stringOf(json['assistant_name']) ??
          'Assistant',
      capacity:
          _intOf(json['capacity']) ??
          _intOf(section['capacity']) ??
          _intOf(json['section_capacity']) ??
          0,
      occupancy:
          _intOf(json['occupancy']) ??
          _intOf(section['occupancy']) ??
          _intOf(json['section_occupancy']) ??
          0,
    );
  }
}

class EnrollmentLookupBundle {
  const EnrollmentLookupBundle({
    this.students = const <EnrollmentStudentOption>[],
    this.offerings = const <EnrollmentOfferingOption>[],
    this.doctors = const <EnrollmentStaffOption>[],
    this.assistants = const <EnrollmentStaffOption>[],
    this.semesters = const <String>[],
    this.academicYears = const <String>[],
  });

  final List<EnrollmentStudentOption> students;
  final List<EnrollmentOfferingOption> offerings;
  final List<EnrollmentStaffOption> doctors;
  final List<EnrollmentStaffOption> assistants;
  final List<String> semesters;
  final List<String> academicYears;

  factory EnrollmentLookupBundle.fromJson(JsonMap json) {
    return EnrollmentLookupBundle(
      students: _listOfMaps(
        json['students'],
      ).map(EnrollmentStudentOption.fromJson).toList(growable: false),
      offerings: _listOfMaps(
        json['offerings'],
      ).map(EnrollmentOfferingOption.fromJson).toList(growable: false),
      doctors: _listOfMaps(
        json['doctors'],
      ).map(EnrollmentStaffOption.fromJson).toList(growable: false),
      assistants: _listOfMaps(
        json['assistants'],
      ).map(EnrollmentStaffOption.fromJson).toList(growable: false),
      semesters: _listOfStrings(json['semesters']),
      academicYears: _listOfStrings(json['academic_years']),
    );
  }

  EnrollmentLookupBundle copyWith({
    List<EnrollmentStudentOption>? students,
    List<EnrollmentOfferingOption>? offerings,
    List<EnrollmentStaffOption>? doctors,
    List<EnrollmentStaffOption>? assistants,
    List<String>? semesters,
    List<String>? academicYears,
  }) {
    return EnrollmentLookupBundle(
      students: List<EnrollmentStudentOption>.unmodifiable(
        students ?? this.students,
      ),
      offerings: List<EnrollmentOfferingOption>.unmodifiable(
        offerings ?? this.offerings,
      ),
      doctors: List<EnrollmentStaffOption>.unmodifiable(
        doctors ?? this.doctors,
      ),
      assistants: List<EnrollmentStaffOption>.unmodifiable(
        assistants ?? this.assistants,
      ),
      semesters: List<String>.unmodifiable(semesters ?? this.semesters),
      academicYears: List<String>.unmodifiable(
        academicYears ?? this.academicYears,
      ),
    );
  }
}

class EnrollmentStatusSlice {
  const EnrollmentStatusSlice({required this.status, required this.count});

  final EnrollmentStatus status;
  final int count;
}

class EnrollmentCourseSummary {
  const EnrollmentCourseSummary({
    required this.courseLabel,
    required this.enrolledCount,
    required this.pendingCount,
    required this.rejectedCount,
  });

  final String courseLabel;
  final int enrolledCount;
  final int pendingCount;
  final int rejectedCount;

  int get total => enrolledCount + pendingCount + rejectedCount;
}

class EnrollmentSectionSummary {
  const EnrollmentSectionSummary({
    required this.sectionName,
    required this.courseLabel,
    required this.occupied,
    required this.capacity,
  });

  final String sectionName;
  final String courseLabel;
  final int occupied;
  final int capacity;

  double get progress => capacity == 0 ? 0 : occupied / capacity;
}

class EnrollmentDashboardSummary {
  const EnrollmentDashboardSummary({
    required this.totalEnrollments,
    required this.enrolledCount,
    required this.pendingCount,
    required this.rejectedCount,
    required this.averageOccupancy,
    required this.courseSummary,
    required this.sectionSummary,
    required this.statusBreakdown,
  });

  final int totalEnrollments;
  final int enrolledCount;
  final int pendingCount;
  final int rejectedCount;
  final double averageOccupancy;
  final List<EnrollmentCourseSummary> courseSummary;
  final List<EnrollmentSectionSummary> sectionSummary;
  final List<EnrollmentStatusSlice> statusBreakdown;

  factory EnrollmentDashboardSummary.empty() {
    return const EnrollmentDashboardSummary(
      totalEnrollments: 0,
      enrolledCount: 0,
      pendingCount: 0,
      rejectedCount: 0,
      averageOccupancy: 0,
      courseSummary: <EnrollmentCourseSummary>[],
      sectionSummary: <EnrollmentSectionSummary>[],
      statusBreakdown: <EnrollmentStatusSlice>[
        EnrollmentStatusSlice(status: EnrollmentStatus.enrolled, count: 0),
        EnrollmentStatusSlice(status: EnrollmentStatus.pending, count: 0),
        EnrollmentStatusSlice(status: EnrollmentStatus.rejected, count: 0),
      ],
    );
  }
}

class EnrollmentsFilters {
  const EnrollmentsFilters({
    this.searchQuery = '',
    this.status,
    this.courseId,
    this.sectionId,
    this.semester,
    this.academicYear,
    this.staffId,
  });

  final String searchQuery;
  final EnrollmentStatus? status;
  final String? courseId;
  final String? sectionId;
  final String? semester;
  final String? academicYear;
  final String? staffId;

  bool get isEmpty =>
      searchQuery.trim().isEmpty &&
      status == null &&
      courseId == null &&
      sectionId == null &&
      semester == null &&
      academicYear == null &&
      staffId == null;

  EnrollmentsFilters copyWith({
    String? searchQuery,
    EnrollmentStatus? status,
    bool clearStatus = false,
    String? courseId,
    bool clearCourseId = false,
    String? sectionId,
    bool clearSectionId = false,
    String? semester,
    bool clearSemester = false,
    String? academicYear,
    bool clearAcademicYear = false,
    String? staffId,
    bool clearStaffId = false,
  }) {
    return EnrollmentsFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      status: clearStatus ? null : status ?? this.status,
      courseId: clearCourseId ? null : courseId ?? this.courseId,
      sectionId: clearSectionId ? null : sectionId ?? this.sectionId,
      semester: clearSemester ? null : semester ?? this.semester,
      academicYear: clearAcademicYear
          ? null
          : academicYear ?? this.academicYear,
      staffId: clearStaffId ? null : staffId ?? this.staffId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EnrollmentsFilters &&
        other.searchQuery == searchQuery &&
        other.status == status &&
        other.courseId == courseId &&
        other.sectionId == sectionId &&
        other.semester == semester &&
        other.academicYear == academicYear &&
        other.staffId == staffId;
  }

  @override
  int get hashCode => Object.hash(
    searchQuery,
    status,
    courseId,
    sectionId,
    semester,
    academicYear,
    staffId,
  );
}

class EnrollmentsSort {
  const EnrollmentsSort({
    this.field = EnrollmentSortField.updatedAt,
    this.ascending = false,
  });

  final EnrollmentSortField field;
  final bool ascending;

  EnrollmentsSort copyWith({EnrollmentSortField? field, bool? ascending}) {
    return EnrollmentsSort(
      field: field ?? this.field,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EnrollmentsSort &&
        other.field == field &&
        other.ascending == ascending;
  }

  @override
  int get hashCode => Object.hash(field, ascending);
}

class EnrollmentsPagination {
  const EnrollmentsPagination({
    this.page = 1,
    this.perPage = 10,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;

  EnrollmentsPagination copyWith({
    int? page,
    int? perPage,
    int? totalItems,
    int? totalPages,
  }) {
    return EnrollmentsPagination(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EnrollmentsPagination &&
        other.page == page &&
        other.perPage == perPage &&
        other.totalItems == totalItems &&
        other.totalPages == totalPages;
  }

  @override
  int get hashCode => Object.hash(page, perPage, totalItems, totalPages);
}

class EnrollmentUpsertPayload {
  const EnrollmentUpsertPayload({
    required this.studentId,
    required this.courseOfferingId,
    required this.courseId,
    required this.sectionId,
    required this.semester,
    required this.academicYear,
    required this.status,
    required this.doctorId,
    required this.assistantId,
  });

  final String studentId;
  final String courseOfferingId;
  final String courseId;
  final String sectionId;
  final String semester;
  final String academicYear;
  final EnrollmentStatus status;
  final String doctorId;
  final String assistantId;

  JsonMap toJson() {
    return <String, dynamic>{
      'student_user_id': _intOrString(studentId),
      'course_offering_id': _intOrString(courseOfferingId),
      'course_id': courseId,
      'section_id': sectionId,
      'semester': semester,
      'academic_year': academicYear,
      'status': status.apiValue,
      'doctor_user_id': _intOrString(doctorId),
      'assistant_user_id': _intOrString(assistantId),
    };
  }
}

class EnrollmentMutationResult {
  const EnrollmentMutationResult({
    required this.items,
    required this.pagination,
    required this.summary,
    required this.message,
    required this.type,
    this.highlightEnrollmentId,
  });

  final List<EnrollmentRecord> items;
  final EnrollmentsPagination pagination;
  final EnrollmentDashboardSummary summary;
  final String message;
  final EnrollmentMutationType type;
  final String? highlightEnrollmentId;
}

class EnrollmentsBundle {
  const EnrollmentsBundle({
    required this.items,
    required this.pagination,
    required this.lookups,
    required this.summary,
  });

  final List<EnrollmentRecord> items;
  final EnrollmentsPagination pagination;
  final EnrollmentLookupBundle lookups;
  final EnrollmentDashboardSummary summary;
}

class EnrollmentBulkRowDraft {
  const EnrollmentBulkRowDraft({
    required this.rowNumber,
    required this.source,
    required this.previewStudent,
    required this.previewCourse,
    required this.previewSection,
    required this.previewSemester,
    required this.previewAcademicYear,
    required this.previewStatus,
    required this.errors,
    this.payload,
  });

  final int rowNumber;
  final Map<String, String> source;
  final String previewStudent;
  final String previewCourse;
  final String previewSection;
  final String previewSemester;
  final String previewAcademicYear;
  final String previewStatus;
  final List<String> errors;
  final EnrollmentUpsertPayload? payload;

  bool get isValid => errors.isEmpty && payload != null;
}

class EnrollmentBulkPreview {
  const EnrollmentBulkPreview({
    required this.fileName,
    required this.rows,
    required this.generatedAt,
  });

  final String fileName;
  final List<EnrollmentBulkRowDraft> rows;
  final DateTime generatedAt;

  int get validCount => rows.where((row) => row.isValid).length;
  int get invalidCount => rows.length - validCount;

  List<EnrollmentUpsertPayload> get validPayloads => rows
      .map((row) => row.payload)
      .whereType<EnrollmentUpsertPayload>()
      .toList(growable: false);
}

EnrollmentDashboardSummary buildEnrollmentSummary(
  List<EnrollmentRecord> items,
  List<EnrollmentOfferingOption> offerings,
) {
  if (items.isEmpty) return EnrollmentDashboardSummary.empty();

  final enrolledCount = items
      .where((item) => item.status == EnrollmentStatus.enrolled)
      .length;
  final pendingCount = items
      .where((item) => item.status == EnrollmentStatus.pending)
      .length;
  final rejectedCount = items
      .where((item) => item.status == EnrollmentStatus.rejected)
      .length;

  final courseMap = <String, List<EnrollmentRecord>>{};
  final sectionMap = <String, List<EnrollmentRecord>>{};
  for (final item in items) {
    courseMap
        .putIfAbsent(item.compositeCourseLabel, () => <EnrollmentRecord>[])
        .add(item);
    sectionMap
        .putIfAbsent(item.sectionId, () => <EnrollmentRecord>[])
        .add(item);
  }

  final courseSummary =
      courseMap.entries
          .map((entry) {
            final records = entry.value;
            return EnrollmentCourseSummary(
              courseLabel: entry.key,
              enrolledCount: records
                  .where((item) => item.status == EnrollmentStatus.enrolled)
                  .length,
              pendingCount: records
                  .where((item) => item.status == EnrollmentStatus.pending)
                  .length,
              rejectedCount: records
                  .where((item) => item.status == EnrollmentStatus.rejected)
                  .length,
            );
          })
          .toList(growable: false)
        ..sort((a, b) => b.total.compareTo(a.total));

  final sectionSummary =
      sectionMap.entries
          .map((entry) {
            final sample = entry.value.first;
            final offering = offerings.firstWhere(
              (item) =>
                  item.sectionId == sample.sectionId &&
                  item.courseId == sample.courseId,
              orElse: () => EnrollmentOfferingOption(
                id: sample.courseOfferingId,
                courseId: sample.courseId,
                courseCode: sample.courseCode,
                courseName: sample.courseName,
                sectionId: sample.sectionId,
                sectionName: sample.sectionName,
                departmentName: sample.departmentName,
                semester: sample.semester,
                academicYear: sample.academicYear,
                doctorId: sample.doctorId,
                doctorName: sample.doctorName,
                assistantId: sample.assistantId,
                assistantName: sample.assistantName,
                capacity: sample.sectionCapacity,
                occupancy: sample.sectionOccupancy,
              ),
            );
            return EnrollmentSectionSummary(
              sectionName: sample.sectionName,
              courseLabel: sample.compositeCourseLabel,
              occupied: math.max(
                offering.occupancy,
                entry.value
                    .where((item) => item.status != EnrollmentStatus.rejected)
                    .length,
              ),
              capacity: math.max(offering.capacity, sample.sectionCapacity),
            );
          })
          .toList(growable: false)
        ..sort((a, b) => b.progress.compareTo(a.progress));

  final averageOccupancy = sectionSummary.isEmpty
      ? 0.0
      : sectionSummary.fold<double>(0, (sum, item) => sum + item.progress) /
            sectionSummary.length;

  return EnrollmentDashboardSummary(
    totalEnrollments: items.length,
    enrolledCount: enrolledCount,
    pendingCount: pendingCount,
    rejectedCount: rejectedCount,
    averageOccupancy: averageOccupancy,
    courseSummary: courseSummary,
    sectionSummary: sectionSummary,
    statusBreakdown: <EnrollmentStatusSlice>[
      EnrollmentStatusSlice(
        status: EnrollmentStatus.enrolled,
        count: enrolledCount,
      ),
      EnrollmentStatusSlice(
        status: EnrollmentStatus.pending,
        count: pendingCount,
      ),
      EnrollmentStatusSlice(
        status: EnrollmentStatus.rejected,
        count: rejectedCount,
      ),
    ],
  );
}

JsonMap _mapOf(dynamic value) {
  if (value is JsonMap) return value;
  return const <String, dynamic>{};
}

List<JsonMap> _listOfMaps(dynamic value) {
  if (value is List) {
    return value.whereType<JsonMap>().toList(growable: false);
  }
  return const <JsonMap>[];
}

List<String> _listOfStrings(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }
  return const <String>[];
}

String? _stringOf(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return text;
}

int? _intOf(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '');
}

dynamic _intOrString(String value) {
  return int.tryParse(value) ?? value;
}
