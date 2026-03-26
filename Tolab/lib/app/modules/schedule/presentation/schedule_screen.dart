import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/models/schedule_models.dart';
import '../../../shared/widgets/app_calendar_panel.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/schedule_state.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ScheduleState>(
      onInit: (store) => store.dispatch(LoadScheduleAction()),
      converter: (store) => store.state.scheduleState,
      builder: (context, state) {
        final selectedEvents = state.items.where((event) {
          return event.start.year == _selectedDay.year &&
              event.start.month == _selectedDay.month &&
              event.start.day == _selectedDay.day;
        }).toList()..sort((a, b) => a.start.compareTo(b.start));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Schedule',
              subtitle:
                  'Plan lectures, sections, and exams in a polished calendar workspace with compact operational visibility.',
              breadcrumbs: ['Admin', 'Academic', 'Schedule'],
              actions: [
                PremiumButton(
                  label: 'Sync rooms',
                  icon: Icons.meeting_room_outlined,
                  isSecondary: true,
                ),
                PremiumButton(
                  label: 'Add event',
                  icon: Icons.event_available_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _ScheduleMetric(
                  label: 'Today',
                  value: selectedEvents.length.toString(),
                  color: AppColors.primary,
                ),
                _ScheduleMetric(
                  label: 'This week',
                  value: state.items.length.toString(),
                  color: AppColors.secondary,
                ),
                const _ScheduleMetric(
                  label: 'Exam blocks',
                  value: '4',
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AsyncStateView(
                status: state.status,
                errorMessage: state.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(
                  context,
                ).dispatch(LoadScheduleAction()),
                isEmpty: state.items.isEmpty,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showSidePanel = constraints.maxWidth > 1180;

                    return showSidePanel
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: AppCalendarPanel(
                                        focusedDay: _focusedDay,
                                        selectedDay: _selectedDay,
                                        events: state.items,
                                        onDaySelected:
                                            (selectedDay, focusedDay) {
                                              setState(() {
                                                _selectedDay = selectedDay;
                                                _focusedDay = focusedDay;
                                              });
                                            },
                                        onPageChanged: (focusedDay) => setState(
                                          () => _focusedDay = focusedDay,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _TimelineStrip(events: state.items),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 4,
                                child: _DayAgendaPanel(
                                  selectedDay: _selectedDay,
                                  selectedEvents: selectedEvents,
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            children: [
                              SizedBox(
                                height: 560,
                                child: AppCalendarPanel(
                                  focusedDay: _focusedDay,
                                  selectedDay: _selectedDay,
                                  events: state.items,
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                  onPageChanged: (focusedDay) =>
                                      setState(() => _focusedDay = focusedDay),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _DayAgendaPanel(
                                selectedDay: _selectedDay,
                                selectedEvents: selectedEvents,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _TimelineStrip(events: state.items),
                            ],
                          );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DayAgendaPanel extends StatelessWidget {
  const _DayAgendaPanel({
    required this.selectedDay,
    required this.selectedEvents,
  });

  final DateTime selectedDay;
  final List<ScheduleEventModel> selectedEvents;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM').format(selectedDay),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Daily agenda, room occupancy, and instructor visibility.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (selectedEvents.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No scheduled events for this day.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: selectedEvents.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final event = selectedEvents[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppConstants.mediumRadius,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            StatusBadge(event.type.toUpperCase()),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(event.course),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat.Hm().format(event.start)} - ${DateFormat.Hm().format(event.end)}  ${event.location}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.instructor,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: 'Reschedule',
                  icon: Icons.update_rounded,
                  isSecondary: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PremiumButton(
                  label: 'Publish day',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStrip extends StatelessWidget {
  const _TimelineStrip({required this.events});

  final List<ScheduleEventModel> events;

  @override
  Widget build(BuildContext context) {
    final sorted = [...events]..sort((a, b) => a.start.compareTo(b.start));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming sequence',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final event = sorted[index];
                return Container(
                  width: 220,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('d MMM').format(event.start),
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: event.color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.location}  ${DateFormat.Hm().format(event.start)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleMetric extends StatelessWidget {
  const _ScheduleMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
