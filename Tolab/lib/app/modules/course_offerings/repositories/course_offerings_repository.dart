import 'dart:math' as math;

import '../../../core/errors/app_exception.dart';
import '../../../core/services/demo_data_service.dart';
import '../../subjects/models/subject_management_models.dart';
import '../models/course_offering_model.dart';
import '../services/course_offerings_api.dart';

class CourseOfferingsRepository {
  CourseOfferingsRepository(this._api, this._demoDataService);

  final CourseOfferingsApi _api;
  final DemoDataService _demoDataService;

  List<CourseOfferingModel>? _cache;

  Future<CourseOfferingsBundle> fetchOfferings({
    required CourseOfferingsFilters filters,
    required CourseOfferingsPagination pagination,
  }) async {
    _ensureSeeded();
    try {
      final remote = await _api.fetchOfferings(
        page: 1,
        perPage: 100,
        semester: filters.semester,
      );
      if (remote.items.isNotEmpty) {
        _cache = remote.items
            .map(
              (item) =>
                  _mergeRemoteOffering(item, fallback: _findById(item.id)),
            )
            .toList(growable: false);
      }
    } catch (_) {}

    final offerings = List<CourseOfferingModel>.unmodifiable(_cache!);
    return CourseOfferingsBundle(
      offerings: offerings,
      subjects: _buildSubjectOptions(),
      doctors: _buildStaffOptions(role: 'Doctor'),
      assistants: _buildStaffOptions(role: 'Assistant'),
      departments: _buildDepartmentOptions(),
      sections: _buildSectionOptions(),
      pagination: pagination.copyWith(
        totalItems: offerings.length,
        totalPages: _pageCount(offerings.length, pagination.perPage),
      ),
    );
  }

  Future<CourseOfferingModel> fetchOfferingDetails(String offeringId) async {
    _ensureSeeded();
    final fallback = _findById(offeringId);
    try {
      final remote = await _api.fetchOfferingDetails(offeringId);
      final merged = _mergeRemoteOffering(remote, fallback: fallback);
      _replaceInCache(merged);
      return merged;
    } catch (_) {
      if (fallback != null) return fallback;
      throw AppException('The selected offering could not be found.');
    }
  }

  Future<CourseOfferingMutationResult> createOffering({
    required CourseOfferingUpsertPayload payload,
    required CourseOfferingsPagination pagination,
  }) async {
    _ensureSeeded();
    final local = _materializePayload(
      payload,
      id: 'OFF-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    try {
      final remote = await _api.createOffering(payload);
      _cache = [_mergeRemoteOffering(remote, fallback: local), ..._cache!];
    } catch (_) {
      _cache = [local, ..._cache!];
    }
    return _mutationResult(
      message: 'Course offering created successfully.',
      pagination: pagination,
      updatedOfferingId: _cache!.first.id,
    );
  }

  Future<CourseOfferingMutationResult> updateOffering({
    required String offeringId,
    required CourseOfferingUpsertPayload payload,
    required CourseOfferingsPagination pagination,
  }) async {
    _ensureSeeded();
    final current = _findById(offeringId);
    if (current == null) {
      throw AppException('The selected offering could not be found.');
    }
    final local =
        _materializePayload(
          payload,
          id: current.id,
          createdAt: current.createdAt,
          enrolledCount: current.enrolledCount,
        ).copyWith(
          students: current.students,
          schedule: current.schedule,
          contentActions: current.contentActions,
        );
    try {
      final remote = await _api.updateOffering(offeringId, payload);
      _replaceInCache(_mergeRemoteOffering(remote, fallback: local));
    } catch (_) {
      _replaceInCache(local);
    }
    return _mutationResult(
      message: 'Course offering updated successfully.',
      pagination: pagination,
      updatedOfferingId: offeringId,
    );
  }

  Future<CourseOfferingMutationResult> deleteOffering({
    required String offeringId,
    required CourseOfferingsPagination pagination,
  }) async {
    _ensureSeeded();
    _cache = _cache!
        .where((item) => item.id != offeringId)
        .toList(growable: false);
    try {
      await _api.deleteOffering(offeringId);
    } catch (_) {}
    return _mutationResult(
      message: 'Course offering deleted successfully.',
      pagination: pagination,
    );
  }

  CourseOfferingMutationResult _mutationResult({
    required String message,
    required CourseOfferingsPagination pagination,
    String? updatedOfferingId,
  }) {
    final offerings = List<CourseOfferingModel>.unmodifiable(_cache!);
    return CourseOfferingMutationResult(
      offerings: offerings,
      pagination: pagination.copyWith(
        totalItems: offerings.length,
        totalPages: _pageCount(offerings.length, pagination.perPage),
      ),
      message: message,
      updatedOfferingId: updatedOfferingId,
    );
  }

  void _ensureSeeded() {
    _cache ??= _seedOfferings();
  }

  List<CourseOfferingModel> _seedOfferings() {
    final subjects = _demoDataService
        .subjects()
        .take(6)
        .toList(growable: false);
    const sections = <_SeedSection>[
      _SeedSection('SEC-1', 'CS-4A', 'DEP-1', 'Computer Science'),
      _SeedSection('SEC-2', 'CS-4B', 'DEP-1', 'Computer Science'),
      _SeedSection('SEC-3', 'IS-3A', 'DEP-2', 'Information Systems'),
      _SeedSection('SEC-4', 'IS-3B', 'DEP-2', 'Information Systems'),
      _SeedSection('SEC-5', 'ENG-2A', 'DEP-3', 'Engineering'),
      _SeedSection('SEC-6', 'ENG-3B', 'DEP-3', 'Engineering'),
    ];
    const statuses = <CourseOfferingStatus>[
      CourseOfferingStatus.active,
      CourseOfferingStatus.active,
      CourseOfferingStatus.draft,
      CourseOfferingStatus.completed,
      CourseOfferingStatus.cancelled,
      CourseOfferingStatus.active,
    ];
    const semesters = <String>[
      'Spring',
      'Spring',
      'Summer',
      'Fall',
      'Fall',
      'Spring',
    ];

    return List<CourseOfferingModel>.generate(subjects.length, (index) {
      final subject = subjects[index];
      final section = sections[index % sections.length];
      final startDate = DateTime(2026, math.max(1, index + 1), 4 + index);
      final enrolled = math.max(18, subject.enrolledStudents - (index * 7));
      final capacity = math.max(enrolled + 10, subject.eligibleStudents);
      return CourseOfferingModel(
        id: 'OFF-${index + 1}',
        subjectId: subject.id,
        subjectName: subject.name,
        code: subject.code,
        departmentId: section.departmentId,
        departmentName: section.departmentName,
        sectionId: section.id,
        sectionName: section.name,
        doctor: CourseOfferingStaffMember(
          id: subject.doctor.id,
          name: subject.doctor.name,
          role: 'Doctor',
          email: subject.doctor.email,
          department: subject.department,
        ),
        assistants: [
          CourseOfferingStaffMember(
            id: subject.assistant.id,
            name: subject.assistant.name,
            role: 'Assistant',
            email: subject.assistant.email,
            department: subject.department,
          ),
        ],
        semester: semesters[index],
        academicYear: '2025/2026',
        capacity: capacity,
        enrolledCount: math.min(enrolled, capacity),
        status: statuses[index],
        startDate: startDate,
        endDate: startDate.add(const Duration(days: 104)),
        createdAt: DateTime(2025, 12, 18 + index),
        students: _seedStudents(section.name, index, math.min(8, 5 + index)),
        schedule: _seedSchedule(subject.code, section.name, index),
        contentActions: const [
          CourseOfferingQuickAction(
            id: 'lecture',
            kind: CourseOfferingQuickActionKind.lecture,
            title: 'Add lecture',
            subtitle: 'Create a new lecture and publish structured content.',
          ),
          CourseOfferingQuickAction(
            id: 'upload',
            kind: CourseOfferingQuickActionKind.upload,
            title: 'Upload file',
            subtitle: 'Attach slides, sheets, or supporting material.',
          ),
          CourseOfferingQuickAction(
            id: 'assignment',
            kind: CourseOfferingQuickActionKind.assignment,
            title: 'Create assignment',
            subtitle: 'Open quick coursework for the enrolled cohort.',
          ),
          CourseOfferingQuickAction(
            id: 'announcement',
            kind: CourseOfferingQuickActionKind.announcement,
            title: 'Post update',
            subtitle: 'Notify the cohort with a staff announcement.',
          ),
        ],
      );
    }).toList(growable: false);
  }

  List<CourseOfferingStudent> _seedStudents(
    String sectionName,
    int offeringIndex,
    int count,
  ) {
    const names = <String>[
      'Omar Adel',
      'Mariam Tarek',
      'Youssef Ali',
      'Nadine Khaled',
      'Salma Hossam',
      'Mahmoud Osama',
      'Rana Samir',
      'Karim Mohamed',
      'Lina Adel',
      'Farah Emad',
    ];
    return List<CourseOfferingStudent>.generate(count, (index) {
      final name = names[(offeringIndex + index) % names.length];
      return CourseOfferingStudent(
        id: 'STD-$offeringIndex-$index',
        name: name,
        email: '${name.toLowerCase().replaceAll(' ', '.')}@tolab.edu',
        sectionName: sectionName,
        status: index.isEven ? 'Active' : 'Regular',
        enrolledAt: DateTime(2026, 1, 8 + index),
      );
    }).toList(growable: false);
  }

  List<CourseOfferingScheduleItem> _seedSchedule(
    String code,
    String sectionName,
    int index,
  ) {
    const days = <String>['Sunday', 'Monday', 'Tuesday', 'Wednesday'];
    return <CourseOfferingScheduleItem>[
      CourseOfferingScheduleItem(
        id: 'SCH-$index-1',
        title: '$code Lecture',
        dayLabel: days[index % days.length],
        timeLabel: '09:00 - 11:00',
        location: 'Hall ${String.fromCharCode(65 + index)}12',
        type: 'Lecture',
        status: 'Scheduled',
      ),
      CourseOfferingScheduleItem(
        id: 'SCH-$index-2',
        title: '$sectionName Section',
        dayLabel: days[(index + 1) % days.length],
        timeLabel: '12:30 - 14:00',
        location: 'Lab ${index + 1}0${index + 2}',
        type: 'Section',
        status: 'Scheduled',
      ),
      CourseOfferingScheduleItem(
        id: 'SCH-$index-3',
        title: 'Office hours',
        dayLabel: days[(index + 2) % days.length],
        timeLabel: '14:30 - 15:30',
        location: 'Faculty office',
        type: 'Support',
        status: 'Open',
      ),
    ];
  }

  CourseOfferingModel _mergeRemoteOffering(
    CourseOfferingModel remote, {
    CourseOfferingModel? fallback,
  }) {
    return remote.copyWith(
      subjectId: remote.subjectId.isEmpty
          ? fallback?.subjectId
          : remote.subjectId,
      subjectName: remote.subjectName == 'Untitled subject'
          ? fallback?.subjectName
          : remote.subjectName,
      code: remote.code == 'SUBJ' ? fallback?.code : remote.code,
      departmentId: remote.departmentId.isEmpty
          ? fallback?.departmentId
          : remote.departmentId,
      departmentName: remote.departmentName == 'Department'
          ? fallback?.departmentName
          : remote.departmentName,
      sectionId: remote.sectionId.isEmpty
          ? fallback?.sectionId
          : remote.sectionId,
      sectionName: remote.sectionName == 'Section'
          ? fallback?.sectionName
          : remote.sectionName,
      doctor: remote.doctor.name == 'Unassigned doctor'
          ? fallback?.doctor
          : remote.doctor,
      assistants: remote.assistants.isEmpty
          ? fallback?.assistants
          : remote.assistants,
      capacity: remote.capacity == 120 && fallback != null
          ? fallback.capacity
          : remote.capacity,
      enrolledCount: remote.enrolledCount == 0 && fallback != null
          ? fallback.enrolledCount
          : remote.enrolledCount,
      students: remote.students.isEmpty ? fallback?.students : remote.students,
      schedule: remote.schedule.isEmpty ? fallback?.schedule : remote.schedule,
      contentActions: remote.contentActions.isEmpty
          ? fallback?.contentActions
          : remote.contentActions,
    );
  }

  CourseOfferingModel _materializePayload(
    CourseOfferingUpsertPayload payload, {
    required String id,
    required DateTime createdAt,
    int? enrolledCount,
  }) {
    final subject = _buildSubjectOptions().firstWhere(
      (item) => item.id == payload.subjectId,
      orElse: () => const CourseOfferingLookupOption(
        id: 'subject',
        label: 'Untitled subject',
      ),
    );
    final department = _buildDepartmentOptions().firstWhere(
      (item) => item.id == payload.departmentId,
      orElse: () => const CourseOfferingLookupOption(
        id: 'department',
        label: 'Department',
      ),
    );
    final section = _buildSectionOptions().firstWhere(
      (item) => item.id == payload.sectionId,
      orElse: () =>
          const CourseOfferingLookupOption(id: 'section', label: 'Section'),
    );
    final doctor = _buildStaffOptions(role: 'Doctor').firstWhere(
      (item) => item.id == payload.doctorId,
      orElse: () =>
          const CourseOfferingLookupOption(id: 'doctor', label: 'Doctor'),
    );
    final assistantOptions = _buildStaffOptions(role: 'Assistant');

    return CourseOfferingModel(
      id: id,
      subjectId: subject.id,
      subjectName: subject.label,
      code: subject.subtitle ?? 'SUBJ',
      departmentId: department.id,
      departmentName: department.label,
      sectionId: section.id,
      sectionName: section.label,
      doctor: CourseOfferingStaffMember(
        id: doctor.id,
        name: doctor.label,
        role: 'Doctor',
        email: doctor.subtitle ?? 'doctor@tolab.edu',
        department: department.label,
      ),
      assistants: payload.assistantIds
          .map(
            (assistantId) => assistantOptions.firstWhere(
              (item) => item.id == assistantId,
              orElse: () => CourseOfferingLookupOption(
                id: assistantId,
                label: 'Assistant',
                subtitle: 'assistant@tolab.edu',
                group: department.id,
              ),
            ),
          )
          .map(
            (item) => CourseOfferingStaffMember(
              id: item.id,
              name: item.label,
              role: 'Assistant',
              email: item.subtitle ?? 'assistant@tolab.edu',
              department: department.label,
            ),
          )
          .toList(growable: false),
      semester: payload.semester,
      academicYear: payload.academicYear,
      capacity: payload.capacity,
      enrolledCount: enrolledCount ?? payload.enrolledCount,
      status: payload.status,
      startDate: payload.startDate,
      endDate: payload.endDate,
      createdAt: createdAt,
      students: _seedStudents(section.label, 0, 6),
      schedule: _seedSchedule(subject.subtitle ?? 'SUBJ', section.label, 0),
      contentActions: const [
        CourseOfferingQuickAction(
          id: 'lecture',
          kind: CourseOfferingQuickActionKind.lecture,
          title: 'Add lecture',
          subtitle: 'Create a new lecture and publish structured content.',
        ),
        CourseOfferingQuickAction(
          id: 'upload',
          kind: CourseOfferingQuickActionKind.upload,
          title: 'Upload file',
          subtitle: 'Attach slides, sheets, or supporting material.',
        ),
      ],
    );
  }

  List<CourseOfferingLookupOption> _buildSubjectOptions() {
    return _demoDataService
        .subjects()
        .map((SubjectRecord subject) {
          final departmentId = _departmentIdFromName(subject.department);
          return CourseOfferingLookupOption(
            id: subject.id,
            label: subject.name,
            subtitle: subject.code,
            group: departmentId,
          );
        })
        .toList(growable: false);
  }

  List<CourseOfferingLookupOption> _buildDepartmentOptions() {
    final names = <String>{
      ..._demoDataService.subjects().map((item) => item.department),
      ...?_cache?.map((item) => item.departmentName),
    }.toList()..sort();
    return names
        .map(
          (name) => CourseOfferingLookupOption(
            id: _departmentIdFromName(name),
            label: name,
          ),
        )
        .toList(growable: false);
  }

  List<CourseOfferingLookupOption> _buildSectionOptions() {
    final map = <String, CourseOfferingLookupOption>{
      for (final offering in _cache ?? const <CourseOfferingModel>[])
        offering.sectionId: CourseOfferingLookupOption(
          id: offering.sectionId,
          label: offering.sectionName,
          group: offering.departmentId,
        ),
      'SEC-7': const CourseOfferingLookupOption(
        id: 'SEC-7',
        label: 'CS-3C',
        group: 'DEP-1',
      ),
      'SEC-8': const CourseOfferingLookupOption(
        id: 'SEC-8',
        label: 'IS-4A',
        group: 'DEP-2',
      ),
    };
    return map.values.toList(growable: false);
  }

  List<CourseOfferingLookupOption> _buildStaffOptions({required String role}) {
    final map = <String, CourseOfferingLookupOption>{};
    for (final subject in _demoDataService.subjects()) {
      final staff = role == 'Doctor' ? subject.doctor : subject.assistant;
      map[staff.id] = CourseOfferingLookupOption(
        id: staff.id,
        label: staff.name,
        subtitle: staff.email,
        group: _departmentIdFromName(subject.department),
      );
    }
    for (final offering in _cache ?? const <CourseOfferingModel>[]) {
      final members = role == 'Doctor'
          ? [offering.doctor]
          : offering.assistants;
      for (final member in members) {
        map[member.id] = CourseOfferingLookupOption(
          id: member.id,
          label: member.name,
          subtitle: member.email,
          group: offering.departmentId,
        );
      }
    }
    return map.values.toList(growable: false);
  }

  String _departmentIdFromName(String name) {
    return switch (name.toLowerCase()) {
      'computer science' => 'DEP-1',
      'information systems' => 'DEP-2',
      'engineering' => 'DEP-3',
      _ => 'DEP-${name.hashCode.abs()}',
    };
  }

  int _pageCount(int totalItems, int perPage) {
    if (totalItems == 0) return 1;
    return (totalItems / perPage).ceil();
  }

  CourseOfferingModel? _findById(String offeringId) {
    for (final offering in _cache ?? const <CourseOfferingModel>[]) {
      if (offering.id == offeringId) return offering;
    }
    return null;
  }

  void _replaceInCache(CourseOfferingModel offering) {
    _cache = (_cache ?? const <CourseOfferingModel>[])
        .map((item) => item.id == offering.id ? offering : item)
        .toList(growable: false);
  }
}

class _SeedSection {
  const _SeedSection(
    this.id,
    this.name,
    this.departmentId,
    this.departmentName,
  );

  final String id;
  final String name;
  final String departmentId;
  final String departmentName;
}
