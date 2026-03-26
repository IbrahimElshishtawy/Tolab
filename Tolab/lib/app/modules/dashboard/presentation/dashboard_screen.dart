import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
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
                  'Track enrollment health, staffing, schedule movement, and moderation pressure from a single premium workspace.',
              breadcrumbs: ['Admin', 'Dashboard'],
              actions: [
                PremiumButton(
                  label: 'Export report',
                  icon: Icons.ios_share_rounded,
                  isSecondary: true,
                ),
                PremiumButton(
                  label: 'Create campaign',
                  icon: Icons.auto_awesome_rounded,
                ),
              ],
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
                          final isDesktop = constraints.maxWidth >= 1240;
                          final isWide = constraints.maxWidth >= 980;
                          final cardWidth = isDesktop
                              ? (constraints.maxWidth - (AppSpacing.md * 3)) / 4
                              : isWide
                              ? (constraints.maxWidth - AppSpacing.md) / 2
                              : constraints.maxWidth;

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimationLimiter(
                                  child: Wrap(
                                    spacing: AppSpacing.md,
                                    runSpacing: AppSpacing.md,
                                    children: [
                                      for (
                                        var index = 0;
                                        index < bundle.metrics.length;
                                        index++
                                      )
                                        AnimationConfiguration.staggeredGrid(
                                          position: index,
                                          columnCount: isDesktop
                                              ? 4
                                              : isWide
                                              ? 2
                                              : 1,
                                          duration: const Duration(
                                            milliseconds: 360,
                                          ),
                                          child: ScaleAnimation(
                                            child: SizedBox(
                                              width: cardWidth,
                                              child: MetricCard(
                                                metric: bundle.metrics[index],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                if (isWide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: Column(
                                          children: [
                                            TrendChartCard(
                                              points: bundle.trends,
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            ActivityFeedCard(
                                              activities: bundle.activities,
                                              alerts: bundle.alerts,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          children: [
                                            DistributionChartCard(
                                              slices: bundle.distribution,
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            const _QuickActionsCard(),
                                            const SizedBox(
                                              height: AppSpacing.md,
                                            ),
                                            _OperationalHighlightsCard(
                                              alerts: bundle.alerts,
                                            ),
                                          ],
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
                                  const SizedBox(height: AppSpacing.md),
                                  const _QuickActionsCard(),
                                  const SizedBox(height: AppSpacing.md),
                                  _OperationalHighlightsCard(
                                    alerts: bundle.alerts,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ActivityFeedCard(
                                    activities: bundle.activities,
                                    alerts: bundle.alerts,
                                  ),
                                ],
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

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    const actions = [
      (
        'New intake',
        'Open a student onboarding batch',
        Icons.person_add_alt_1_rounded,
      ),
      (
        'Staff invite',
        'Provision a doctor or assistant profile',
        Icons.badge_rounded,
      ),
      (
        'Schedule exam',
        'Create an assessment event block',
        Icons.event_note_rounded,
      ),
      (
        'Moderation sweep',
        'Review high-risk reported threads',
        Icons.shield_rounded,
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Most-used administrative actions for the daily control loop.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final action in actions) ...[
            _ActionTile(title: action.$1, subtitle: action.$2, icon: action.$3),
            if (action != actions.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.arrow_outward_rounded, size: 18),
        ],
      ),
    );
  }
}

class _OperationalHighlightsCard extends StatelessWidget {
  const _OperationalHighlightsCard({required this.alerts});

  final List<String> alerts;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Operations snapshot',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const StatusBadge('Stable', icon: Icons.verified_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: const [
              _MiniStat(label: 'Attendance sync', value: '98.2%'),
              _MiniStat(label: 'Open tickets', value: '12'),
              _MiniStat(label: 'Pending reviews', value: '24'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Watchlist', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          for (final alert in alerts)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.brightness_1_rounded,
                      size: 10,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(alert)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
