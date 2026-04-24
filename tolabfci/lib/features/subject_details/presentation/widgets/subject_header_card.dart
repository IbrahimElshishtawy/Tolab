import 'package:flutter/material.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';

class SubjectHeaderCard extends StatelessWidget {
  const SubjectHeaderCard({
    super.key,
    required this.subject,
    required this.lectureCount,
    required this.quizCount,
    required this.taskCount,
  });

  final SubjectOverview subject;
  final int lectureCount;
  final int quizCount;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(subject.accentHex);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [accent.withValues(alpha: 0.14), context.appColors.surface],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
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
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subject.description),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          AppBadge(label: subject.code),
                          AppBadge(label: 'الدكتور ${subject.instructor}'),
                          AppBadge(label: 'المعيد ${subject.assistantName}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppBadge(
                  label: subject.status,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  foregroundColor: accent,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ResponsiveWrapGrid(
              minItemWidth: 150,
              spacing: AppSpacing.sm,
              children: [
                _Metric(
                  label: 'نسبة التقدم',
                  value: '${(subject.progress * 100).round()}%',
                ),
                _Metric(
                  label: 'المحاضرات',
                  value: '$lectureCount',
                  accent: AppColors.primary,
                ),
                _Metric(
                  label: 'الكويزات',
                  value: '$quizCount',
                  accent: AppColors.error,
                ),
                _Metric(
                  label: 'الشيتات',
                  value: '$taskCount',
                  accent: AppColors.warning,
                ),
                _Metric(
                  label: 'السكاشن',
                  value: '${subject.sectionsCount}',
                  accent: AppColors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.accent = AppColors.primary,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Color _accentColor(String hex) {
  final sanitized = hex.replaceAll('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}
