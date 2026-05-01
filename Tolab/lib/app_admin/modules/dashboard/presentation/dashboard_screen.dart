import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../shared/enums/load_status.dart';
import '../../../state/app_state.dart';
import '../state/dashboard_state.dart';
import '../widgets/dashboard_chart_cards.dart';
import '../widgets/dashboard_filter_bar.dart';
import '../widgets/dashboard_kpi_card.dart';
import '../widgets/dashboard_panels.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _started = false;
  Store<AppState>? _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final store = StoreProvider.of<AppState>(context, listen: false);
    _store = store;
    store
      ..dispatch(const LoadDashboardRequestedAction())
      ..dispatch(const StartDashboardRealtimeAction());
  }

  @override
  void dispose() {
    _store?.dispatch(const StopDashboardRealtimeAction());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DashboardState>(
      distinct: true,
      converter: (store) => store.state.dashboardState,
      onDidChange: (previous, current) {
        final feedback = current.feedbackMessage;
        if (feedback != null && feedback != previous?.feedbackMessage) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(feedback)));
          StoreProvider.of<AppState>(
            context,
            listen: false,
          ).dispatch(const DashboardFeedbackDismissedAction());
        }

        final searchError = current.searchErrorMessage;
        if (searchError != null &&
            searchError != previous?.searchErrorMessage) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(searchError),
                duration: const Duration(seconds: 3),
              ),
            );
        }
      },
      builder: (context, state) {
        final bundle = state.bundle;
        if (bundle == null && state.status == LoadStatus.loading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (bundle == null) {
          return _DashboardFailureState(
            message:
                state.errorMessage ?? 'Unable to load the admin dashboard.',
            onRetry: () => StoreProvider.of<AppState>(
              context,
              listen: false,
            ).dispatch(const LoadDashboardRequestedAction()),
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: () async {
            StoreProvider.of<AppState>(
              context,
              listen: false,
            ).dispatch(const LoadDashboardRequestedAction());
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              DashboardFilterBar(
                bundle: bundle,
                filters: state.filters,
                searchQuery: state.searchQuery,
                searchScope: state.searchScope,
                searchStatus: state.searchStatus,
                lastRealtimeSignalAt: state.lastRealtimeSignalAt,
                onSearchChanged: (value) => StoreProvider.of<AppState>(
                  context,
                  listen: false,
                ).dispatch(DashboardSearchQueryChangedAction(value)),
                onScopeChanged: (scope) => StoreProvider.of<AppState>(
                  context,
                  listen: false,
                ).dispatch(DashboardSearchScopeChangedAction(scope)),
                onTimeRangeChanged: (range) => StoreProvider.of<AppState>(
                  context,
                  listen: false,
                ).dispatch(DashboardTimeRangeChangedAction(range)),
              ),
              const SizedBox(height: AppSpacing.lg),
              RecentActivityTableCard(rows: bundle.activityRows),
              const SizedBox(height: AppSpacing.lg),
              DashboardSearchResultsPanel(
                query: state.searchQuery,
                results: state.searchResults,
                searchStatus: state.searchStatus,
                onEntrySelected: (entry) => context.go(
                  entry.role == DashboardDirectoryRole.student
                      ? RoutePaths.students
                      : RoutePaths.staff,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AnimatedKpiGrid(stats: bundle.stats),
              const SizedBox(height: AppSpacing.lg),
              _ResponsiveCharts(bundle: bundle),
              const SizedBox(height: AppSpacing.lg),
              _AdaptiveOperationsRow(
                bundle: bundle,
                onQuickActionSelected: (action) {
                  final route = action.route;
                  if (route.isEmpty) {
                    StoreProvider.of<AppState>(context, listen: false).dispatch(
                      DashboardFeedbackShownAction(
                        '${action.label} is ready for the connected backend flow.',
                      ),
                    );
                    return;
                  }
                  context.go(route);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedKpiGrid extends StatelessWidget {
  const _AnimatedKpiGrid({required this.stats});

  final List<DashboardStatCard> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1260
            ? 4
            : width >= 760
            ? 2
            : 1;
        final cardWidth = columns == 1
            ? width
            : (width - (AppSpacing.md * (columns - 1))) / columns;

        return AnimationLimiter(
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (var index = 0; index < stats.length; index++)
                AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: columns,
                  duration: const Duration(milliseconds: 320),
                  child: FadeInAnimation(
                    child: SlideAnimation(
                      verticalOffset: 18,
                      child: SizedBox(
                        width: cardWidth,
                        child: DashboardKpiCard(metric: stats[index]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ResponsiveCharts extends StatelessWidget {
  const _ResponsiveCharts({required this.bundle});

  final DashboardBundle bundle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < 980) {
          return Column(
            children: [
              StudentsCoursesTrendCard(points: bundle.trendPoints),
              const SizedBox(height: AppSpacing.md),
              EnrollmentDepartmentBarCard(points: bundle.departmentStats),
              const SizedBox(height: AppSpacing.md),
              PendingApprovalsDonutCard(slices: bundle.taskBreakdown),
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: StudentsCoursesTrendCard(points: bundle.trendPoints),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 4,
                  child: PendingApprovalsDonutCard(
                    slices: bundle.taskBreakdown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            EnrollmentDepartmentBarCard(points: bundle.departmentStats),
          ],
        );
      },
    );
  }
}

class _AdaptiveOperationsRow extends StatelessWidget {
  const _AdaptiveOperationsRow({
    required this.bundle,
    required this.onQuickActionSelected,
  });

  final DashboardBundle bundle;
  final ValueChanged<DashboardQuickAction> onQuickActionSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return Column(
            children: [
              QuickActionsPanel(
                actions: bundle.quickActions,
                onActionSelected: onQuickActionSelected,
              ),
              const SizedBox(height: AppSpacing.md),
              DashboardAlertsPanel(alerts: bundle.alerts),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: QuickActionsPanel(
                actions: bundle.quickActions,
                onActionSelected: onQuickActionSelected,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 4,
              child: DashboardAlertsPanel(alerts: bundle.alerts),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardFailureState extends StatelessWidget {
  const _DashboardFailureState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Dashboard unavailable',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
