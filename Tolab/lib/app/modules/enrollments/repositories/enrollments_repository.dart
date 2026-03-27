import 'dart:math' as math;

import '../../../core/errors/app_exception.dart';
import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/staff_member.dart';
import '../../../shared/models/student.dart';
import '../models/enrollment_models.dart';
import '../services/enrollments_api.dart';

class EnrollmentsRepository {
  EnrollmentsRepository(this._api, this._demoDataService);

  final EnrollmentsApi _api;
  final DemoDataService _demoDataService;

  List<EnrollmentRecord>? _cache;
  EnrollmentLookupBundle? _lookups;

  Future<EnrollmentsBundle> fetchEnrollments({
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) async {
    _ensureSeeded();

    try {
      final remote = await _api.fetchEnrollments(
        filters: filters,
        sort: sort,
        pagination: pagination.copyWith(page: 1, perPage: 250),
      );
      if (remote.items.isNotEmpty) {
        _cache = remote.items;
      }
      if (remote.lookups.offerings.isNotEmpty ||
          remote.lookups.students.isNotEmpty ||
          remote.lookups.doctors.isNotEmpty ||
          remote.lookups.assistants.isNotEmpty) {
        _lookups = _mergeLookups(remote.lookups);
      }
      if (_cache != null && _lookups != null) {
        return _buildBundle(
          items: _cache!,
          filters: filters,
          sort: sort,
          pagination: pagination,
        );
      }
    } catch (_) {}

    return _buildBundle(
      items: _cache!,
      filters: filters,
      sort: sort,
      pagination: pagination,
    );
  }

  Future<EnrollmentMutationResult> createEnrollment({
    required EnrollmentUpsertPayload payload,
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) async {
    _ensureSeeded();
    final local = _materializePayload(
      payload,
      id: 'ENR-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    try {
      final remote = await _api.createEnrollment(payload);
      _cache = [remote, ..._cache!];
    } catch (_) {
      _cache = [local, ..._cache!];
    }
    _refreshLookupOccupancy();
    return _mutationResult(
      message: 'Enrollment created successfully.',
      type: EnrollmentMutationType.created,
      highlightEnrollmentId: _cache!.first.id,
      filters: filters,
      sort: sort,
      pagination: pagination,
    );
  }

  Future<EnrollmentMutationResult> updateEnrollment({
    required String enrollmentId,
    required EnrollmentUpsertPayload payload,
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) async {
    _ensureSeeded();
    final current = _cache!.firstWhere(
      (item) => item.id == enrollmentId,
      orElse: () =>
          throw AppException('The selected enrollment could not be found.'),
    );
    final local = _materializePayload(
      payload,
      id: current.id,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    try {
      final remote = await _api.updateEnrollment(enrollmentId, payload);
      _replaceItem(remote);
    } catch (_) {
      _replaceItem(local);
    }
    _refreshLookupOccupancy();
    return _mutationResult(
      message: 'Enrollment updated successfully.',
      type: EnrollmentMutationType.updated,
      highlightEnrollmentId: enrollmentId,
      filters: filters,
      sort: sort,
      pagination: pagination,
    );
  }

  Future<EnrollmentMutationResult> updateEnrollmentStatus({
    required EnrollmentRecord record,
    required EnrollmentStatus status,
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) {
    return updateEnrollment(
      enrollmentId: record.id,
      payload: EnrollmentUpsertPayload(
        studentId: record.studentId,
        courseOfferingId: record.courseOfferingId,
        courseId: record.courseId,
        sectionId: record.sectionId,
        semester: record.semester,
        academicYear: record.academicYear,
        status: status,
        doctorId: record.doctorId,
        assistantId: record.assistantId,
      ),
      filters: filters,
      sort: sort,
      pagination: pagination,
    );
  }

  Future<EnrollmentMutationResult> deleteEnrollment({
    required String enrollmentId,
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) async {
    _ensureSeeded();
    _cache = _cache!
        .where((item) => item.id != enrollmentId)
        .toList(growable: false);
    try {
      await _api.deleteEnrollment(enrollmentId);
    } catch (_) {}
    _refreshLookupOccupancy();
    return _mutationResult(
      message: 'Enrollment deleted successfully.',
      type: EnrollmentMutationType.deleted,
      filters: filters,
      sort: sort,
      pagination: pagination,
    );
  }

  Future<EnrollmentMutationResult> bulkUpload({
    required List<EnrollmentUpsertPayload> payloads,
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) async {
    _ensureSeeded();
    final now = DateTime.now();
    final seeded = payloads
        .asMap()
        .entries
        .map(
          (entry) => _materializePayload(
            entry.value,
            id: 'ENR-${now.microsecondsSinceEpoch}-${entry.key}',
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);
    try {
      final remote = await _api.bulkUpload(payloads);
      _cache = [...remote, ..._cache!];
    } catch (_) {
      _cache = [...seeded, ..._cache!];
    }
    _refreshLookupOccupancy();
    return _mutationResult(
      message: '${payloads.length} enrollments imported successfully.',
      type: EnrollmentMutationType.bulkUploaded,
      filters: filters,
      sort: sort,
      pagination: pagination,
    );
  }

  EnrollmentsBundle _buildBundle({
    required List<EnrollmentRecord> items,
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
  }) {
    final filtered = _applyFilters(items, filters);
    final ordered = _applySort(filtered, sort);
    final totalPages = ordered.isEmpty
        ? 1
        : (ordered.length / pagination.perPage).ceil();
    final resolvedPage = math.min(pagination.page, totalPages);
    final start = math.max(0, (resolvedPage - 1) * pagination.perPage);
    final end = math.min(ordered.length, start + pagination.perPage);
    final visible = ordered.sublist(start, end);
    final lookups = _lookups!;
    return EnrollmentsBundle(
      items: List<EnrollmentRecord>.unmodifiable(visible),
      pagination: pagination.copyWith(
        page: resolvedPage,
        totalItems: ordered.length,
        totalPages: totalPages,
      ),
      lookups: lookups,
      summary: buildEnrollmentSummary(_cache!, lookups.offerings),
    );
  }

  EnrollmentMutationResult _mutationResult({
    required String message,
    required EnrollmentMutationType type,
    required EnrollmentsFilters filters,
    required EnrollmentsSort sort,
    required EnrollmentsPagination pagination,
    String? highlightEnrollmentId,
  }) {
    final filtered = _applyFilters(_cache!, filters);
    final ordered = _applySort(filtered, sort);
    final totalPages = ordered.isEmpty
        ? 1
        : (ordered.length / pagination.perPage).ceil();
    return EnrollmentMutationResult(
      items: List<EnrollmentRecord>.unmodifiable(ordered),
      pagination: pagination.copyWith(
        totalItems: ordered.length,
        totalPages: totalPages,
        page: math.min(pagination.page, totalPages),
      ),
      summary: buildEnrollmentSummary(_cache!, _lookups!.offerings),
      message: message,
      type: type,
      highlightEnrollmentId: highlightEnrollmentId,
    );
  }

  void _ensureSeeded() {
    _lookups ??= _seedLookups();
    _cache ??= _seedEnrollments(_lookups!);
    _refreshLookupOccupancy();
  }

  EnrollmentLookupBundle _seedLookups() {
    final students = _demoDataService
        .students()
        .map(
          (Student student) => EnrollmentStudentOption(
            id: student.id,
            name: student.name,
            email: student.email,
            departmentName: student.department,
            sectionName: student.section,
            levelLabel: student.level,
          ),
        )
        .toList(growable: false);

    final staff = _demoDataService.staff();
    final doctors = staff
        .where((member) => member.title.toLowerCase() == 'doctor')
        .map(_mapStaff)
        .toList(growable: false);
    final assistants = staff
        .where((member) => member.title.toLowerCase() == 'assistant')
        .map(_mapStaff)
        .toList(growable: false);

    final subjects = _demoDataService
        .subjects()
        .take(6)
        .toList(growable: false);
    final sectionCycle =
        students.map((item) => item.sectionName).toSet().toList()..sort();
    final offerings = List<EnrollmentOfferingOption>.generate(subjects.length, (
      index,
    ) {
      final subject = subjects[index];
      final sectionName = sectionCycle[index % sectionCycle.length];
      final sectionId = 'SEC-${index + 1}';
      final doctor = doctors.firstWhere(
        (member) => member.name == subject.doctor.name,
        orElse: () => doctors[index % math.max(doctors.length, 1)],
      );
      final assistant = assistants.isEmpty
          ? const EnrollmentStaffOption(
              id: '',
              name: 'Assistant',
              email: '',
              role: 'Assistant',
              departmentName: 'Department',
            )
          : assistants.firstWhere(
              (member) => member.name == subject.assistant.name,
              orElse: () => assistants[index % assistants.length],
            );
      final capacity = math.max(subject.eligibleStudents, 28 + (index * 4));
      final occupancy = math.min(capacity - 1, 18 + (index * 5));
      return EnrollmentOfferingOption(
        id: 'OFF-${index + 1}',
        courseId: subject.id,
        courseCode: subject.code,
        courseName: subject.name,
        sectionId: sectionId,
        sectionName: sectionName,
        departmentName: subject.department,
        semester: _semesterForIndex(index),
        academicYear: subject.academicYear,
        doctorId: doctor.id,
        doctorName: doctor.name,
        assistantId: assistant.id,
        assistantName: assistant.name,
        capacity: capacity,
        occupancy: occupancy,
      );
    });

    final semesters = {for (final item in offerings) item.semester}.toList()
      ..sort();
    final academicYears = {
      for (final item in offerings) item.academicYear,
    }.toList()..sort();

    return EnrollmentLookupBundle(
      students: students,
      offerings: offerings,
      doctors: doctors,
      assistants: assistants,
      semesters: semesters,
      academicYears: academicYears,
    );
  }

  List<EnrollmentRecord> _seedEnrollments(EnrollmentLookupBundle lookups) {
    const statuses = <EnrollmentStatus>[
      EnrollmentStatus.enrolled,
      EnrollmentStatus.pending,
      EnrollmentStatus.enrolled,
      EnrollmentStatus.rejected,
      EnrollmentStatus.enrolled,
      EnrollmentStatus.pending,
      EnrollmentStatus.enrolled,
      EnrollmentStatus.enrolled,
    ];
    final records = <EnrollmentRecord>[];
    for (var index = 0; index < 14; index++) {
      final student = lookups.students[index % lookups.students.length];
      final offering = lookups.offerings[index % lookups.offerings.length];
      final timestamp = DateTime(2026, 1 + (index % 2), 5 + index);
      records.add(
        EnrollmentRecord(
          id: 'ENR-${index + 1}',
          studentId: student.id,
          studentName: student.name,
          studentEmail: student.email,
          courseOfferingId: offering.id,
          courseId: offering.courseId,
          courseCode: offering.courseCode,
          courseName: offering.courseName,
          sectionId: offering.sectionId,
          sectionName: offering.sectionName,
          departmentName: offering.departmentName,
          semester: offering.semester,
          academicYear: offering.academicYear,
          status: statuses[index % statuses.length],
          doctorId: offering.doctorId,
          doctorName: offering.doctorName,
          assistantId: offering.assistantId,
          assistantName: offering.assistantName,
          sectionCapacity: offering.capacity,
          sectionOccupancy: offering.occupancy,
          createdAt: timestamp,
          updatedAt: timestamp.add(Duration(hours: 4 + index)),
        ),
      );
    }
    return List<EnrollmentRecord>.unmodifiable(records);
  }

  List<EnrollmentRecord> _applyFilters(
    List<EnrollmentRecord> items,
    EnrollmentsFilters filters,
  ) {
    final query = filters.searchQuery.trim().toLowerCase();
    return items
        .where((item) {
          final matchesQuery =
              query.isEmpty ||
              item.studentName.toLowerCase().contains(query) ||
              item.studentId.toLowerCase().contains(query) ||
              item.courseName.toLowerCase().contains(query) ||
              item.courseCode.toLowerCase().contains(query) ||
              item.sectionName.toLowerCase().contains(query) ||
              item.doctorName.toLowerCase().contains(query) ||
              item.assistantName.toLowerCase().contains(query);
          final matchesStatus =
              filters.status == null || item.status == filters.status;
          final matchesCourse =
              filters.courseId == null || item.courseId == filters.courseId;
          final matchesSection =
              filters.sectionId == null || item.sectionId == filters.sectionId;
          final matchesSemester =
              filters.semester == null ||
              item.semester.toLowerCase() == filters.semester!.toLowerCase();
          final matchesYear =
              filters.academicYear == null ||
              item.academicYear == filters.academicYear;
          final matchesStaff =
              filters.staffId == null ||
              item.doctorId == filters.staffId ||
              item.assistantId == filters.staffId;
          return matchesQuery &&
              matchesStatus &&
              matchesCourse &&
              matchesSection &&
              matchesSemester &&
              matchesYear &&
              matchesStaff;
        })
        .toList(growable: false);
  }

  List<EnrollmentRecord> _applySort(
    List<EnrollmentRecord> items,
    EnrollmentsSort sort,
  ) {
    final ordered = List<EnrollmentRecord>.from(items);
    int compare(Comparable<Object> left, Comparable<Object> right) {
      return left.compareTo(right);
    }

    ordered.sort((a, b) {
      final result = switch (sort.field) {
        EnrollmentSortField.studentName => compare(
          a.studentName,
          b.studentName,
        ),
        EnrollmentSortField.studentId => compare(a.studentId, b.studentId),
        EnrollmentSortField.course => compare(a.courseName, b.courseName),
        EnrollmentSortField.section => compare(a.sectionName, b.sectionName),
        EnrollmentSortField.semester => compare(a.semester, b.semester),
        EnrollmentSortField.year => compare(a.academicYear, b.academicYear),
        EnrollmentSortField.status => compare(a.status.index, b.status.index),
        EnrollmentSortField.updatedAt => compare(a.updatedAt, b.updatedAt),
      };
      return sort.ascending ? result : -result;
    });
    return List<EnrollmentRecord>.unmodifiable(ordered);
  }

  EnrollmentRecord _materializePayload(
    EnrollmentUpsertPayload payload, {
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final student = _lookups!.students.firstWhere(
      (item) => item.id == payload.studentId,
      orElse: () => const EnrollmentStudentOption(
        id: '',
        name: 'Student',
        email: '',
        departmentName: 'Department',
        sectionName: 'Section',
        levelLabel: 'Level',
      ),
    );
    final offering = _lookups!.offerings.firstWhere(
      (item) => item.id == payload.courseOfferingId,
      orElse: () => _lookups!.offerings.firstWhere(
        (item) =>
            item.courseId == payload.courseId &&
            item.sectionId == payload.sectionId &&
            item.semester == payload.semester &&
            item.academicYear == payload.academicYear,
        orElse: () => throw AppException(
          'The selected course offering could not be resolved.',
        ),
      ),
    );
    final doctor = _lookups!.doctors.firstWhere(
      (item) => item.id == payload.doctorId,
      orElse: () => EnrollmentStaffOption(
        id: payload.doctorId,
        name: offering.doctorName,
        email: '',
        role: 'Doctor',
        departmentName: offering.departmentName,
      ),
    );
    final assistant = _lookups!.assistants.firstWhere(
      (item) => item.id == payload.assistantId,
      orElse: () => EnrollmentStaffOption(
        id: payload.assistantId,
        name: offering.assistantName,
        email: '',
        role: 'Assistant',
        departmentName: offering.departmentName,
      ),
    );
    return EnrollmentRecord(
      id: id,
      studentId: student.id,
      studentName: student.name,
      studentEmail: student.email,
      courseOfferingId: offering.id,
      courseId: offering.courseId,
      courseCode: offering.courseCode,
      courseName: offering.courseName,
      sectionId: offering.sectionId,
      sectionName: offering.sectionName,
      departmentName: offering.departmentName,
      semester: payload.semester,
      academicYear: payload.academicYear,
      status: payload.status,
      doctorId: doctor.id,
      doctorName: doctor.name,
      assistantId: assistant.id,
      assistantName: assistant.name,
      sectionCapacity: offering.capacity,
      sectionOccupancy: offering.occupancy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  EnrollmentLookupBundle _mergeLookups(EnrollmentLookupBundle remote) {
    final current = _lookups ?? const EnrollmentLookupBundle();
    return current.copyWith(
      students: remote.students.isEmpty ? current.students : remote.students,
      offerings: remote.offerings.isEmpty
          ? current.offerings
          : remote.offerings,
      doctors: remote.doctors.isEmpty ? current.doctors : remote.doctors,
      assistants: remote.assistants.isEmpty
          ? current.assistants
          : remote.assistants,
      semesters: remote.semesters.isEmpty
          ? current.semesters
          : remote.semesters,
      academicYears: remote.academicYears.isEmpty
          ? current.academicYears
          : remote.academicYears,
    );
  }

  void _replaceItem(EnrollmentRecord record) {
    _cache = [
      for (final item in _cache!)
        if (item.id == record.id) record else item,
    ];
  }

  void _refreshLookupOccupancy() {
    if (_lookups == null || _cache == null) return;
    final occupancyByOffering = <String, int>{};
    for (final item in _cache!) {
      if (item.status == EnrollmentStatus.rejected) continue;
      occupancyByOffering.update(
        item.courseOfferingId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    _lookups = _lookups!.copyWith(
      offerings: _lookups!.offerings
          .map((offering) {
            final occupancy =
                occupancyByOffering[offering.id] ?? offering.occupancy;
            return EnrollmentOfferingOption(
              id: offering.id,
              courseId: offering.courseId,
              courseCode: offering.courseCode,
              courseName: offering.courseName,
              sectionId: offering.sectionId,
              sectionName: offering.sectionName,
              departmentName: offering.departmentName,
              semester: offering.semester,
              academicYear: offering.academicYear,
              doctorId: offering.doctorId,
              doctorName: offering.doctorName,
              assistantId: offering.assistantId,
              assistantName: offering.assistantName,
              capacity: offering.capacity,
              occupancy: occupancy,
            );
          })
          .toList(growable: false),
    );
  }

  EnrollmentStaffOption _mapStaff(StaffMember staff) {
    return EnrollmentStaffOption(
      id: staff.id,
      name: staff.name,
      email: staff.email,
      role: staff.title,
      departmentName: staff.department,
    );
  }

  String _semesterForIndex(int index) {
    return switch (index % 3) {
      0 => 'Spring',
      1 => 'Fall',
      _ => 'Summer',
    };
  }
}
