import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../models/analytics_workspace_models.dart';

class SubjectInsightsCard extends StatelessWidget {
  const SubjectInsightsCard({super.key, required this.insight});

  final AnalyticsSubjectInsight insight;

  @override
  Widget build(BuildContext context) {
    final trendColor = insight.attendanceTrend >= 0
        ? const Color(0xFF14B8A6)
        : const Color(0xFFDC2626);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        StatusBadge(insight.subjectCode),
                        StatusBadge(insight.riskLevel),
                        StatusBadge('Health ${insight.healthScore}'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      insight.subjectName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => context.go(insight.route),
                child: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _Metric(label: 'Avg grade', value: '${insight.averageGrade.toStringAsFixed(1)}%'),
              _Metric(label: 'Attendance trend', value: '${insight.attendanceTrend >= 0 ? '+' : ''}${insight.attendanceTrend}%'),
              _Metric(label: 'Engagement', value: '${insight.engagementScore}'),
              _Metric(label: 'Completion', value: '${insight.completionRate}%'),
              _Metric(label: 'Quiz entry', value: '${insight.quizParticipation}%'),
              _Metric(label: 'Pending review', value: '${insight.pendingReviewCount}'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: insight.healthScore / 100,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      trendColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                insight.healthScore.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
