import '../models/schedule_models.dart';
import 'schedule_state.dart';

class ScheduleOverviewMetrics {
  const ScheduleOverviewMetrics({
    required this.todayCount,
    required this.weekCount,
    required this.conflictCount,
    required this.completedCount,
    required this.plannedCount,
  });

  final int todayCount;
  final int weekCount;
  final int conflictCount;
  final int completedCount;
  final int plannedCount;
}

DateTime selectScheduleFocusedDay(ScheduleState state) {
  return _stripTime(state.focusedDay ?? DateTime.now());
}

DateTime selectScheduleSelectedDay(ScheduleState state) {
  return _stripTime(state.selectedDay ?? state.focusedDay ?? DateTime.now());
}

List<ScheduleEventItem> selectVisibleScheduleEvents(ScheduleState state) {
  final filters = state.filters;
  final conflictIds = selectConflictEventIds(state.events);
  final visible =
      state.events
          .where((event) {
            final matchesDepartment =
                filters.departmentId == null ||
                event.department == filters.departmentId;
            final matchesYear =
                filters.yearId == null || event.yearLabel == filters.yearId;
            final matchesSubject =
                filters.subjectId == null ||
                event.subjectId == filters.subjectId;
            final matchesInstructor =
                filters.instructorId == null ||
                event.instructorId == filters.instructorId ||
                event.instructor == filters.instructorId;
            final matchesSection =
                filters.sectionId == null ||
                event.sectionId == filters.sectionId;
            final matchesType = filters.eventTypes.contains(event.type);
            final matchesStatus =
                (filters.showPlanned &&
                    event.status == ScheduleEventStatus.planned) ||
                (filters.showCompleted &&
                    event.status == ScheduleEventStatus.completed);
            final matchesConflict =
                !filters.conflictsOnly || conflictIds.contains(event.id);

            return matchesDepartment &&
                matchesYear &&
                matchesSubject &&
                matchesInstructor &&
                matchesSection &&
                matchesType &&
                matchesStatus &&
                matchesConflict;
          })
          .toList(growable: false)
        ..sort((left, right) => left.startAt.compareTo(right.startAt));
  return visible;
}

List<ScheduleEventItem> selectSelectedDayEvents(ScheduleState state) {
  final selectedDay = selectScheduleSelectedDay(state);
  return selectVisibleScheduleEvents(
    state,
  ).where((event) => event.occursOnDay(selectedDay)).toList(growable: false);
}

List<ScheduleEventItem> selectWeekEvents(
  ScheduleState state, {
  DateTime? anchor,
}) {
  final weekStart = _startOfWeek(anchor ?? selectScheduleFocusedDay(state));
  final weekEnd = weekStart.add(const Duration(days: 7));
  return selectVisibleScheduleEvents(state)
      .where(
        (event) =>
            event.startAt.isBefore(weekEnd) &&
            !event.startAt.isBefore(weekStart),
      )
      .toList(growable: false);
}

ScheduleOverviewMetrics selectScheduleOverviewMetrics(ScheduleState state) {
  final today = _stripTime(DateTime.now());
  final visibleEvents = selectVisibleScheduleEvents(state);
  final weekStart = _startOfWeek(today);
  final weekEnd = weekStart.add(const Duration(days: 7));
  final todayCount = visibleEvents
      .where((event) => event.occursOnDay(today))
      .length;
  final weekCount = visibleEvents
      .where(
        (event) =>
            event.startAt.isBefore(weekEnd) &&
            !event.startAt.isBefore(weekStart),
      )
      .length;
  final conflictCount = selectConflictEventIds(visibleEvents).length;
  final completedCount = visibleEvents
      .where((event) => event.status == ScheduleEventStatus.completed)
      .length;
  final plannedCount = visibleEvents
      .where((event) => event.status == ScheduleEventStatus.planned)
      .length;
  return ScheduleOverviewMetrics(
    todayCount: todayCount,
    weekCount: weekCount,
    conflictCount: conflictCount,
    completedCount: completedCount,
    plannedCount: plannedCount,
  );
}

Map<String, List<String>> selectScheduleConflictMap(
  List<ScheduleEventItem> events,
) {
  final sorted = [...events]
    ..sort((left, right) => left.startAt.compareTo(right.startAt));
  final conflicts = <String, Set<String>>{};

  for (var index = 0; index < sorted.length; index++) {
    final current = sorted[index];
    for (var nextIndex = index + 1; nextIndex < sorted.length; nextIndex++) {
      final other = sorted[nextIndex];
      if (!_sameCalendarDay(current.startAt, other.startAt)) {
        continue;
      }
      if (!_overlaps(current, other)) {
        continue;
      }

      final reasons = <String>{
        'Time overlap',
        if (current.location == other.location) 'Room conflict',
        if (current.section == other.section) 'Section conflict',
        if (current.instructor == other.instructor) 'Instructor conflict',
      };

      conflicts.update(
        current.id,
        (value) => value..addAll(reasons),
        ifAbsent: () => reasons,
      );
      conflicts.update(
        other.id,
        (value) => value..addAll(reasons),
        ifAbsent: () => reasons,
      );
    }
  }

  return <String, List<String>>{
    for (final entry in conflicts.entries)
      entry.key: entry.value.toList(growable: false),
  };
}

Set<String> selectConflictEventIds(List<ScheduleEventItem> events) {
  return selectScheduleConflictMap(events).keys.toSet();
}

bool _overlaps(ScheduleEventItem left, ScheduleEventItem right) {
  return left.startAt.isBefore(right.endAt) &&
      right.startAt.isBefore(left.endAt);
}

bool _sameCalendarDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime _startOfWeek(DateTime value) {
  final stripped = _stripTime(value);
  return stripped.subtract(Duration(days: stripped.weekday - 1));
}

DateTime _stripTime(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
