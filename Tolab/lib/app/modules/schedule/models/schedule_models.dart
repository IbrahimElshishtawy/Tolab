import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/helpers/json_types.dart';

enum ScheduleCalendarView { month, week, day }

extension ScheduleCalendarViewX on ScheduleCalendarView {
  String get label => switch (this) {
    ScheduleCalendarView.month => 'Month',
    ScheduleCalendarView.week => 'Week',
    ScheduleCalendarView.day => 'Day',
  };

  IconData get icon => switch (this) {
    ScheduleCalendarView.month => Icons.calendar_view_month_rounded,
    ScheduleCalendarView.week => Icons.view_week_rounded,
    ScheduleCalendarView.day => Icons.today_rounded,
  };

  int get visibleDays => switch (this) {
    ScheduleCalendarView.month => 30,
    ScheduleCalendarView.week => 7,
    ScheduleCalendarView.day => 1,
  };
}

enum ScheduleEventType { lecture, quiz, exam, task }

extension ScheduleEventTypeX on ScheduleEventType {
  String get label => switch (this) {
    ScheduleEventType.lecture => 'Lecture',
    ScheduleEventType.quiz => 'Quiz',
    ScheduleEventType.exam => 'Exam',
    ScheduleEventType.task => 'Task',
  };

  String get apiValue => name;

  Color get color => switch (this) {
    ScheduleEventType.lecture => AppColors.primary,
    ScheduleEventType.quiz => AppColors.secondary,
    ScheduleEventType.exam => AppColors.warning,
    ScheduleEventType.task => AppColors.info,
  };

  IconData get icon => switch (this) {
    ScheduleEventType.lecture => Icons.co_present_rounded,
    ScheduleEventType.quiz => Icons.quiz_rounded,
    ScheduleEventType.exam => Icons.fact_check_rounded,
    ScheduleEventType.task => Icons.task_alt_rounded,
  };

  static ScheduleEventType fromJson(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return switch (normalized) {
      'lecture' => ScheduleEventType.lecture,
      'quiz' => ScheduleEventType.quiz,
      'exam' => ScheduleEventType.exam,
      'task' || 'assignment' => ScheduleEventType.task,
      _ => ScheduleEventType.lecture,
    };
  }
}

enum ScheduleEventStatus { planned, completed }

extension ScheduleEventStatusX on ScheduleEventStatus {
  String get label => switch (this) {
    ScheduleEventStatus.planned => 'Planned',
    ScheduleEventStatus.completed => 'Completed',
  };

  String get apiValue => name;

  Color get color => switch (this) {
    ScheduleEventStatus.planned => AppColors.primary,
    ScheduleEventStatus.completed => AppColors.secondary,
  };

  static ScheduleEventStatus fromJson(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return switch (normalized) {
      'completed' || 'done' => ScheduleEventStatus.completed,
      _ => ScheduleEventStatus.planned,
    };
  }
}

enum ScheduleRepeatRule { none, weekly, biWeekly, monthly }

extension ScheduleRepeatRuleX on ScheduleRepeatRule {
  String get label => switch (this) {
    ScheduleRepeatRule.none => 'Does not repeat',
    ScheduleRepeatRule.weekly => 'Repeats weekly',
    ScheduleRepeatRule.biWeekly => 'Repeats bi-weekly',
    ScheduleRepeatRule.monthly => 'Repeats monthly',
  };

  String get shortLabel => switch (this) {
    ScheduleRepeatRule.none => 'None',
    ScheduleRepeatRule.weekly => 'Weekly',
    ScheduleRepeatRule.biWeekly => 'Bi-weekly',
    ScheduleRepeatRule.monthly => 'Monthly',
  };

  String get remoteWeekPattern => switch (this) {
    ScheduleRepeatRule.none || ScheduleRepeatRule.weekly => 'ALL',
    ScheduleRepeatRule.biWeekly => 'ODD',
    ScheduleRepeatRule.monthly => 'ALL',
  };

  static ScheduleRepeatRule fromJson(dynamic value) {
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return switch (normalized) {
      'weekly' => ScheduleRepeatRule.weekly,
      'biweekly' ||
      'bi_weekly' ||
      'bi-weekly' ||
      'odd' ||
      'even' => ScheduleRepeatRule.biWeekly,
      'monthly' => ScheduleRepeatRule.monthly,
      _ => ScheduleRepeatRule.none,
    };
  }
}

class ScheduleOption {
  const ScheduleOption({required this.id, required this.label, this.subtitle});

  final String id;
  final String label;
  final String? subtitle;

  factory ScheduleOption.fromJson(JsonMap json) {
    return ScheduleOption(
      id: _stringValue(json['id'], 'option'),
      label: _stringValue(json['label'] ?? json['name'], 'Option'),
      subtitle: _nullableString(json['subtitle']),
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'id': id,
    'label': label,
    if (subtitle != null) 'subtitle': subtitle,
  };
}

class ScheduleFilters {
  const ScheduleFilters({
    this.departmentId,
    this.yearId,
    this.subjectId,
    this.instructorId,
    this.sectionId,
    this.showPlanned = true,
    this.showCompleted = true,
    this.conflictsOnly = false,
    this.eventTypes = const <ScheduleEventType>{
      ScheduleEventType.lecture,
      ScheduleEventType.quiz,
      ScheduleEventType.exam,
      ScheduleEventType.task,
    },
  });

  final String? departmentId;
  final String? yearId;
  final String? subjectId;
  final String? instructorId;
  final String? sectionId;
  final bool showPlanned;
  final bool showCompleted;
  final bool conflictsOnly;
  final Set<ScheduleEventType> eventTypes;

  ScheduleFilters copyWith({
    String? departmentId,
    String? yearId,
    String? subjectId,
    String? instructorId,
    String? sectionId,
    bool? showPlanned,
    bool? showCompleted,
    bool? conflictsOnly,
    Set<ScheduleEventType>? eventTypes,
    bool clearDepartment = false,
    bool clearYear = false,
    bool clearSubject = false,
    bool clearInstructor = false,
    bool clearSection = false,
  }) {
    return ScheduleFilters(
      departmentId: clearDepartment
          ? null
          : (departmentId ?? this.departmentId),
      yearId: clearYear ? null : (yearId ?? this.yearId),
      subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
      instructorId: clearInstructor
          ? null
          : (instructorId ?? this.instructorId),
      sectionId: clearSection ? null : (sectionId ?? this.sectionId),
      showPlanned: showPlanned ?? this.showPlanned,
      showCompleted: showCompleted ?? this.showCompleted,
      conflictsOnly: conflictsOnly ?? this.conflictsOnly,
      eventTypes: eventTypes ?? this.eventTypes,
    );
  }

  ScheduleFilters cleared() => const ScheduleFilters();
}

class ScheduleLookupBundle {
  const ScheduleLookupBundle({
    this.departments = const <ScheduleOption>[],
    this.years = const <ScheduleOption>[],
    this.subjects = const <ScheduleOption>[],
    this.instructors = const <ScheduleOption>[],
    this.sections = const <ScheduleOption>[],
    this.offerings = const <ScheduleOption>[],
    this.staff = const <ScheduleOption>[],
  });

  final List<ScheduleOption> departments;
  final List<ScheduleOption> years;
  final List<ScheduleOption> subjects;
  final List<ScheduleOption> instructors;
  final List<ScheduleOption> sections;
  final List<ScheduleOption> offerings;
  final List<ScheduleOption> staff;

  ScheduleLookupBundle copyWith({
    List<ScheduleOption>? departments,
    List<ScheduleOption>? years,
    List<ScheduleOption>? subjects,
    List<ScheduleOption>? instructors,
    List<ScheduleOption>? sections,
    List<ScheduleOption>? offerings,
    List<ScheduleOption>? staff,
  }) {
    return ScheduleLookupBundle(
      departments: departments ?? this.departments,
      years: years ?? this.years,
      subjects: subjects ?? this.subjects,
      instructors: instructors ?? this.instructors,
      sections: sections ?? this.sections,
      offerings: offerings ?? this.offerings,
      staff: staff ?? this.staff,
    );
  }
}

class ScheduleEventItem {
  const ScheduleEventItem({
    required this.id,
    required this.title,
    required this.section,
    required this.subject,
    required this.instructor,
    required this.location,
    required this.status,
    required this.type,
    required this.startAt,
    required this.endAt,
    required this.department,
    required this.yearLabel,
    this.note,
    this.courseOfferingId,
    this.sectionId,
    this.subjectId,
    this.instructorId,
    this.studentScopeLabel,
    this.repeatRule = ScheduleRepeatRule.none,
    this.assignedStaffIds = const <String>[],
    this.isSynced = false,
  });

  final String id;
  final String title;
  final String section;
  final String subject;
  final String instructor;
  final String location;
  final ScheduleEventStatus status;
  final ScheduleEventType type;
  final DateTime startAt;
  final DateTime endAt;
  final String department;
  final String yearLabel;
  final String? note;
  final String? courseOfferingId;
  final String? sectionId;
  final String? subjectId;
  final String? instructorId;
  final String? studentScopeLabel;
  final ScheduleRepeatRule repeatRule;
  final List<String> assignedStaffIds;
  final bool isSynced;

  Duration get duration => endAt.difference(startAt);

  bool occursOnDay(DateTime date) {
    return startAt.year == date.year &&
        startAt.month == date.month &&
        startAt.day == date.day;
  }

  ScheduleEventItem copyWith({
    String? id,
    String? title,
    String? section,
    String? subject,
    String? instructor,
    String? location,
    ScheduleEventStatus? status,
    ScheduleEventType? type,
    DateTime? startAt,
    DateTime? endAt,
    String? department,
    String? yearLabel,
    String? note,
    String? courseOfferingId,
    String? sectionId,
    String? subjectId,
    String? instructorId,
    String? studentScopeLabel,
    ScheduleRepeatRule? repeatRule,
    List<String>? assignedStaffIds,
    bool? isSynced,
    bool clearNote = false,
  }) {
    return ScheduleEventItem(
      id: id ?? this.id,
      title: title ?? this.title,
      section: section ?? this.section,
      subject: subject ?? this.subject,
      instructor: instructor ?? this.instructor,
      location: location ?? this.location,
      status: status ?? this.status,
      type: type ?? this.type,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      department: department ?? this.department,
      yearLabel: yearLabel ?? this.yearLabel,
      note: clearNote ? null : (note ?? this.note),
      courseOfferingId: courseOfferingId ?? this.courseOfferingId,
      sectionId: sectionId ?? this.sectionId,
      subjectId: subjectId ?? this.subjectId,
      instructorId: instructorId ?? this.instructorId,
      studentScopeLabel: studentScopeLabel ?? this.studentScopeLabel,
      repeatRule: repeatRule ?? this.repeatRule,
      assignedStaffIds: assignedStaffIds ?? this.assignedStaffIds,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'section': section,
    'subject': subject,
    'instructor': instructor,
    'location': location,
    'status': status.apiValue,
    'type': type.apiValue,
    'start_at': startAt.toIso8601String(),
    'end_at': endAt.toIso8601String(),
    'department': department,
    'year_label': yearLabel,
    'note': note,
    'course_offering_id': courseOfferingId,
    'section_id': sectionId,
    'subject_id': subjectId,
    'instructor_id': instructorId,
    'student_scope_label': studentScopeLabel,
    'repeat_rule': repeatRule.name,
    'assigned_staff_ids': assignedStaffIds,
    'is_synced': isSynced,
  };

  factory ScheduleEventItem.fromJson(JsonMap json) {
    final startAt =
        _dateValue(json['start_at']) ??
        _dateValue(json['start']) ??
        _resolveRecurringDate(
          dayOfWeek: _intValue(json['day_of_week']),
          time: _stringValue(json['start_time'], '09:00'),
        );
    final endAt =
        _dateValue(json['end_at']) ??
        _dateValue(json['end']) ??
        _resolveRecurringDate(
          dayOfWeek: _intValue(json['day_of_week']),
          time: _stringValue(json['end_time'], '10:00'),
          baseDate: startAt,
        );

    return ScheduleEventItem(
      id: _stringValue(json['id'], 'schedule-event'),
      title: _stringValue(
        json['title'] ?? json['name'] ?? json['type'],
        'Schedule event',
      ),
      section: _stringValue(json['section'] ?? json['section_name'], 'Section'),
      subject: _stringValue(
        json['subject'] ?? json['subject_name'] ?? json['course_name'],
        'Subject',
      ),
      instructor: _stringValue(
        json['instructor'] ??
            json['instructor_name'] ??
            json['doctor_name'] ??
            json['staff_name'],
        'Instructor',
      ),
      location: _stringValue(json['location'], 'Room TBD'),
      status: ScheduleEventStatusX.fromJson(json['status']),
      type: ScheduleEventTypeX.fromJson(json['type']),
      startAt: startAt,
      endAt: endAt.isAfter(startAt)
          ? endAt
          : startAt.add(const Duration(hours: 1)),
      department: _stringValue(
        json['department'] ?? json['department_name'],
        'Department',
      ),
      yearLabel: _stringValue(
        json['year_label'] ?? json['academic_year'],
        'Year',
      ),
      note: _nullableString(json['note']),
      courseOfferingId: _nullableString(json['course_offering_id']),
      sectionId: _nullableString(json['section_id']),
      subjectId: _nullableString(json['subject_id']),
      instructorId: _nullableString(
        json['instructor_id'] ?? json['doctor_id'] ?? json['staff_id'],
      ),
      studentScopeLabel: _nullableString(json['student_scope_label']),
      repeatRule: ScheduleRepeatRuleX.fromJson(
        json['repeat_rule'] ?? json['week_pattern'],
      ),
      assignedStaffIds: _stringList(json['assigned_staff_ids']),
      isSynced: json['is_synced'] == true,
    );
  }
}

class ScheduleEventUpsertPayload {
  const ScheduleEventUpsertPayload({
    required this.title,
    required this.section,
    required this.subject,
    required this.instructor,
    required this.location,
    required this.status,
    required this.type,
    required this.startAt,
    required this.endAt,
    required this.department,
    required this.yearLabel,
    this.note,
    this.courseOfferingId,
    this.sectionId,
    this.subjectId,
    this.instructorId,
    this.studentScopeLabel,
    this.repeatRule = ScheduleRepeatRule.none,
    this.assignedStaffIds = const <String>[],
  });

  final String title;
  final String section;
  final String subject;
  final String instructor;
  final String location;
  final ScheduleEventStatus status;
  final ScheduleEventType type;
  final DateTime startAt;
  final DateTime endAt;
  final String department;
  final String yearLabel;
  final String? note;
  final String? courseOfferingId;
  final String? sectionId;
  final String? subjectId;
  final String? instructorId;
  final String? studentScopeLabel;
  final ScheduleRepeatRule repeatRule;
  final List<String> assignedStaffIds;

  ScheduleEventItem toEvent({required String id, required bool isSynced}) {
    return ScheduleEventItem(
      id: id,
      title: title,
      section: section,
      subject: subject,
      instructor: instructor,
      location: location,
      status: status,
      type: type,
      startAt: startAt,
      endAt: endAt,
      department: department,
      yearLabel: yearLabel,
      note: note,
      courseOfferingId: courseOfferingId,
      sectionId: sectionId,
      subjectId: subjectId,
      instructorId: instructorId,
      studentScopeLabel: studentScopeLabel,
      repeatRule: repeatRule,
      assignedStaffIds: assignedStaffIds,
      isSynced: isSynced,
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'title': title,
    'section': section,
    'subject': subject,
    'instructor': instructor,
    'location': location,
    'status': status.apiValue,
    'type': type.apiValue,
    'start_at': startAt.toIso8601String(),
    'end_at': endAt.toIso8601String(),
    'department': department,
    'year_label': yearLabel,
    'note': note,
    'course_offering_id': courseOfferingId,
    'section_id': sectionId,
    'subject_id': subjectId,
    'instructor_id': instructorId,
    'student_scope_label': studentScopeLabel,
    'repeat_rule': repeatRule.name,
    'assigned_staff_ids': assignedStaffIds,
  };

  JsonMap toRemoteApiJson() => <String, dynamic>{
    'title': title,
    'type': type.apiValue,
    'status': status.apiValue,
    'day_of_week': startAt.weekday % 7,
    'start_time': _formatTime(startAt),
    'end_time': _formatTime(endAt),
    'location': location,
    'week_pattern': repeatRule.remoteWeekPattern,
    'note': note,
    'section': section,
    'subject': subject,
    'department': department,
    'academic_year': yearLabel,
    'instructor_name': instructor,
    'student_scope_label': studentScopeLabel,
    'assigned_staff_ids': assignedStaffIds,
  };
}

class ScheduleBundle {
  const ScheduleBundle({required this.events, required this.lookups});

  final List<ScheduleEventItem> events;
  final ScheduleLookupBundle lookups;
}

class ScheduleMutationResult {
  const ScheduleMutationResult({
    required this.events,
    required this.lookups,
    required this.message,
    this.highlightedEventId,
  });

  final List<ScheduleEventItem> events;
  final ScheduleLookupBundle lookups;
  final String message;
  final String? highlightedEventId;
}

class ScheduleConflict {
  const ScheduleConflict({required this.eventId, required this.reasons});

  final String eventId;
  final List<String> reasons;
}

DateTime _resolveRecurringDate({
  int? dayOfWeek,
  required String time,
  DateTime? baseDate,
}) {
  final reference = baseDate ?? DateTime.now();
  final sanitizedDay = (dayOfWeek ?? reference.weekday % 7).clamp(0, 6);
  final startOfWeek = reference.subtract(Duration(days: reference.weekday % 7));
  final targetDay = DateTime(
    startOfWeek.year,
    startOfWeek.month,
    startOfWeek.day + sanitizedDay,
  );
  final parts = time.split(':');
  final hour = int.tryParse(parts.isEmpty ? '' : parts.first) ?? 9;
  final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
  return DateTime(targetDay.year, targetDay.month, targetDay.day, hour, minute);
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _stringValue(dynamic value, String fallback) {
  final resolved = value?.toString().trim();
  if (resolved == null || resolved.isEmpty) return fallback;
  return resolved;
}

String? _nullableString(dynamic value) {
  final resolved = value?.toString().trim();
  if (resolved == null || resolved.isEmpty) return null;
  return resolved;
}

DateTime? _dateValue(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

int? _intValue(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
