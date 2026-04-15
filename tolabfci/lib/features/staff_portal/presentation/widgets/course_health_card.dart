import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/staff_portal_models.dart';

class CourseHealthCard extends StatelessWidget {
  const CourseHealthCard({super.key, required this.summary});

  final CourseHealthSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('صحة المقررات', 'Course health'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      summary.summary,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _ScoreCircle(score: summary.overallScore),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...summary.metrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(metric.label)),
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 85
        ? AppColors.success
        : score >= 70
        ? AppColors.warning
        : AppColors.error;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$score',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
      ),
    );
  }
}
