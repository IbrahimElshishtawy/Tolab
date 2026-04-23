import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';

class TaskAnalyticsCards extends StatelessWidget {
  const TaskAnalyticsCards({super.key, required this.metrics});

  final List<WorkspaceOverviewMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1180
            ? (constraints.maxWidth - (AppSpacing.md * 3)) / 4
            : constraints.maxWidth >= 760
            ? (constraints.maxWidth - AppSpacing.md) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: metrics
              .map((metric) {
                return Container(
                  width: width,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: tokens.border),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadow.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: metric.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(metric.icon, color: metric.color),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        metric.value,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        metric.label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: metric.color),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        metric.caption,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}
