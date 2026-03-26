import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../state/app_state.dart';
import '../state/dashboard_state.dart';
import '../widgets/analytics_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DashboardState>(
      onInit: (store) => store.dispatch(LoadDashboardAction()),
      converter: (store) => store.state.dashboardState,
      builder: (context, state) {
        final bundle = state.bundle;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'University Overview',
              subtitle:
                  'Track academic operations, staffing, moderation, and notifications from one control surface.',
              breadcrumbs: ['Admin', 'Dashboard'],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AsyncStateView(
                status: state.status,
                errorMessage: state.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(
                  context,
                ).dispatch(LoadDashboardAction()),
                child: bundle == null
                    ? const SizedBox.shrink()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width > 1320
                              ? 4
                              : width > 940
                              ? 2
                              : 1;
                          final isWide = width > 980;

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: AppSpacing.md,
                                        mainAxisSpacing: AppSpacing.md,
                                        childAspectRatio: width > 940
                                            ? 1.5
                                            : 2.2,
                                      ),
                                  itemCount: bundle.metrics.length,
                                  itemBuilder: (context, index) {
                                    return MetricCard(
                                      metric: bundle.metrics[index],
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                if (isWide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TrendChartCard(
                                          points: bundle.trends,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: DistributionChartCard(
                                          slices: bundle.distribution,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  TrendChartCard(points: bundle.trends),
                                  const SizedBox(height: AppSpacing.md),
                                  DistributionChartCard(
                                    slices: bundle.distribution,
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.md),
                                ActivityFeedCard(
                                  activities: bundle.activities,
                                  alerts: bundle.alerts,
                                ),
                              ],
                            ),
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
