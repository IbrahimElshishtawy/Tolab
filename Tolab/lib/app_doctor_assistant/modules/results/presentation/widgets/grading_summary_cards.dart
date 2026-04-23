import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../models/results_models.dart';

class GradingSummaryCards extends StatelessWidget {
  const GradingSummaryCards({
    super.key,
    required this.analytics,
  });

  final GradeAnalyticsModel analytics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _SummaryCard(
          title: 'Average score',
          value: '${analytics.averageScore.toStringAsFixed(1)}%',
          tone: const Color(0xFF2563EB),
        ),
        _SummaryCard(
          title: 'Missing grades',
          value: '${analytics.missingGrades}',
          tone: const Color(0xFFF59E0B),
        ),
        _SummaryCard(
          title: 'Attendance completion',
          value: '${analytics.attendanceCompletion}%',
          tone: const Color(0xFF14B8A6),
        ),
        _SummaryCard(
          title: 'Quiz pipeline',
          value: '${analytics.gradedQuizzes}/${analytics.gradedQuizzes + analytics.pendingQuizzes}',
          tone: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.tone,
  });

  final String title;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AppCard(
        backgroundColor: tone.withValues(alpha: 0.08),
        borderColor: tone.withValues(alpha: 0.18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
