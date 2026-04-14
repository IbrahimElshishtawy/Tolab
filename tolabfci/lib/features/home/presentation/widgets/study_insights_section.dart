import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../providers/home_providers.dart';

class StudyInsightsSection extends StatelessWidget {
  const StudyInsightsSection({super.key, required this.model});

  final StudentStudyInsightsModel model;

  @override
  Widget build(BuildContext context) {
    final totalTasks = model.completedTasks + model.pendingTasks;
    final progress = totalTasks == 0 ? 0.0 : model.completedTasks / totalTasks;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Study insights',
            subtitle: 'A quick read on momentum, completion, and engagement.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            model.summary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceAlt,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _InsightMetric(
                label: 'Completed',
                value: '${model.completedTasks}',
              ),
              _InsightMetric(label: 'Pending', value: '${model.pendingTasks}'),
              _InsightMetric(
                label: 'Viewed lectures',
                value: '${model.viewedLectures}',
              ),
              _InsightMetric(
                label: 'Engagement',
                value: '${(model.engagementScore * 100).round()}%',
                caption: model.engagementLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightMetric extends StatelessWidget {
  const _InsightMetric({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 22),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(caption!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
