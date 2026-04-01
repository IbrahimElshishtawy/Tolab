import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/schedule_models.dart';

// Interactive schedule board supporting month, week, and day timelines.
class ScheduleCalendarBoard extends StatelessWidget {
  const ScheduleCalendarBoard({
    super.key,
    required this.events,
    required this.view,
    required this.focusedDay,
    required this.selectedDay,
    required this.conflictMap,
    required this.onViewChanged,
    required this.onFocusedDayChanged,
    required this.onSelectedDayChanged,
    required this.onNavigate,
    required this.onEventTap,
    required this.onEventDropped,
    this.onCreateAt,
  });

  final List<ScheduleEventItem> events;
  final ScheduleCalendarView view;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<String, List<String>> conflictMap;
  final ValueChanged<ScheduleCalendarView> onViewChanged;
  final ValueChanged<DateTime> onFocusedDayChanged;
  final ValueChanged<DateTime> onSelectedDayChanged;
  final ValueChanged<int> onNavigate;
  final ValueChanged<ScheduleEventItem> onEventTap;
  final void Function(
    ScheduleEventItem event,
    DateTime newStart,
    DateTime newEnd,
  )
  onEventDropped;
  final ValueChanged<DateTime>? onCreateAt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = switch (view) {
          ScheduleCalendarView.month => DateFormat(
            'MMMM yyyy',
          ).format(focusedDay),
          ScheduleCalendarView.week => _weekRangeLabel(
            _startOfWeek(focusedDay),
          ),
          ScheduleCalendarView.day => DateFormat(
            'EEEE, d MMMM yyyy',
          ).format(selectedDay),
        };
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final isCompact =
            constraints.maxWidth < 1040 ||
            (hasBoundedHeight && constraints.maxHeight < 620);
        final cardPadding = EdgeInsets.all(
          isCompact ? AppSpacing.md : AppSpacing.lg,
        );
        final verticalGap = isCompact ? AppSpacing.md : AppSpacing.lg;
        final toolbarHeight = isCompact ? 104.0 : 120.0;
        final calendarContent = AnimatedSwitcher(
          duration: AppMotion.slow,
          switchInCurve: AppMotion.entrance,
          switchOutCurve: AppMotion.emphasized,
          child: GestureDetector(
            key: ValueKey<String>(view.name),
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() < 150) return;
              onNavigate(velocity < 0 ? 1 : -1);
            },
            child: switch (view) {
              ScheduleCalendarView.month => _MonthCalendarView(
                focusedDay: focusedDay,
                selectedDay: selectedDay,
                events: events,
                conflictMap: conflictMap,
                onFocusedDayChanged: onFocusedDayChanged,
                onSelectedDayChanged: onSelectedDayChanged,
                compact: isCompact,
                availableHeight: hasBoundedHeight
                    ? math.max(
                        220,
                        constraints.maxHeight -
                            toolbarHeight -
                            (cardPadding.vertical + verticalGap),
                      )
                    : null,
              ),
              ScheduleCalendarView.week ||
              ScheduleCalendarView.day => _TimelineCalendarView(
                events: events,
                view: view,
                focusedDay: focusedDay,
                selectedDay: selectedDay,
                conflictMap: conflictMap,
                onSelectedDayChanged: onSelectedDayChanged,
                onEventTap: onEventTap,
                onEventDropped: onEventDropped,
                onCreateAt: onCreateAt,
                compact: isCompact,
              ),
            },
          ),
        );
        final toolbar = _CalendarToolbar(
          title: title,
          view: view,
          onViewChanged: onViewChanged,
          onNavigate: onNavigate,
          onTodayPressed: () {
            final today = DateTime.now();
            onFocusedDayChanged(today);
            onSelectedDayChanged(today);
          },
          compact: isCompact,
        );

        if (view == ScheduleCalendarView.month) {
          return AppCard(
            padding: cardPadding,
            child: hasBoundedHeight
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      toolbar,
                      SizedBox(height: verticalGap),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(child: calendarContent),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      toolbar,
                      SizedBox(height: verticalGap),
                      calendarContent,
                    ],
                  ),
          );
        }

        final fallbackTimelineHeight = isCompact ? 560.0 : 680.0;

        return AppCard(
          padding: cardPadding,
          child: hasBoundedHeight
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    toolbar,
                    SizedBox(height: verticalGap),
                    Expanded(child: calendarContent),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    toolbar,
                    SizedBox(height: verticalGap),
                    SizedBox(
                      height: fallbackTimelineHeight,
                      child: calendarContent,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CalendarToolbar extends StatelessWidget {
  const _CalendarToolbar({
    required this.title,
    required this.view,
    required this.onViewChanged,
    required this.onNavigate,
    required this.onTodayPressed,
    required this.compact,
  });

  final String title;
  final ScheduleCalendarView view;
  final ValueChanged<ScheduleCalendarView> onViewChanged;
  final ValueChanged<int> onNavigate;
  final VoidCallback onTodayPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleStyle = compact
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.titleLarge;
    final iconButtonStyle = IconButton.styleFrom(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      minimumSize: Size(compact ? 32 : 36, compact ? 32 : 36),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Previous',
              style: iconButtonStyle,
              onPressed: () => onNavigate(-1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              tooltip: 'Next',
              style: iconButtonStyle,
              onPressed: () => onNavigate(1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 16,
                  vertical: compact ? 10 : 12,
                ),
              ),
              onPressed: onTodayPressed,
              child: const Text('Today'),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(title, style: titleStyle),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Wrap(
            spacing: 4,
            children: ScheduleCalendarView.values
                .map((calendarView) {
                  final selected = calendarView == view;
                  return ChoiceChip(
                    selected: selected,
                    showCheckmark: false,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(calendarView.icon, size: compact ? 14 : 16),
                    label: Text(calendarView.label),
                    onSelected: (_) => onViewChanged(calendarView),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _MonthCalendarView extends StatelessWidget {
  const _MonthCalendarView({
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.conflictMap,
    required this.onFocusedDayChanged,
    required this.onSelectedDayChanged,
    required this.compact,
    this.availableHeight,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<ScheduleEventItem> events;
  final Map<String, List<String>> conflictMap;
  final ValueChanged<DateTime> onFocusedDayChanged;
  final ValueChanged<DateTime> onSelectedDayChanged;
  final bool compact;
  final double? availableHeight;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(events);
    final derivedRowHeight = availableHeight == null
        ? (compact ? 76.0 : 92.0)
        : ((availableHeight! - 28) / 6).clamp(42.0, compact ? 76.0 : 92.0);

    return TableCalendar<ScheduleEventItem>(
      firstDay: DateTime(focusedDay.year - 2),
      lastDay: DateTime(focusedDay.year + 2, 12, 31),
      focusedDay: focusedDay,
      headerVisible: false,
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) =>
          grouped[_dayKey(day)] ?? const <ScheduleEventItem>[],
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      startingDayOfWeek: StartingDayOfWeek.monday,
      rowHeight: derivedRowHeight,
      onDaySelected: (selected, focused) {
        onSelectedDayChanged(selected);
        onFocusedDayChanged(focused);
      },
      onPageChanged: onFocusedDayChanged,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        defaultDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
        weekendTextStyle: Theme.of(context).textTheme.bodyMedium!,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.labelLarge!,
        weekendStyle: Theme.of(context).textTheme.labelLarge!,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, dayEvents) {
          if (dayEvents.isEmpty) return const SizedBox.shrink();
          final conflictCount = dayEvents
              .where((event) => conflictMap.containsKey(event.id))
              .length;
          return Padding(
            padding: EdgeInsets.only(top: compact ? 24 : 30),
            child: Align(
              alignment: Alignment.topCenter,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: compact ? 3 : 4,
                runSpacing: compact ? 3 : 4,
                children: [
                  for (final event in dayEvents.take(3))
                    Container(
                      width: compact ? 14 : 18,
                      height: compact ? 5 : 6,
                      decoration: BoxDecoration(
                        color: event.type.color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  if (dayEvents.length > 3)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '+${dayEvents.length - 3}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  if (conflictCount > 0)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineCalendarView extends StatelessWidget {
  const _TimelineCalendarView({
    required this.events,
    required this.view,
    required this.focusedDay,
    required this.selectedDay,
    required this.conflictMap,
    required this.onSelectedDayChanged,
    required this.onEventTap,
    required this.onEventDropped,
    required this.compact,
    this.onCreateAt,
  });

  final List<ScheduleEventItem> events;
  final ScheduleCalendarView view;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<String, List<String>> conflictMap;
  final ValueChanged<DateTime> onSelectedDayChanged;
  final ValueChanged<ScheduleEventItem> onEventTap;
  final bool compact;
  final void Function(
    ScheduleEventItem event,
    DateTime newStart,
    DateTime newEnd,
  )
  onEventDropped;
  final ValueChanged<DateTime>? onCreateAt;

  static const int _startHour = 7;
  static const int _endHour = 20;

  @override
  Widget build(BuildContext context) {
    final weekStart = view == ScheduleCalendarView.day
        ? _stripTime(selectedDay)
        : _startOfWeek(focusedDay);
    final visibleDays = List<DateTime>.generate(
      view == ScheduleCalendarView.day ? 1 : 7,
      (index) => weekStart.add(Duration(days: index)),
      growable: false,
    );
    final isDesktopDrag = MediaQuery.sizeOf(context).width >= 1100;

    return LayoutBuilder(
      builder: (context, constraints) {
        final leadColumnWidth = compact ? 64.0 : 76.0;
        final slotHeight = compact ? 54.0 : 64.0;
        final timelineHeight = (_endHour - _startHour + 1) * slotHeight;
        final timelineWidth = math.max<double>(
          constraints.maxWidth - leadColumnWidth,
          (visibleDays.length == 1
                  ? 360
                  : visibleDays.length * (compact ? 148 : 170))
              .toDouble(),
        );
        final dayWidth = timelineWidth / visibleDays.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: leadColumnWidth + timelineWidth,
                child: Row(
                  children: [
                    SizedBox(width: leadColumnWidth),
                    for (final day in visibleDays)
                      GestureDetector(
                        onTap: () => onSelectedDayChanged(day),
                        child: Container(
                          width: dayWidth,
                          padding: const EdgeInsets.only(
                            left: AppSpacing.sm,
                            right: AppSpacing.sm,
                            bottom: AppSpacing.md,
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEE').format(day),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: AppMotion.fast,
                                width: compact ? 36 : 42,
                                height: compact ? 36 : 42,
                                decoration: BoxDecoration(
                                  color: _sameDay(day, selectedDay)
                                      ? AppColors.primary
                                      : Theme.of(context).canvasColor,
                                  borderRadius: BorderRadius.circular(
                                    compact ? 12 : 16,
                                  ),
                                  border: Border.all(
                                    color: _sameDay(day, selectedDay)
                                        ? AppColors.primary
                                        : Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: _sameDay(day, selectedDay)
                                              ? Colors.white
                                              : null,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: leadColumnWidth + timelineWidth,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: timelineHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: leadColumnWidth,
                              child: Column(
                                children: [
                                  for (
                                    var hour = _startHour;
                                    hour <= _endHour;
                                    hour++
                                  )
                                    SizedBox(
                                      height: slotHeight,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: compact ? 2 : 4,
                                          ),
                                          child: Text(
                                            DateFormat.j().format(
                                              DateTime(2026, 1, 1, hour),
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            for (final day in visibleDays)
                              _TimelineDayColumn(
                                day: day,
                                width: dayWidth,
                                slotHeight: slotHeight,
                                startHour: _startHour,
                                endHour: _endHour,
                                events: events
                                    .where((event) => event.occursOnDay(day))
                                    .toList(growable: false),
                                conflictMap: conflictMap,
                                enableDrag: isDesktopDrag,
                                onEventTap: onEventTap,
                                onEventDropped: onEventDropped,
                                onCreateAt: onCreateAt,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TimelineDayColumn extends StatelessWidget {
  const _TimelineDayColumn({
    required this.day,
    required this.width,
    required this.slotHeight,
    required this.startHour,
    required this.endHour,
    required this.events,
    required this.conflictMap,
    required this.enableDrag,
    required this.onEventTap,
    required this.onEventDropped,
    this.onCreateAt,
  });

  final DateTime day;
  final double width;
  final double slotHeight;
  final int startHour;
  final int endHour;
  final List<ScheduleEventItem> events;
  final Map<String, List<String>> conflictMap;
  final bool enableDrag;
  final ValueChanged<ScheduleEventItem> onEventTap;
  final void Function(
    ScheduleEventItem event,
    DateTime newStart,
    DateTime newEnd,
  )
  onEventDropped;
  final ValueChanged<DateTime>? onCreateAt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Column(
            children: [
              for (var hour = startHour; hour <= endHour; hour++)
                DragTarget<_DroppedScheduleEvent>(
                  onWillAcceptWithDetails: (_) => enableDrag,
                  onAcceptWithDetails: (details) {
                    final dragged = details.data;
                    final minutes = dragged.event.startAt.minute;
                    final newStart = DateTime(
                      day.year,
                      day.month,
                      day.day,
                      hour,
                      minutes,
                    );
                    onEventDropped(
                      dragged.event,
                      newStart,
                      newStart.add(dragged.event.duration),
                    );
                  },
                  builder: (context, candidateData, rejectedData) {
                    final activeDrop = candidateData.isNotEmpty;
                    return GestureDetector(
                      onDoubleTap: onCreateAt == null
                          ? null
                          : () => onCreateAt!(
                              DateTime(day.year, day.month, day.day, hour),
                            ),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        height: slotHeight,
                        decoration: BoxDecoration(
                          color: activeDrop
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            right: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          for (final event in events)
            Positioned(
              top: _eventTop(event.startAt, startHour, slotHeight),
              left: 8,
              right: 8,
              height: math.max(_eventHeight(event.duration, slotHeight), 44),
              child: _TimelineEventBlock(
                event: event,
                conflictReasons: conflictMap[event.id] ?? const <String>[],
                enableDrag: enableDrag,
                onTap: () => onEventTap(event),
                onDroppedData: (dragged) {},
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineEventBlock extends StatelessWidget {
  const _TimelineEventBlock({
    required this.event,
    required this.conflictReasons,
    required this.enableDrag,
    required this.onTap,
    required this.onDroppedData,
  });

  final ScheduleEventItem event;
  final List<String> conflictReasons;
  final bool enableDrag;
  final VoidCallback onTap;
  final ValueChanged<_DroppedScheduleEvent> onDroppedData;

  @override
  Widget build(BuildContext context) {
    final content = _TimelineEventContent(
      event: event,
      conflictReasons: conflictReasons,
      onTap: onTap,
    );

    if (!enableDrag) {
      return content;
    }

    return LongPressDraggable<_DroppedScheduleEvent>(
      data: _DroppedScheduleEvent(event),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 220,
          child: Opacity(opacity: 0.96, child: content),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.32, child: content),
      child: content,
    );
  }
}

class _TimelineEventContent extends StatelessWidget {
  const _TimelineEventContent({
    required this.event,
    required this.conflictReasons,
    required this.onTap,
  });

  final ScheduleEventItem event;
  final List<String> conflictReasons;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = event.type.color;
    final hasConflict = conflictReasons.isNotEmpty;
    final isCompact = event.duration.inMinutes <= 60;

    return InkWell(
      borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
          border: Border.all(
            color: hasConflict
                ? AppColors.danger
                : color.withValues(alpha: 0.8),
            width: hasConflict ? 1.4 : 1,
          ),
        ),
        padding: EdgeInsets.all(isCompact ? AppSpacing.xs : AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isCompact
                  ? Theme.of(context).textTheme.labelLarge
                  : Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat.jm().format(event.startAt)} - ${DateFormat.jm().format(event.endAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              event.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (hasConflict) ...[
              const SizedBox(height: 4),
              Text(
                'Conflict',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DroppedScheduleEvent {
  const _DroppedScheduleEvent(this.event);

  final ScheduleEventItem event;
}

double _eventTop(DateTime startAt, int startHour, double slotHeight) {
  final startMinutes = ((startAt.hour - startHour) * 60) + startAt.minute;
  return math.max(0, startMinutes / 60 * slotHeight);
}

double _eventHeight(Duration duration, double slotHeight) {
  return math.max(slotHeight * (duration.inMinutes / 60), 40);
}

String _weekRangeLabel(DateTime weekStart) {
  final weekEnd = weekStart.add(const Duration(days: 6));
  if (weekStart.month == weekEnd.month) {
    return '${DateFormat('d').format(weekStart)} - ${DateFormat('d MMMM yyyy').format(weekEnd)}';
  }
  return '${DateFormat('d MMM').format(weekStart)} - ${DateFormat('d MMM yyyy').format(weekEnd)}';
}

DateTime _startOfWeek(DateTime value) {
  final stripped = _stripTime(value);
  return stripped.subtract(Duration(days: stripped.weekday - 1));
}

DateTime _stripTime(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool _sameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _dayKey(DateTime date) {
  return '${date.year}-${date.month}-${date.day}';
}

Map<String, List<ScheduleEventItem>> _groupByDay(
  List<ScheduleEventItem> events,
) {
  final grouped = <String, List<ScheduleEventItem>>{};
  for (final event in events) {
    grouped
        .putIfAbsent(_dayKey(event.startAt), () => <ScheduleEventItem>[])
        .add(event);
  }
  return grouped;
}
