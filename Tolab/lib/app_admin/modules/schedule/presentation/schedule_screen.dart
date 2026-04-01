import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../models/schedule_models.dart';
import '../state/schedule_actions.dart';
import '../state/schedule_selectors.dart';
import '../widgets/schedule_calendar_board.dart';
import '../widgets/schedule_event_card.dart';
import '../widgets/schedule_event_form_dialog.dart';
import '../widgets/schedule_filters_panel.dart';
import '../widgets/schedule_states.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _lastFeedbackMessage;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ScheduleViewModel>(
      onInit: (store) => store.dispatch(const FetchScheduleAction()),
      onDidChange: (previous, current) {
        if (!mounted) return;
        final message = current.feedbackMessage;
        if (message == null ||
            message.isEmpty ||
            message == _lastFeedbackMessage) {
          return;
        }
        _lastFeedbackMessage = message;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      converter: (store) => _ScheduleViewModel.fromStore(store),
      builder: (context, vm) {
        final store = StoreProvider.of<AppState>(context);
        final isDesktop = AppBreakpoints.isDesktop(context);
        final activeFiltersCount = vm.activeFiltersCount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Academic Schedule',
              subtitle:
                  'Manage lectures, quizzes, examinations, and academic operations from one coordinated timetable workspace for university administration.',
              breadcrumbs: const ['Admin', 'Academic', 'Schedule'],
              actions: [
                PremiumButton(
                  label: 'Refresh',
                  icon: Icons.sync_rounded,
                  isSecondary: true,
                  onPressed: () => store.dispatch(const FetchScheduleAction()),
                ),
                PremiumButton(
                  label: 'Add event',
                  icon: Icons.add_rounded,
                  onPressed: () => _openCreateDialog(
                    context,
                    store,
                    vm.lookups,
                    vm.selectedDay,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _AcademicOverviewPanel(
                  metrics: vm.metrics,
                  view: vm.view,
                  selectedDay: vm.selectedDay,
                  nextUpcomingEvent: vm.nextUpcomingEvent,
                  lookups: vm.lookups,
                  activeFiltersCount: activeFiltersCount,
                ),
                _MetricTile(
                  label: 'Today',
                  value: '${vm.metrics.todayCount}',
                  icon: Icons.today_rounded,
                  accent: AppColors.primary,
                  detail: 'Academic items scheduled today',
                ),
                _MetricTile(
                  label: 'This week',
                  value: '${vm.metrics.weekCount}',
                  icon: Icons.calendar_view_week_rounded,
                  accent: AppColors.info,
                  detail: 'Visible sessions in the current week',
                ),
                _MetricTile(
                  label: 'Conflicts',
                  value: '${vm.metrics.conflictCount}',
                  icon: Icons.warning_amber_rounded,
                  accent: AppColors.danger,
                  detail: 'Items that need timetable review',
                ),
                _MetricTile(
                  label: 'Planned',
                  value: '${vm.metrics.plannedCount}',
                  icon: Icons.fact_check_outlined,
                  accent: AppColors.secondary,
                  detail: 'Sessions still awaiting delivery',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (vm.feedbackMessage != null &&
                vm.feedbackMessage!.isNotEmpty) ...[
              _FeedbackBanner(message: vm.feedbackMessage!),
              const SizedBox(height: AppSpacing.lg),
            ],
            Expanded(
              child: Builder(
                builder: (context) {
                  if (vm.status == LoadStatus.loading &&
                      vm.visibleEvents.isEmpty) {
                    return const ScheduleLoadingState();
                  }
                  if (vm.status == LoadStatus.failure &&
                      vm.visibleEvents.isEmpty) {
                    return ScheduleErrorState(
                      message:
                          vm.errorMessage ?? 'Unable to load schedule data.',
                      onRetry: () =>
                          store.dispatch(const FetchScheduleAction()),
                    );
                  }
                  if (vm.visibleEvents.isEmpty) {
                    return ScheduleEmptyState(
                      onCreatePressed: () => _openCreateDialog(
                        context,
                        store,
                        vm.lookups,
                        vm.selectedDay,
                      ),
                    );
                  }

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: SingleChildScrollView(
                            child: ScheduleFiltersPanel(
                              filters: vm.filters,
                              lookups: vm.lookups,
                              onChanged: (filters) => store.dispatch(
                                ScheduleFiltersChangedAction(filters),
                              ),
                              onReset: () => store.dispatch(
                                const ScheduleFiltersChangedAction(
                                  ScheduleFilters(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: ScheduleCalendarBoard(
                                  events: vm.visibleEvents,
                                  view: vm.view,
                                  focusedDay: vm.focusedDay,
                                  selectedDay: vm.selectedDay,
                                  conflictMap: vm.conflictMap,
                                  onViewChanged: (view) => store.dispatch(
                                    ScheduleViewChangedAction(view),
                                  ),
                                  onFocusedDayChanged: (day) => store.dispatch(
                                    ScheduleFocusedDayChangedAction(day),
                                  ),
                                  onSelectedDayChanged: (day) => store.dispatch(
                                    ScheduleSelectedDayChangedAction(day),
                                  ),
                                  onNavigate: (direction) =>
                                      _navigateCalendar(store, vm, direction),
                                  onEventTap: (event) => _openEditDialog(
                                    context,
                                    store,
                                    vm.lookups,
                                    event,
                                  ),
                                  onEventDropped: (event, start, end) {
                                    store.dispatch(
                                      RescheduleScheduleEventAction(
                                        event: event,
                                        targetStart: start,
                                        targetEnd: end,
                                      ),
                                    );
                                  },
                                  onCreateAt: (date) => _openCreateDialog(
                                    context,
                                    store,
                                    vm.lookups,
                                    date,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        SizedBox(
                          width: 360,
                          child: _ScheduleSidePanel(
                            selectedDay: vm.selectedDay,
                            selectedEvents: vm.selectedDayEvents,
                            conflictMap: vm.conflictMap,
                            highlightedEventId: vm.highlightedEventId,
                            onEventTap: (event) => _openEditDialog(
                              context,
                              store,
                              vm.lookups,
                              event,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final compactCalendarHeight = _compactCalendarHeight(
                    context,
                    vm.view,
                  );
                  final compactSidePanelHeight = _compactSidePanelHeight(
                    context,
                  );

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScheduleFiltersPanel(
                          filters: vm.filters,
                          lookups: vm.lookups,
                          onChanged: (filters) => store.dispatch(
                            ScheduleFiltersChangedAction(filters),
                          ),
                          onReset: () => store.dispatch(
                            const ScheduleFiltersChangedAction(
                              ScheduleFilters(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (vm.view == ScheduleCalendarView.month)
                          ScheduleCalendarBoard(
                            events: vm.visibleEvents,
                            view: vm.view,
                            focusedDay: vm.focusedDay,
                            selectedDay: vm.selectedDay,
                            conflictMap: vm.conflictMap,
                            onViewChanged: (view) =>
                                store.dispatch(ScheduleViewChangedAction(view)),
                            onFocusedDayChanged: (day) => store.dispatch(
                              ScheduleFocusedDayChangedAction(day),
                            ),
                            onSelectedDayChanged: (day) => store.dispatch(
                              ScheduleSelectedDayChangedAction(day),
                            ),
                            onNavigate: (direction) =>
                                _navigateCalendar(store, vm, direction),
                            onEventTap: (event) => _openEditDialog(
                              context,
                              store,
                              vm.lookups,
                              event,
                            ),
                            onEventDropped: (event, start, end) {
                              store.dispatch(
                                RescheduleScheduleEventAction(
                                  event: event,
                                  targetStart: start,
                                  targetEnd: end,
                                ),
                              );
                            },
                            onCreateAt: (date) => _openCreateDialog(
                              context,
                              store,
                              vm.lookups,
                              date,
                            ),
                          )
                        else
                          SizedBox(
                            height: compactCalendarHeight,
                            child: ScheduleCalendarBoard(
                              events: vm.visibleEvents,
                              view: vm.view,
                              focusedDay: vm.focusedDay,
                              selectedDay: vm.selectedDay,
                              conflictMap: vm.conflictMap,
                              onViewChanged: (view) => store.dispatch(
                                ScheduleViewChangedAction(view),
                              ),
                              onFocusedDayChanged: (day) => store.dispatch(
                                ScheduleFocusedDayChangedAction(day),
                              ),
                              onSelectedDayChanged: (day) => store.dispatch(
                                ScheduleSelectedDayChangedAction(day),
                              ),
                              onNavigate: (direction) =>
                                  _navigateCalendar(store, vm, direction),
                              onEventTap: (event) => _openEditDialog(
                                context,
                                store,
                                vm.lookups,
                                event,
                              ),
                              onEventDropped: (event, start, end) {
                                store.dispatch(
                                  RescheduleScheduleEventAction(
                                    event: event,
                                    targetStart: start,
                                    targetEnd: end,
                                  ),
                                );
                              },
                              onCreateAt: (date) => _openCreateDialog(
                                context,
                                store,
                                vm.lookups,
                                date,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: compactSidePanelHeight,
                          child: _ScheduleSidePanel(
                            selectedDay: vm.selectedDay,
                            selectedEvents: vm.selectedDayEvents,
                            conflictMap: vm.conflictMap,
                            highlightedEventId: vm.highlightedEventId,
                            onEventTap: (event) => _openEditDialog(
                              context,
                              store,
                              vm.lookups,
                              event,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateCalendar(
    Store<AppState> store,
    _ScheduleViewModel vm,
    int direction,
  ) {
    final base = vm.view == ScheduleCalendarView.month
        ? vm.focusedDay
        : vm.selectedDay;
    final delta = switch (vm.view) {
      ScheduleCalendarView.month => DateTime(
        base.year,
        base.month + direction,
        base.day,
      ),
      ScheduleCalendarView.week => base.add(Duration(days: 7 * direction)),
      ScheduleCalendarView.day => base.add(Duration(days: direction)),
    };
    store.dispatch(ScheduleFocusedDayChangedAction(delta));
    if (vm.view != ScheduleCalendarView.month) {
      store.dispatch(ScheduleSelectedDayChangedAction(delta));
    }
  }

  void _openCreateDialog(
    BuildContext context,
    Store<AppState> store,
    ScheduleLookupBundle lookups,
    DateTime initialDate,
  ) {
    ScheduleEventFormDialog.show(
      context,
      lookups: lookups,
      initialDate: initialDate,
      onSubmit: (payload) {
        store.dispatch(CreateScheduleEventAction(payload: payload));
      },
    );
  }

  void _openEditDialog(
    BuildContext context,
    Store<AppState> store,
    ScheduleLookupBundle lookups,
    ScheduleEventItem event,
  ) {
    ScheduleEventFormDialog.show(
      context,
      lookups: lookups,
      initialEvent: event,
      onSubmit: (payload) {
        store.dispatch(
          UpdateScheduleEventAction(eventId: event.id, payload: payload),
        );
      },
      onDelete: () {
        store.dispatch(DeleteScheduleEventAction(eventId: event.id));
      },
    );
  }

  double _compactCalendarHeight(
    BuildContext context,
    ScheduleCalendarView view,
  ) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isMobile = AppBreakpoints.isMobile(context);
    final targetHeight = screenHeight * (isMobile ? 0.6 : 0.72);

    if (view == ScheduleCalendarView.month) {
      return targetHeight.clamp(420.0, 620.0).toDouble();
    }

    return targetHeight.clamp(520.0, 780.0).toDouble();
  }

  double _compactSidePanelHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isMobile = AppBreakpoints.isMobile(context);
    final targetHeight = screenHeight * (isMobile ? 0.42 : 0.48);
    return targetHeight.clamp(280.0, 420.0).toDouble();
  }
}

class _ScheduleViewModel {
  const _ScheduleViewModel({
    required this.status,
    required this.mutationStatus,
    required this.filters,
    required this.lookups,
    required this.view,
    required this.focusedDay,
    required this.selectedDay,
    required this.visibleEvents,
    required this.selectedDayEvents,
    required this.conflictMap,
    required this.metrics,
    required this.errorMessage,
    required this.feedbackMessage,
    required this.highlightedEventId,
    required this.nextUpcomingEvent,
    required this.activeFiltersCount,
  });

  final LoadStatus status;
  final LoadStatus mutationStatus;
  final ScheduleFilters filters;
  final ScheduleLookupBundle lookups;
  final ScheduleCalendarView view;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<ScheduleEventItem> visibleEvents;
  final List<ScheduleEventItem> selectedDayEvents;
  final Map<String, List<String>> conflictMap;
  final ScheduleOverviewMetrics metrics;
  final String? errorMessage;
  final String? feedbackMessage;
  final String? highlightedEventId;
  final ScheduleEventItem? nextUpcomingEvent;
  final int activeFiltersCount;

  factory _ScheduleViewModel.fromStore(Store<AppState> store) {
    final state = store.state.scheduleState;
    final visibleEvents = selectVisibleScheduleEvents(state);
    final now = DateTime.now();
    return _ScheduleViewModel(
      status: state.status,
      mutationStatus: state.mutationStatus,
      filters: state.filters,
      lookups: state.lookups,
      view: state.view,
      focusedDay: selectScheduleFocusedDay(state),
      selectedDay: selectScheduleSelectedDay(state),
      visibleEvents: visibleEvents,
      selectedDayEvents: selectSelectedDayEvents(state),
      conflictMap: selectScheduleConflictMap(visibleEvents),
      metrics: selectScheduleOverviewMetrics(state),
      errorMessage: state.errorMessage,
      feedbackMessage: state.feedbackMessage,
      highlightedEventId: state.highlightedEventId,
      nextUpcomingEvent: visibleEvents.cast<ScheduleEventItem?>().firstWhere(
        (event) => event!.endAt.isAfter(now),
        orElse: () => null,
      ),
      activeFiltersCount: _activeFiltersCount(state.filters),
    );
  }
}

class _AcademicOverviewPanel extends StatelessWidget {
  const _AcademicOverviewPanel({
    required this.metrics,
    required this.view,
    required this.selectedDay,
    required this.nextUpcomingEvent,
    required this.lookups,
    required this.activeFiltersCount,
  });

  final ScheduleOverviewMetrics metrics;
  final ScheduleCalendarView view;
  final DateTime selectedDay;
  final ScheduleEventItem? nextUpcomingEvent;
  final ScheduleLookupBundle lookups;
  final int activeFiltersCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 520),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.info.withValues(alpha: 0.09),
            Theme.of(context).cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoPill(
                icon: Icons.school_rounded,
                label: 'Academic timetable',
                accent: AppColors.primary,
              ),
              _InfoPill(
                icon: view.icon,
                label: '${view.label} view',
                accent: AppColors.info,
              ),
              _InfoPill(
                icon: Icons.tune_rounded,
                label: activeFiltersCount == 0
                    ? 'All filters open'
                    : '$activeFiltersCount active filters',
                accent: activeFiltersCount == 0
                    ? AppColors.secondary
                    : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Academic coordination overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Track daily delivery, weekly load, and timetable risks while keeping departments, sections, and instructors aligned.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _LegendChip(
                label: '${lookups.departments.length} departments',
                valueColor: AppColors.primary,
              ),
              _LegendChip(
                label: '${lookups.sections.length} sections',
                valueColor: AppColors.info,
              ),
              _LegendChip(
                label: '${lookups.instructors.length} instructors',
                valueColor: AppColors.secondary,
              ),
              _LegendChip(
                label: '${metrics.completedCount} completed',
                valueColor: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected academic day',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(selectedDay),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  nextUpcomingEvent == null
                      ? 'No upcoming item is visible in the current scope.'
                      : 'Next item: ${nextUpcomingEvent!.title} at ${DateFormat.jm().format(nextUpcomingEvent!.startAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.detail,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            accent.withValues(alpha: 0.12),
            Theme.of(context).cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 96,
            height: 5,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSidePanel extends StatelessWidget {
  const _ScheduleSidePanel({
    required this.selectedDay,
    required this.selectedEvents,
    required this.conflictMap,
    required this.highlightedEventId,
    required this.onEventTap,
  });

  final DateTime selectedDay;
  final List<ScheduleEventItem> selectedEvents;
  final Map<String, List<String>> conflictMap;
  final String? highlightedEventId;
  final ValueChanged<ScheduleEventItem> onEventTap;

  @override
  Widget build(BuildContext context) {
    final conflictEvents = selectedEvents
        .where((event) => conflictMap.containsKey(event.id))
        .toList(growable: false);
    final lectureCount = selectedEvents
        .where((event) => event.type == ScheduleEventType.lecture)
        .length;
    final assessmentCount = selectedEvents
        .where(
          (event) =>
              event.type == ScheduleEventType.quiz ||
              event.type == ScheduleEventType.exam,
        )
        .length;
    final taskCount = selectedEvents
        .where((event) => event.type == ScheduleEventType.task)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _InfoPill(
                    icon: Icons.event_note_rounded,
                    label: 'Academic day brief',
                    accent: AppColors.primary,
                  ),
                  if (conflictEvents.isNotEmpty)
                    _InfoPill(
                      icon: Icons.priority_high_rounded,
                      label: '${conflictEvents.length} alerts',
                      accent: AppColors.danger,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                DateFormat('EEEE, d MMMM').format(selectedDay),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${selectedEvents.length} scheduled items are mapped to this day.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _DayStatChip(
                    label: 'Lectures',
                    value: lectureCount.toString(),
                  ),
                  _DayStatChip(
                    label: 'Assessments',
                    value: assessmentCount.toString(),
                  ),
                  _DayStatChip(label: 'Tasks', value: taskCount.toString()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                'Day agenda',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${selectedEvents.length} item${selectedEvents.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: selectedEvents.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      AppConstants.cardRadius,
                    ),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    'No academic items are scheduled for the selected day. Choose another date or add a new timetable entry.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  itemCount: selectedEvents.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final event = selectedEvents[index];
                    return ScheduleEventCard(
                      event: event,
                      compact: true,
                      conflictReasons:
                          conflictMap[event.id] ?? const <String>[],
                      highlighted: event.id == highlightedEventId,
                      onTap: () => onEventTap(event),
                      onEdit: () => onEventTap(event),
                    );
                  },
                ),
        ),
        if (conflictEvents.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${conflictEvents.length} timetable conflict item${conflictEvents.length == 1 ? '' : 's'} require review for this day.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.valueColor});

  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: valueColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DayStatChip extends StatelessWidget {
  const _DayStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$value ',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextSpan(text: label),
          ],
        ),
      ),
    );
  }
}

int _activeFiltersCount(ScheduleFilters filters) {
  var count = 0;
  if (filters.departmentId != null) count++;
  if (filters.yearId != null) count++;
  if (filters.subjectId != null) count++;
  if (filters.instructorId != null) count++;
  if (filters.sectionId != null) count++;
  if (!filters.showPlanned) count++;
  if (!filters.showCompleted) count++;
  if (filters.conflictsOnly) count++;
  if (filters.eventTypes.length != ScheduleEventType.values.length) count++;
  return count;
}
