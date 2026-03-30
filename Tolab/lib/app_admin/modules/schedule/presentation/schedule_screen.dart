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
        final isMobile = AppBreakpoints.isMobile(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Schedule',
              subtitle:
                  'Coordinate lectures, quizzes, exams, and academic tasks through a responsive calendar workspace built for mobile, desktop, and web administration.',
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
                _MetricTile(
                  label: 'Today',
                  value: '${vm.metrics.todayCount}',
                  accent: AppColors.primary,
                  detail: 'Events scheduled for today',
                ),
                _MetricTile(
                  label: 'This week',
                  value: '${vm.metrics.weekCount}',
                  accent: AppColors.info,
                  detail: 'Visible sessions in current week',
                ),
                _MetricTile(
                  label: 'Conflicts',
                  value: '${vm.metrics.conflictCount}',
                  accent: AppColors.danger,
                  detail: 'Items requiring timetable action',
                ),
                _MetricTile(
                  label: 'Completed',
                  value: '${vm.metrics.completedCount}',
                  accent: AppColors.secondary,
                  detail: 'Events already delivered',
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

                  return SingleChildScrollView(
                    child: Column(
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
                        SizedBox(
                          height: isMobile ? 620 : 700,
                          child: ScheduleCalendarBoard(
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
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ScheduleSidePanel(
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

  factory _ScheduleViewModel.fromStore(Store<AppState> store) {
    final state = store.state.scheduleState;
    final visibleEvents = selectVisibleScheduleEvents(state);
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
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
    required this.detail,
  });

  final String label;
  final String value;
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
              Text(
                DateFormat('EEEE, d MMMM').format(selectedDay),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${selectedEvents.length} events selected for this day.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
                    'No events are scheduled for the selected day.',
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
                    '${conflictEvents.length} conflict items need review for this day.',
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
