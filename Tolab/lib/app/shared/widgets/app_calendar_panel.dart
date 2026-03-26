import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/colors/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/spacing/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../models/schedule_models.dart';

class AppCalendarPanel extends StatelessWidget {
  const AppCalendarPanel({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<ScheduleEventModel> events;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          TableCalendar<ScheduleEventModel>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronIcon: const Icon(Icons.chevron_left_rounded),
              rightChevronIcon: const Icon(Icons.chevron_right_rounded),
              titleTextStyle: Theme.of(context).textTheme.titleMedium!,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: Theme.of(context).textTheme.labelMedium!,
              weekendStyle: Theme.of(context).textTheme.labelMedium!,
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.info],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              markersMaxCount: 3,
              markersAnchor: 1.1,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, dayEvents) {
                if (dayEvents.isEmpty) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Wrap(
                    spacing: 3,
                    children: dayEvents.take(3).map((event) {
                      final scheduleEvent = event as ScheduleEventModel;
                      return Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color: scheduleEvent.color,
                          borderRadius: BorderRadius.circular(
                            AppConstants.pillRadius,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            eventLoader: (day) => events.where((event) {
              return event.start.year == day.year &&
                  event.start.month == day.month &&
                  event.start.day == day.day;
            }).toList(),
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: const [
                _CalendarLegend(label: 'Lecture', color: AppColors.primary),
                _CalendarLegend(label: 'Section', color: AppColors.secondary),
                _CalendarLegend(label: 'Exam', color: AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppConstants.pillRadius),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
