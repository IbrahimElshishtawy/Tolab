import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../state/app_state.dart';
import '../models/dashboard_models.dart';
import '../state/dashboard_state.dart';
import '../widgets/dashboard_chart_cards.dart';
import '../widgets/dashboard_filter_bar.dart';
import '../widgets/dashboard_kpi_card.dart';
import '../widgets/dashboard_panels.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DashboardState>(
      onInit: (store) => store.dispatch(const LoadDashboardRequestedAction()),
      distinct: true,
      converter: (store) => store.state.dashboardState,
      onDidChange: (previous, current) {
        final feedbackMessage = current.feedbackMessage;
        if (feedbackMessage == null ||
            feedbackMessage == previous?.feedbackMessage) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(feedbackMessage)));

        StoreProvider.of<AppState>(
          context,
          listen: false,
        ).dispatch(const DashboardFeedbackDismissedAction());
      },
      builder: (context, state) {
        final bundle = state.bundle;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'University Overview',
              subtitle:
                  'A polished command surface for enrollment health, staff delivery, moderation risk, and upcoming academic workload.',
              breadcrumbs: ['Admin', 'Dashboard'],
            ),
            const SizedBox(height: AppSpacing.lg),
            DashboardFilterBar(
              filters: state.filters,
              lookups: bundle?.lookups ?? const DashboardLookups(),
              onFilterChanged: (field, value) =>
                  StoreProvider.of<AppState>(context, listen: false).dispatch(
                    DashboardFilterChangedAction(field: field, value: value),
                  ),
              onReset: () => StoreProvider.of<AppState>(
                context,
                listen: false,
              ).dispatch(const DashboardFiltersResetAction()),
              isRefreshing: state.refreshStatus == LoadStatus.loading,
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AsyncStateView(
                status: state.status,
                errorMessage: state.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(
                  context,
                  listen: false,
                ).dispatch(const LoadDashboardRequestedAction()),
                isEmpty: bundle?.isEmpty ?? false,
                emptyTitle: 'No dashboard data for this filter set',
                emptySubtitle:
                    'Try widening the semester or department scope to surface academic activity again.',
                child: bundle == null
                    ? const SizedBox.shrink()
                    : _DashboardContent(bundle: bundle),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.bundle});

  final DashboardBundle bundle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1280;
        final isTablet = width >= 760;
        final kpiWidth = isDesktop
            ? (width - (AppSpacing.md * 3)) / 4
            : isTablet
            ? (width - AppSpacing.md) / 2
            : width;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimationLimiter(
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (var index = 0; index < bundle.kpis.length; index++)
                      AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 320),
                        columnCount: isDesktop
                            ? 4
                            : isTablet
                            ? 2
                            : 1,
                        child: FadeInAnimation(
                          child: SizedBox(
                            width: kpiWidth,
                            child: DashboardKpiCard(metric: bundle.kpis[index]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (isDesktop)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: EnrollmentTrendCard(
                            points: bundle.enrollmentTrend,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 5,
                          child: StudentDistributionCard(
                            slices: bundle.studentDistribution,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AttendanceOverviewCard(
                            points: bundle.attendanceOverview,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: StaffPerformanceCard(
                            points: bundle.staffPerformance,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: RecentActivityPanel(
                            items: bundle.recentActivity,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              QuickActionsPanel(
                                actions: bundle.quickActions,
                                onActionSelected: (action) =>
                                    _handleQuickAction(context, action),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ModerationAlertsPanel(
                                items: bundle.moderationAlerts,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ScheduleSummaryPanel(
                                items: bundle.scheduleSummary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else ...[
                EnrollmentTrendCard(points: bundle.enrollmentTrend),
                const SizedBox(height: AppSpacing.md),
                StudentDistributionCard(slices: bundle.studentDistribution),
                const SizedBox(height: AppSpacing.md),
                AttendanceOverviewCard(points: bundle.attendanceOverview),
                const SizedBox(height: AppSpacing.md),
                StaffPerformanceCard(points: bundle.staffPerformance),
                const SizedBox(height: AppSpacing.md),
                QuickActionsPanel(
                  actions: bundle.quickActions,
                  onActionSelected: (action) =>
                      _handleQuickAction(context, action),
                ),
                const SizedBox(height: AppSpacing.md),
                ModerationAlertsPanel(items: bundle.moderationAlerts),
                const SizedBox(height: AppSpacing.md),
                ScheduleSummaryPanel(items: bundle.scheduleSummary),
                const SizedBox(height: AppSpacing.md),
                RecentActivityPanel(items: bundle.recentActivity),
              ],
            ],
          ),
        );
      },
    );
  }

  void _handleQuickAction(BuildContext context, DashboardQuickAction action) {
    if (action.route.isNotEmpty) {
      context.go(action.route);
      return;
    }
    StoreProvider.of<AppState>(context, listen: false).dispatch(
      DashboardFeedbackShownAction('${action.label} is ready to be wired.'),
    );
  }
}
