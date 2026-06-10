import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/animations/app_motion.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/models/schedule_models.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/section_management_models.dart';
import '../design/section_management_tokens.dart';
import 'section_management_primitives.dart';

class SectionScheduleTab extends StatelessWidget {
  const SectionScheduleTab({
    super.key,
    required this.selectedDay,
    required this.viewMode,
    required this.visibleDays,
    required this.dayEvents,
    required this.eventsByDay,
    required this.onDaySelected,
    required this.onViewModeChanged,
  });

  final DateTime selectedDay;
  final SectionScheduleViewMode viewMode;
  final List<DateTime> visibleDays;
  final List<ScheduleEventModel> dayEvents;
  final Map<DateTime, List<ScheduleEventModel>> eventsByDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<SectionScheduleViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final deviceType = AppBreakpoints.resolve(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionPanelHeader(
                title: context.l10n.byValue('Schedule'),
                subtitle:
                    context.l10n.byValue('Day and week views with responsive event blocks, today highlighting, and semantic event colors.'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SectionSegmentChip(
                    label: context.l10n.byValue('Day view'),
                    selected: viewMode == SectionScheduleViewMode.day,
                    onTap: () => onViewModeChanged(SectionScheduleViewMode.day),
                  ),
                  SectionSegmentChip(
                    label: context.l10n.byValue('Week view'),
                    selected: viewMode == SectionScheduleViewMode.week,
                    onTap: () => onViewModeChanged(SectionScheduleViewMode.week),
                  ),
                  IconButton(
                    onPressed: () => onDaySelected(
                      selectedDay.subtract(
                        Duration(
                          days: viewMode == SectionScheduleViewMode.day ? 1 : 7,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    viewMode == SectionScheduleViewMode.day
                        ? DateFormat('EEEE, MMM d').format(selectedDay)
                        : '${DateFormat('MMM d').format(visibleDays.first)} - ${DateFormat('MMM d').format(visibleDays.last)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  IconButton(
                    onPressed: () => onDaySelected(
                      selectedDay.add(
                        Duration(
                          days: viewMode == SectionScheduleViewMode.day ? 1 : 7,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                  PremiumButton(
                    label: 'Today',
                    icon: Icons.today_rounded,
                    isSecondary: true,
                    onPressed: () => onDaySelected(DateTime.now()),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _LegendPill(label: context.l10n.byValue('Lecture'), color: AppColors.primary),
                  _LegendPill(label: context.l10n.byValue('Section'), color: AppColors.secondary),
                  _LegendPill(label: context.l10n.byValue('Exam'), color: AppColors.danger),
                  _LegendPill(label: context.l10n.byValue('Quiz'), color: AppColors.warning),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (deviceType == DeviceScreenType.mobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 74,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleDays.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final day = visibleDays[index];
                    final selected = _isSameDay(day, selectedDay);
                    return _DaySelectorChip(
                      day: day,
                      selected: selected,
                      onTap: () => onDaySelected(day),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _MobileScheduleAgenda(events: dayEvents),
            ],
          )
        else
          _ScheduleBoard(
            days: visibleDays,
            selectedDay: selectedDay,
            eventsByDay: eventsByDay,
          ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _DaySelectorChip extends StatelessWidget {
  const _DaySelectorChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(day, DateTime.now());
    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary
            : SectionManagementPalette.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : isToday
              ? AppColors.info
              : Theme.of(context).dividerColor,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE').format(day),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected
                      ? SectionManagementPalette.selectedTextOnAccent(context)
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d').format(day),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected
                      ? SectionManagementPalette.selectedTextOnAccent(context)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MobileScheduleAgenda extends StatelessWidget {
  const _MobileScheduleAgenda({required this.events});

  final List<ScheduleEventModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return AppCard(
        child: Text(
          context.l10n.byValue('No scheduled events for the selected day.'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Column(
      children: [
        for (final event in events) ...[
          _MobileEventCard(event: event),
          if (event != events.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _MobileEventCard extends StatelessWidget {
  const _MobileEventCard({required this.event});

  final ScheduleEventModel event;

  @override
  Widget build(BuildContext context) {
    final color = scheduleTypeColor(event.type);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: color.withValues(alpha: 0.06),
      borderColor: color.withValues(alpha: 0.16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(event.type.toUpperCase()),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(context.l10n.byValue(event.course), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          _MetricLine(
            label: context.l10n.byValue('Time'),
            value:
                '${DateFormat('hh:mm a').format(event.start)} - ${DateFormat('hh:mm a').format(event.end)}',
          ),
          const SizedBox(height: AppSpacing.xs),
          _MetricLine(label: context.l10n.byValue('Instructor'), value: context.l10n.byValue(event.instructor)),
          const SizedBox(height: AppSpacing.xs),
          _MetricLine(label: context.l10n.byValue('Location'), value: context.l10n.byValue(event.location)),
        ],
      ),
    );
  }
}

class _ScheduleBoard extends StatelessWidget {
  const _ScheduleBoard({
    required this.days,
    required this.selectedDay,
    required this.eventsByDay,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final Map<DateTime, List<ScheduleEventModel>> eventsByDay;

  @override
  Widget build(BuildContext context) {
    const startHour = 8;
    const totalHours = 11;
    const timeColumnWidth = 72.0;
    const boardHeight = 620.0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: timeColumnWidth),
              for (final day in days)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _isSameDay(day, DateTime.now())
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppConstants.pillRadius,
                            ),
                          ),
                          child: Text(
                            DateFormat('d MMM').format(day),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: _isSameDay(day, DateTime.now())
                                  ? SectionManagementPalette.selectedTextOnAccent(
                                      context,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: boardHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columnWidth =
                    (constraints.maxWidth - timeColumnWidth) / days.length;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Row(
                        children: [
                          const SizedBox(width: timeColumnWidth),
                          for (final day in days)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isSameDay(day, DateTime.now())
                                      ? AppColors.primary.withValues(
                                          alpha: 0.04,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.mediumRadius,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.42),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    for (var slot = 0; slot <= totalHours; slot++)
                      Positioned(
                        top: slot * (boardHeight / totalHours),
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            SizedBox(
                              width: timeColumnWidth,
                              child: Text(
                                DateFormat('hh a').format(
                                  DateTime(2026, 1, 1, startHour + slot),
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    for (var index = 0; index < days.length; index++)
                      for (final event in eventsByDay[days[index]] ?? const [])
                        Positioned(
                          left: timeColumnWidth + (columnWidth * index) + 8,
                          top: _eventTop(
                            event,
                            startHour,
                            totalHours,
                            boardHeight,
                          ),
                          width: columnWidth - 16,
                          height: _eventHeight(event, totalHours, boardHeight),
                          child: _ScheduleEventBlock(event: event),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static double _eventTop(
    ScheduleEventModel event,
    int startHour,
    int totalHours,
    double boardHeight,
  ) {
    final eventStartHour = event.start.hour + (event.start.minute / 60);
    final offset = (eventStartHour - startHour) / totalHours;
    return offset * boardHeight + 4;
  }

  static double _eventHeight(
    ScheduleEventModel event,
    int totalHours,
    double boardHeight,
  ) {
    final hours = event.end.difference(event.start).inMinutes / 60;
    return math.max((hours / totalHours) * boardHeight - 8, 58);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ScheduleEventBlock extends StatelessWidget {
  const _ScheduleEventBlock({required this.event});

  final ScheduleEventModel event;

  @override
  Widget build(BuildContext context) {
    final color = scheduleTypeColor(event.type);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight <= 72;
        return Container(
          padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: color),
              ),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.l10n.byValue(event.course),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
              ] else
                const SizedBox(height: AppSpacing.xxs),
              Text(
                '${DateFormat('hh:mm').format(event.start)} - ${DateFormat('hh:mm').format(event.end)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
