import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../state/dashboard_state.dart';

class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({super.key, required this.metric});

  final DashboardStatCard metric;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(metric.tone);
    final isPositive = metric.deltaValue >= 0;

    return AppCard(
      interactive: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                ),
                child: Icon(_icon(metric.id), color: accent),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.secondary : AppColors.danger)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color: isPositive ? AppColors.secondary : AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      metric.deltaLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isPositive ? AppColors.secondary : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(metric.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            metric.value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(height: 1),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              widthFactor: _progressForMetric(metric.id),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withValues(alpha: 0.72), accent],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(metric.caption, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Color _accent(DashboardMetricTone tone) => switch (tone) {
    DashboardMetricTone.primary => AppColors.primary,
    DashboardMetricTone.info => AppColors.info,
    DashboardMetricTone.success => AppColors.secondary,
    DashboardMetricTone.warning => AppColors.warning,
    DashboardMetricTone.danger => AppColors.danger,
  };

  IconData _icon(String id) => switch (id) {
    'students' => Icons.school_rounded,
    'courses' => Icons.library_books_rounded,
    'approvals' => Icons.verified_rounded,
    'reviews' => Icons.rate_review_rounded,
    _ => Icons.stacked_line_chart_rounded,
  };

  double _progressForMetric(String id) => switch (id) {
    'students' => 0.88,
    'courses' => 0.76,
    'approvals' => 0.54,
    'reviews' => 0.42,
    _ => 0.64,
  };
}
