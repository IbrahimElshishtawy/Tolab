import 'package:flutter/material.dart';

import '../../core/design/app_spacing.dart';
import '../../models/doctor_assistant_models.dart';
import '../../modules/dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../modules/dashboard/presentation/widgets/dashboard_section_primitives.dart';

class QuickStatsSection extends StatelessWidget {
  const QuickStatsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.metrics,
  });

  final String title;
  final String subtitle;
  final List<WorkspaceOverviewMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: title,
      subtitle: subtitle,
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: metrics
            .map((metric) => _QuickStatCard(metric: metric))
            .toList(growable: false),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({required this.metric});

  final WorkspaceOverviewMetric metric;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 224),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: tokens.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: tokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: metric.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(metric.icon, color: metric.color, size: 20),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              metric.value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              metric.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: metric.color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              metric.caption,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
