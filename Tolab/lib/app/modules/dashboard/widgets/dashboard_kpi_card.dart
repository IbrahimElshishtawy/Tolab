import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/dashboard_models.dart';

class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({super.key, required this.metric});

  final DashboardKpiMetric metric;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(metric.tone);
    final surface = accent.withValues(alpha: 0.08);
    final trendIcon = switch (metric.direction) {
      DashboardTrendDirection.down => Icons.south_east_rounded,
      DashboardTrendDirection.neutral => Icons.east_rounded,
      DashboardTrendDirection.up => Icons.north_east_rounded,
    };

    return AppCard(
      interactive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(
                    AppConstants.mediumRadius,
                  ),
                ),
                child: Icon(_metricIcon(metric.id), color: accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.pillRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(trendIcon, size: 16, color: accent),
                          const SizedBox(width: 6),
                          Text(
                            metric.deltaLabel,
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(color: accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(metric.label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: metric.value.toDouble()),
            duration: AppMotion.slow,
            curve: AppMotion.emphasized,
            builder: (context, value, child) {
              return Text(
                NumberFormat.decimalPattern().format(value.round()),
                style: Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            metric.caption,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.slateSoft.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: AppMotion.medium,
                    curve: AppMotion.emphasized,
                    width:
                        constraints.maxWidth * metric.progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.72)],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.pillRadius,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Color _accentColor(DashboardMetricTone tone) {
  return switch (tone) {
    DashboardMetricTone.secondary => AppColors.secondary,
    DashboardMetricTone.info => AppColors.info,
    DashboardMetricTone.success => AppColors.secondary,
    DashboardMetricTone.warning => AppColors.warning,
    DashboardMetricTone.danger => AppColors.danger,
    DashboardMetricTone.primary => AppColors.primary,
  };
}

IconData _metricIcon(String id) {
  return switch (id) {
    'students' => Icons.school_rounded,
    'staff' => Icons.groups_rounded,
    'departments' => Icons.apartment_rounded,
    'tasks' => Icons.assignment_rounded,
    _ => Icons.insights_rounded,
  };
}
