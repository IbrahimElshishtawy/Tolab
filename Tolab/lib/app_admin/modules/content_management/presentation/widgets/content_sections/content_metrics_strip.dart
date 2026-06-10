import 'package:flutter/material.dart';

import 'package:tolab_fci/app_admin/core/colors/app_colors.dart';
import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/core/widgets/app_card.dart';
import 'package:tolab_fci/app_admin/modules/content_management/state/content_selectors.dart';

class ContentMetricsStrip extends StatelessWidget {
  const ContentMetricsStrip({super.key, required this.metrics});

  final ContentDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        ContentMetricCard(
          label: 'Total content',
          value: '${metrics.totalContent}',
          detail: 'Live and scheduled assets',
          icon: Icons.dashboard_customize_rounded,
          color: AppColors.primary,
        ),
        ContentMetricCard(
          label: 'Assessments',
          value: '${metrics.totalAssessments}',
          detail: 'Quizzes, tasks, and exams',
          icon: Icons.fact_check_rounded,
          color: AppColors.info,
        ),
        ContentMetricCard(
          label: 'Pending submissions',
          value: '${metrics.pendingSubmissions}',
          detail: 'Need grading or student action',
          icon: Icons.pending_actions_rounded,
          color: AppColors.warning,
        ),
        ContentMetricCard(
          label: 'Avg engagement',
          value: '${(metrics.averageEngagementRate * 100).toStringAsFixed(0)}%',
          detail: 'Based on views and completion',
          icon: Icons.trending_up_rounded,
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class ContentMetricCard extends StatelessWidget {
  const ContentMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: AppCard(
        interactive: true,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
