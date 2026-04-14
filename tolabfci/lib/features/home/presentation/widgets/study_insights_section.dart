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
    final palette = context.appColors;
    final totalTasks = model.completedTasks + model.pendingTasks;
    final progress = totalTasks == 0 ? 0.0 : model.completedTasks / totalTasks;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'الدعم الأكاديمي الذكي',
            subtitle: 'مؤشرات سريعة تساعدك على فهم مستواك وما يحتاج متابعة.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            model.headline,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(model.summary, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: palette.surfaceAlt,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _InsightMetric(
                label: 'المكتمل',
                value: '${model.completedTasks}',
              ),
              _InsightMetric(label: 'المعلق', value: '${model.pendingTasks}'),
              _InsightMetric(
                label: 'المشاهد',
                value: '${model.viewedLectures}',
              ),
              _InsightMetric(
                label: 'التفاعل',
                value: '${(model.engagementScore * 100).round()}%',
                caption: model.engagementLabel,
              ),
            ],
          ),
          if (model.tips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            ...model.tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.tips_and_updates_outlined,
                        size: 18,
                        color: AppColors.indigo,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        tip,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    final palette = context.appColors;

    return Container(
      width: 132,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
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
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
