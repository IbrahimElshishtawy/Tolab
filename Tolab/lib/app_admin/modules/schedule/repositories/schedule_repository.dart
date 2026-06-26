import 'dart:math' as math;

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/demo_data_service.dart';
import '../../subjects/models/subject_management_models.dart';
import '../models/schedule_models.dart';
import '../services/schedule_api_service.dart';

class ScheduleRepository {
  ScheduleRepository(this._api, this._demoDataService);

  final ScheduleApiService _api;
  final DemoDataService _demoDataService;

  List<ScheduleEventItem>? _cache;
  ScheduleLookupBundle? _lookups;

  Future<ScheduleBundle> fetchSchedule({
    required ScheduleFilters filters,
  }) async {
    _ensureSeeded();

    if (!AppConfig.useMockData) {
      try {
        final remote = await _api.fetchEvents(filters: filters);
        _cache = remote;
        _rebuildLookups();
      } catch (_) {}
    }

    return ScheduleBundle(
      events: List<ScheduleEventItem>.unmodifiable(_cache!),
      lookups: _lookups!,
    );
  }

  ScheduleEventUpsertPayload _resolvePayloadMetadata(ScheduleEventUpsertPayload payload) {
    var department = payload.department;
    var yearLabel = payload.yearLabel;
    var section = payload.section;
    var subject = payload.subject;
    var instructor = payload.instructor;
    var sectionId = payload.sectionId;
    var subjectId = payload.subjectId;
    var instructorId = payload.instructorId;
    var courseOfferingId = payload.courseOfferingId;

    // 1. If subjectId is selected, resolve subject details
    if (subjectId != null && subjectId.isNotEmpty) {
      try {
        final subRecord = _demoDataService.subjects().firstWhere((s) => s.id == subjectId);
        if (subject == 'Subject' || subject.isEmpty) {
          subject = subRecord.name;
        }
        if (department == 'Department' || department.isEmpty) {
          department = subRecord.department;
        }
        if (yearLabel == 'Year' || yearLabel.isEmpty) {
          yearLabel = subRecord.academicYear;
        }
      } catch (_) {}
    }

    // 2. If courseOfferingId is selected, resolve from cache
    if (courseOfferingId != null && courseOfferingId.isNotEmpty) {
      for (final event in _cache ?? const <ScheduleEventItem>[]) {
        if (event.courseOfferingId == courseOfferingId || event.id == courseOfferingId) {
          if (department == 'Department' || department.isEmpty) {
            department = event.department;
          }
          if (yearLabel == 'Year' || yearLabel.isEmpty) {
            yearLabel = event.yearLabel;
          }
          if (section == 'Section' || section.isEmpty) {
            section = event.section;
            sectionId = event.sectionId;
          }
          if (subject == 'Subject' || subject.isEmpty) {
            subject = event.subject;
            subjectId = event.subjectId;
          }
          if (instructor == 'Instructor' || instructor.isEmpty) {
            instructor = event.instructor;
            instructorId = event.instructorId;
          }
          break;
        }
      }
    }

    // 3. If sectionId is selected, resolve section name
    if (sectionId != null && sectionId.isNotEmpty) {
      try {
        final secRecord = _demoDataService.sections().firstWhere((s) => s.id == sectionId);
        if (section == 'Section' || section.isEmpty) {
          section = secRecord.name;
        }
        if (department == 'Department' || department.isEmpty) {
          department = secRecord.department;
        }
      } catch (_) {}
    }

    // 4. If instructorId is selected, resolve instructor name
    if (instructorId != null && instructorId.isNotEmpty) {
      try {
        final staffList = _demoDataService.staffDirectory();
        final staffRec = staffList.firstWhere((s) => s.id == instructorId);
        if (instructor == 'Instructor' || instructor.isEmpty) {
          instructor = staffRec.fullName;
        }
      } catch (_) {
        try {
          final staffCompact = _demoDataService.staff().firstWhere((s) => s.id == instructorId);
          if (instructor == 'Instructor' || instructor.isEmpty) {
            instructor = staffCompact.name;
          }
        } catch (_) {}
      }
    }

    // 5. Fallback lookups from lookup options if available
    final lookups = _lookups;
    if (lookups != null) {
      if (subject == 'Subject' && subjectId != null) {
        final match = lookups.subjects.firstWhere((opt) => opt.id == subjectId, orElse: () => const ScheduleOption(id: '', label: ''));
        if (match.label.isNotEmpty) subject = match.label;
      }
      if (section == 'Section' && sectionId != null) {
        final match = lookups.sections.firstWhere((opt) => opt.id == sectionId, orElse: () => const ScheduleOption(id: '', label: ''));
        if (match.label.isNotEmpty) section = match.label;
      }
      if (instructor == 'Instructor' && instructorId != null) {
        final match = lookups.instructors.firstWhere((opt) => opt.id == instructorId, orElse: () => const ScheduleOption(id: '', label: ''));
        if (match.label.isNotEmpty) instructor = match.label;
      }
    }

    // 6. Make sure department/year are not placeholders if there is any other subject
    if (department == 'Department' && lookups != null && lookups.departments.isNotEmpty) {
      department = lookups.departments.first.label;
    }
    if (yearLabel == 'Year' && lookups != null && lookups.years.isNotEmpty) {
      yearLabel = lookups.years.first.label;
    }

    return ScheduleEventUpsertPayload(
      title: payload.title,
      section: section,
      subject: subject,
      instructor: instructor,
      location: payload.location,
      status: payload.status,
      type: payload.type,
      startAt: payload.startAt,
      endAt: payload.endAt,
      department: department,
      yearLabel: yearLabel,
      note: payload.note,
      courseOfferingId: courseOfferingId,
      sectionId: sectionId,
      subjectId: subjectId,
      instructorId: instructorId,
      studentScopeLabel: payload.studentScopeLabel == 'Section cohort' ? '$section cohort' : payload.studentScopeLabel,
      repeatRule: payload.repeatRule,
      assignedStaffIds: payload.assignedStaffIds,
    );
  }

  Future<ScheduleMutationResult> createEvent(
    ScheduleEventUpsertPayload payload,
  ) async {
    _ensureSeeded();
    final resolvedPayload = _resolvePayloadMetadata(payload);
    final local = resolvedPayload.toEvent(
      id: 'SCH-${DateTime.now().microsecondsSinceEpoch}',
      isSynced: false,
    );

    if (!AppConfig.useMockData) {
      try {
        final remote = await _api.createEvent(resolvedPayload);
        _cache = [remote.copyWith(isSynced: true), ..._cache!];
      } catch (_) {
        _cache = [local, ..._cache!];
      }
    } else {
      _cache = [local, ..._cache!];
    }

    _rebuildLookups();
    return ScheduleMutationResult(
      events: List<ScheduleEventItem>.unmodifiable(_cache!),
      lookups: _lookups!,
      message: 'Schedule event saved successfully.',
      highlightedEventId: _cache!.first.id,
    );
  }

  Future<ScheduleMutationResult> updateEvent({
    required String eventId,
    required ScheduleEventUpsertPayload payload,
  }) async {
    _ensureSeeded();
    final existing = _cache!.firstWhere(
      (event) => event.id == eventId,
      orElse: () =>
          throw AppException('The selected schedule event was not found.'),
    );

    final resolvedPayload = _resolvePayloadMetadata(payload);
    final local = resolvedPayload.toEvent(id: existing.id, isSynced: existing.isSynced);
    if (!AppConfig.useMockData) {
      try {
        final remote = await _api.updateEvent(eventId, resolvedPayload);
        _replace(remote.copyWith(isSynced: true));
      } catch (_) {
        _replace(local);
      }
    } else {
      _replace(local);
    }

    _rebuildLookups();
    return ScheduleMutationResult(
      events: List<ScheduleEventItem>.unmodifiable(_cache!),
      lookups: _lookups!,
      message: 'Schedule event updated successfully.',
      highlightedEventId: eventId,
    );
  }

  Future<ScheduleMutationResult> deleteEvent({required String eventId}) async {
    _ensureSeeded();
    _cache = _cache!
        .where((event) => event.id != eventId)
        .toList(growable: false);
    if (!AppConfig.useMockData) {
      try {
        await _api.deleteEvent(eventId);
      } catch (_) {}
    }

    _rebuildLookups();
    return ScheduleMutationResult(
      events: List<ScheduleEventItem>.unmodifiable(_cache!),
      lookups: _lookups!,
      message: 'Schedule event deleted successfully.',
    );
  }

  Future<ScheduleMutationResult> rescheduleEvent({
    required ScheduleEventItem event,
    required DateTime targetStart,
    required DateTime targetEnd,
  }) {
    return updateEvent(
      eventId: event.id,
      payload: ScheduleEventUpsertPayload(
        title: event.title,
        section: event.section,
        subject: event.subject,
        instructor: event.instructor,
        location: event.location,
        status: event.status,
        type: event.type,
        startAt: targetStart,
        endAt: targetEnd,
        department: event.department,
        yearLabel: event.yearLabel,
        note: event.note,
        courseOfferingId: event.courseOfferingId,
        sectionId: event.sectionId,
        subjectId: event.subjectId,
        instructorId: event.instructorId,
        studentScopeLabel: event.studentScopeLabel,
        repeatRule: event.repeatRule,
        assignedStaffIds: event.assignedStaffIds,
      ),
    );
  }

  void _ensureSeeded() {
    _cache ??= _seedEvents();
    _lookups ??= _buildLookups(_cache!);
  }

  void _rebuildLookups() {
    _lookups = _buildLookups(_cache ?? const <ScheduleEventItem>[]);
  }

  void _replace(ScheduleEventItem item) {
    _cache = [
      for (final current in _cache!)
        if (current.id == item.id) item else current,
    ]..sort((left, right) => left.startAt.compareTo(right.startAt));
  }

  List<ScheduleEventItem> _seedEvents() {
    final subjects = _demoDataService
        .subjects()
        .take(5)
        .toList(growable: false);
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 35));
    final items = <ScheduleEventItem>[];

    var eventIndex = 1;
    for (var dayOffset = 0; dayOffset < 70; dayOffset++) {
      final date = startDate.add(Duration(days: dayOffset));
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      final eventsForDay = (dayOffset % 2) + 1;
      for (var j = 0; j < eventsForDay; j++) {
        final subject = subjects[(dayOffset + j) % subjects.length];
        final isAssistantLead = (dayOffset + j).isOdd;
        final instructorName = isAssistantLead
            ? subject.assistant.name
            : subject.doctor.name;
        final instructorId = isAssistantLead
            ? subject.assistant.id
            : subject.doctor.id;

        final type = switch ((dayOffset + j) % 4) {
          0 => ScheduleEventType.lecture,
          1 => ScheduleEventType.quiz,
          2 => ScheduleEventType.exam,
          _ => ScheduleEventType.task,
        };

        final status = date.isBefore(now)
            ? ScheduleEventStatus.completed
            : ScheduleEventStatus.planned;

        final startHour = 8 + (j * 3);
        final start = DateTime(date.year, date.month, date.day, startHour, 0);
        final durationHours = type == ScheduleEventType.exam ? 3 : 2;
        final sectionCode =
            '${subject.department.substring(0, 2).toUpperCase()}-${((dayOffset + j) % 4) + 1}A';

        items.add(
          ScheduleEventItem(
            id: 'SCH-$eventIndex',
            title: '${type.label} - ${subject.code}',
            section: sectionCode,
            subject: subject.name,
            instructor: instructorName,
            location: eventIndex % 5 == 0
                ? 'Hall A${(eventIndex % 4) + 1}'
                : 'Lab ${String.fromCharCode(65 + (eventIndex % 5))}${(eventIndex % 3) + 1}',
            status: status,
            type: type,
            startAt: start,
            endAt: start.add(Duration(hours: durationHours)),
            department: subject.department,
            yearLabel: subject.academicYear,
            note: type == ScheduleEventType.exam
                ? 'Seating plan and invigilation checklist required.'
                : 'Prepared for ${subject.enrolledStudents} enrolled students.',
            courseOfferingId: 'OFF-${subject.id}',
            sectionId: 'SEC-$sectionCode',
            subjectId: subject.id,
            instructorId: instructorId,
            studentScopeLabel:
                '$sectionCode - ${math.max(subject.enrolledStudents - (eventIndex % 10), 24)} students',
            repeatRule: eventIndex < 20
                ? ScheduleRepeatRule.weekly
                : ScheduleRepeatRule.none,
            assignedStaffIds: <String>[
              instructorId,
              if (!isAssistantLead) subject.assistant.id,
            ],
            isSynced: date.isBefore(now),
          ),
        );
        eventIndex++;
      }
    }

    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final conflictDay = weekStart.add(const Duration(days: 2, hours: 10));

    items.addAll([
      ScheduleEventItem(
        id: 'SCH-CONFLICT-1',
        title: 'Algorithms Quiz Window',
        section: 'CS-4A',
        subject: subjects.first.name,
        instructor: subjects.first.doctor.name,
        location: 'Hall C2',
        status: ScheduleEventStatus.planned,
        type: ScheduleEventType.quiz,
        startAt: conflictDay,
        endAt: conflictDay.add(const Duration(hours: 1, minutes: 30)),
        department: subjects.first.department,
        yearLabel: subjects.first.academicYear,
        note: 'Shared hall with another booking to surface conflict detection.',
        courseOfferingId: 'OFF-${subjects.first.id}',
        sectionId: 'SEC-CS-4A',
        subjectId: subjects.first.id,
        instructorId: subjects.first.doctor.id,
        studentScopeLabel: 'CS-4A - 82 students',
        assignedStaffIds: <String>[subjects.first.doctor.id],
        isSynced: true,
      ),
      ScheduleEventItem(
        id: 'SCH-CONFLICT-2',
        title: 'Operating Systems Task Clinic',
        section: 'CS-4A',
        subject: subjects[1].name,
        instructor: subjects.first.doctor.name,
        location: 'Hall C2',
        status: ScheduleEventStatus.planned,
        type: ScheduleEventType.task,
        startAt: conflictDay.add(const Duration(minutes: 30)),
        endAt: conflictDay.add(const Duration(hours: 2)),
        department: subjects.first.department,
        yearLabel: subjects.first.academicYear,
        note: 'This overlaps by instructor, section, and room.',
        courseOfferingId: 'OFF-${subjects[1].id}',
        sectionId: 'SEC-CS-4A',
        subjectId: subjects[1].id,
        instructorId: subjects.first.doctor.id,
        studentScopeLabel: 'CS-4A - 82 students',
        assignedStaffIds: <String>[
          subjects.first.doctor.id,
          subjects.first.assistant.id,
        ],
        isSynced: true,
      ),
    ]);

    items.sort((left, right) => left.startAt.compareTo(right.startAt));
    return List<ScheduleEventItem>.unmodifiable(items);
  }

  ScheduleLookupBundle _buildLookups(List<ScheduleEventItem> events) {
    final subjects = _demoDataService.subjects();
    final staffOptions = _buildStaffOptions(subjects);

    final validDepartments = events
        .map((e) => e.department.trim())
        .where((d) => d.isNotEmpty && d != 'Department' && d != 'القسم');

    final validYears = events
        .map((e) => e.yearLabel.trim())
        .where((y) => y.isNotEmpty && y != 'Year' && y != 'السنة الدراسية');

    final validSections = events
        .where((e) => e.section.isNotEmpty && e.section != 'Section' && e.section != 'السكشن');

    return ScheduleLookupBundle(
      departments: _distinctOptions(
        validDepartments.map(
          (dept) => ScheduleOption(id: dept, label: dept),
        ),
      ),
      years: _distinctOptions(
        validYears.map(
          (year) => ScheduleOption(id: year, label: year),
        ),
      ),
      subjects: _distinctOptions(
        subjects.map(
          (subject) => ScheduleOption(
            id: subject.id,
            label: subject.name,
            subtitle: subject.code,
          ),
        ),
      ),
      instructors: _distinctOptions(staffOptions),
      sections: _distinctOptions(
        validSections.map(
          (event) => ScheduleOption(
            id: event.sectionId ?? event.section,
            label: event.section,
            subtitle: '${event.department} - ${event.yearLabel}',
          ),
        ),
      ),
      offerings: _distinctOptions(
        validSections.map(
          (event) => ScheduleOption(
            id: event.courseOfferingId ?? event.id,
            label: '${event.subject} - ${event.section}',
            subtitle: event.yearLabel,
          ),
        ),
      ),
      staff: _distinctOptions(staffOptions),
    );
  }

  Iterable<ScheduleOption> _buildStaffOptions(
    List<SubjectRecord> subjects,
  ) sync* {
    for (final subject in subjects) {
      yield _staffOptionForMember(subject.doctor, subject.department);
      yield _staffOptionForMember(subject.assistant, subject.department);
    }
  }

  ScheduleOption _staffOptionForMember(
    SubjectStaffMember member,
    String department,
  ) {
    return ScheduleOption(
      id: member.id,
      label: member.name,
      subtitle: '${member.role} - $department',
    );
  }

  List<ScheduleOption> _distinctOptions(Iterable<ScheduleOption> options) {
    final seen = <String>{};
    final resolved = <ScheduleOption>[];
    for (final option in options) {
      if (!seen.add(option.id)) continue;
      resolved.add(option);
    }
    resolved.sort((left, right) => left.label.compareTo(right.label));
    return List<ScheduleOption>.unmodifiable(resolved);
  }
}
