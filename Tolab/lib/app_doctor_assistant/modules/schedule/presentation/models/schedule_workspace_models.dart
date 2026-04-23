import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app_admin/modules/schedule/models/schedule_models.dart';

enum FacultyScheduleFilter { lectures, sections, quizzes, tasks, exams }

extension FacultyScheduleFilterX on FacultyScheduleFilter {
  String get label => switch (this) {
    FacultyScheduleFilter.lectures => 'Lectures',
    FacultyScheduleFilter.sections => 'Sections',
    FacultyScheduleFilter.quizzes => 'Quizzes',
    FacultyScheduleFilter.tasks => 'Tasks',
    FacultyScheduleFilter.exams => 'Exams',
  };

  IconData get icon => switch (this) {
    FacultyScheduleFilter.lectures => Icons.slideshow_rounded,
    FacultyScheduleFilter.sections => Icons.widgets_rounded,
    FacultyScheduleFilter.quizzes => Icons.quiz_rounded,
    FacultyScheduleFilter.tasks => Icons.task_alt_rounded,
    FacultyScheduleFilter.exams => Icons.fact_check_rounded,
  };
}

class FacultyScheduleItem {
  const FacultyScheduleItem({
    required this.event,
    required this.filter,
    required this.statusLabel,
    required this.followUpLabel,
    required this.hasConflict,
    required this.isMissingContext,
  });

  final ScheduleEventItem event;
  final FacultyScheduleFilter filter;
  final String statusLabel;
  final String followUpLabel;
  final bool hasConflict;
  final bool isMissingContext;
}

class FacultyScheduleWorkspace {
  const FacultyScheduleWorkspace({
    required this.items,
    required this.conflicts,
    required this.upcomingThisWeek,
    required this.needsFollowUp,
    required this.missingContext,
  });

  final List<FacultyScheduleItem> items;
  final Map<String, List<String>> conflicts;
  final List<FacultyScheduleItem> upcomingThisWeek;
  final List<FacultyScheduleItem> needsFollowUp;
  final List<FacultyScheduleItem> missingContext;
}

FacultyScheduleWorkspace buildScheduleWorkspace(
  List<ScheduleEventItem> events, {
  Map<String, List<String>> initialConflicts = const <String, List<String>>{},
}) {
  final conflicts = {
    ...initialConflicts,
    ..._buildLocalConflicts(events),
  };
  final items = events
      .map(
        (event) => FacultyScheduleItem(
          event: event,
          filter: _resolveFilter(event),
          statusLabel: _statusLabel(event),
          followUpLabel: _followUpLabel(event),
          hasConflict: conflicts.containsKey(event.id),
          isMissingContext: _isMissingContext(event),
        ),
      )
      .toList(growable: false)
    ..sort((left, right) => left.event.startAt.compareTo(right.event.startAt));

  final startOfWeek = DateTime(2026, 4, 20);
  final endOfWeek = DateTime(2026, 4, 27, 23, 59);

  final upcomingThisWeek = items
      .where(
        (item) =>
            item.event.startAt.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            item.event.startAt.isBefore(endOfWeek),
      )
      .toList(growable: false);

  final needsFollowUp = items
      .where((item) => item.hasConflict || item.isMissingContext)
      .toList(growable: false);
  final missingContext = items
      .where((item) => item.isMissingContext)
      .toList(growable: false);

  return FacultyScheduleWorkspace(
    items: items,
    conflicts: conflicts,
    upcomingThisWeek: upcomingThisWeek,
    needsFollowUp: needsFollowUp,
    missingContext: missingContext,
  );
}

List<ScheduleEventItem> filterScheduleEvents(
  List<FacultyScheduleItem> items,
  Set<FacultyScheduleFilter> activeFilters,
) {
  return items
      .where((item) => activeFilters.contains(item.filter))
      .map((item) => item.event)
      .toList(growable: false);
}

FacultyScheduleFilter _resolveFilter(ScheduleEventItem event) {
  final title = event.title.toLowerCase();
  final section = event.section.toLowerCase();
  if (title.contains('section') ||
      title.contains('lab') ||
      title.contains('workshop') ||
      section.contains('section')) {
    return FacultyScheduleFilter.sections;
  }

  return switch (event.type) {
    ScheduleEventType.quiz => FacultyScheduleFilter.quizzes,
    ScheduleEventType.exam => FacultyScheduleFilter.exams,
    ScheduleEventType.task => FacultyScheduleFilter.tasks,
    ScheduleEventType.lecture => FacultyScheduleFilter.lectures,
  };
}

String _statusLabel(ScheduleEventItem event) {
  final now = DateTime(2026, 4, 23, 12);
  if (now.isAfter(event.endAt)) {
    return 'Closed';
  }
  if (now.isAfter(event.startAt) && now.isBefore(event.endAt)) {
    return 'Live';
  }
  if (event.type == ScheduleEventType.task) {
    return 'Pending Review';
  }
  return 'Published';
}

String _followUpLabel(ScheduleEventItem event) {
  if (_isMissingContext(event)) {
    return 'Needs room/link confirmation';
  }
  if (event.type == ScheduleEventType.quiz) {
    return 'Check student notification delivery';
  }
  if (event.type == ScheduleEventType.task) {
    return 'Prepare submission follow-up';
  }
  return 'Ready for delivery';
}

bool _isMissingContext(ScheduleEventItem event) {
  final normalizedLocation = event.location.trim().toLowerCase();
  return normalizedLocation.isEmpty ||
      normalizedLocation == 'online' ||
      normalizedLocation == 'room tbd';
}

Map<String, List<String>> _buildLocalConflicts(List<ScheduleEventItem> events) {
  final conflicts = <String, List<String>>{};
  for (var index = 0; index < events.length; index++) {
    for (var nextIndex = index + 1; nextIndex < events.length; nextIndex++) {
      final current = events[index];
      final next = events[nextIndex];
      final overlaps = current.startAt.isBefore(next.endAt) &&
          next.startAt.isBefore(current.endAt) &&
          current.startAt.year == next.startAt.year &&
          current.startAt.month == next.startAt.month &&
          current.startAt.day == next.startAt.day;
      if (!overlaps) {
        continue;
      }
      final reasons = <String>[
        if (current.instructor == next.instructor)
          'Instructor overlap: ${current.instructor}',
        if (current.location == next.location) 'Room overlap: ${current.location}',
      ];
      if (reasons.isEmpty) {
        continue;
      }
      conflicts.update(current.id, (value) => [...value, ...reasons], ifAbsent: () => reasons);
      conflicts.update(next.id, (value) => [...value, ...reasons], ifAbsent: () => reasons);
    }
  }
  return conflicts;
}

String scheduleDateLabel(DateTime value) {
  return DateFormat('EEE, d MMM • h:mm a').format(value);
}
