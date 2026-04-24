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
    final palette = context.appColors;

    return AppCard(
      backgroundColor: palette.surfaceElevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.auto_stories_rounded, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subject.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        AppBadge(label: subject.code, dense: true),
                        AppBadge(
                          label: 'الدكتور ${subject.instructor}',
                          dense: true,
                        ),
                        AppBadge(
                          label: 'المعيد ${subject.assistantName}',
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(
                label: subject.status,
                backgroundColor: accent.withValues(alpha: 0.12),
                foregroundColor: accent,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ResponsiveWrapGrid(
            minItemWidth: 120,
            spacing: AppSpacing.sm,
            children: [
              _Metric(
                label: 'التقدم',
                value: '${(subject.progress * 100).round()}%',
                accent: accent,
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
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
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
