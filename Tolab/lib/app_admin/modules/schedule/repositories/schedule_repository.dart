import 'dart:math' as math;

import '../../../core/errors/app_exception.dart';
import '../../../core/services/demo_data_service.dart';
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

    try {
      final remote = await _api.fetchEvents(filters: filters);
      if (remote.isNotEmpty) {
        _cache = remote;
        _rebuildLookups();
      }
    } catch (_) {}

    return ScheduleBundle(
      events: List<ScheduleEventItem>.unmodifiable(_cache!),
      lookups: _lookups!,
    );
  }

  Future<ScheduleMutationResult> createEvent(
    ScheduleEventUpsertPayload payload,
  ) async {
    _ensureSeeded();
    final local = payload.toEvent(
      id: 'SCH-${DateTime.now().microsecondsSinceEpoch}',
      isSynced: false,
    );

    try {
      final remote = await _api.createEvent(payload);
      _cache = [remote.copyWith(isSynced: true), ..._cache!];
    } catch (_) {
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

    final local = payload.toEvent(id: existing.id, isSynced: existing.isSynced);
    try {
      final remote = await _api.updateEvent(eventId, payload);
      _replace(remote.copyWith(isSynced: true));
    } catch (_) {
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
    try {
      await _api.deleteEvent(eventId);
    } catch (_) {}

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
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final items = <ScheduleEventItem>[];
    for (var index = 0; index < 14; index++) {
      final subject = subjects[index % subjects.length];
      final isAssistantLead = index.isOdd;
      final instructorName = isAssistantLead
          ? subject.assistant.name
          : subject.doctor.name;
      final instructorId = isAssistantLead
          ? subject.assistant.id
          : subject.doctor.id;
      final type = switch (index % 4) {
        0 => ScheduleEventType.lecture,
        1 => ScheduleEventType.quiz,
        2 => ScheduleEventType.exam,
        _ => ScheduleEventType.task,
      };
      final status = index < 4
          ? ScheduleEventStatus.completed
          : ScheduleEventStatus.planned;
      final start = weekStart.add(
        Duration(
          days: index,
          hours: 8 + ((index % 4) * 2),
          minutes: index.isOdd ? 30 : 0,
        ),
      );
      final durationHours = type == ScheduleEventType.exam ? 3 : 2;
      final sectionCode =
          '${subject.department.substring(0, 2).toUpperCase()}-${(index % 4) + 1}A';
      items.add(
        ScheduleEventItem(
          id: 'SCH-${index + 1}',
          title: '${type.label} ${index + 1}',
          section: sectionCode,
          subject: subject.name,
          instructor: instructorName,
          location: index % 5 == 0
              ? 'Hall A${index + 2}'
              : 'Lab ${String.fromCharCode(65 + (index % 5))}${index + 1}',
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
              '$sectionCode • ${math.max(subject.enrolledStudents - (index * 2), 24)} students',
          repeatRule: index < 8
              ? ScheduleRepeatRule.weekly
              : ScheduleRepeatRule.none,
          assignedStaffIds: <String>[
            instructorId,
            if (!isAssistantLead) subject.assistant.id,
          ],
          isSynced: index < 6,
        ),
      );
    }

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
        studentScopeLabel: 'CS-4A • 82 students',
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
        studentScopeLabel: 'CS-4A • 82 students',
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
    final staff = _demoDataService.staff();
    return ScheduleLookupBundle(
      departments: _distinctOptions(
        events.map(
          (event) =>
              ScheduleOption(id: event.department, label: event.department),
        ),
      ),
      years: _distinctOptions(
        events.map(
          (event) =>
              ScheduleOption(id: event.yearLabel, label: event.yearLabel),
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
      instructors: _distinctOptions(
        staff.map(
          (member) => ScheduleOption(
            id: member.id,
            label: member.name,
            subtitle: '${member.title} • ${member.department}',
          ),
        ),
      ),
      sections: _distinctOptions(
        events.map(
          (event) => ScheduleOption(
            id: event.sectionId ?? event.section,
            label: event.section,
            subtitle: '${event.department} • ${event.yearLabel}',
          ),
        ),
      ),
      offerings: _distinctOptions(
        events.map(
          (event) => ScheduleOption(
            id: event.courseOfferingId ?? event.id,
            label: '${event.subject} • ${event.section}',
            subtitle: event.yearLabel,
          ),
        ),
      ),
      staff: _distinctOptions(
        staff.map(
          (member) => ScheduleOption(
            id: member.id,
            label: member.name,
            subtitle: member.title,
          ),
        ),
      ),
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
