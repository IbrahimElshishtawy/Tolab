import 'package:flutter/material.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          subject.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        AppBadge(
                          label: subject.status,
                          backgroundColor: accent.withValues(alpha: 0.12),
                          foregroundColor: accent,
                          dense: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${subject.code} • ${subject.description}',
                      maxLines: compact ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'آخر نشاط: ${subject.lastActivityLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final infoChips = Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppBadge(label: subject.code, dense: true),
              AppBadge(label: 'الدكتور ${subject.instructor}', dense: true),
              AppBadge(label: 'المعيد ${subject.assistantName}', dense: true),
            ],
          );

          final stats = Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _MiniStatPill(
                label: 'التقدم',
                value: '${(subject.progress * 100).round()}%',
                accent: accent,
              ),
              _MiniStatPill(
                label: 'محاضرات',
                value: '$lectureCount',
                accent: AppColors.primary,
              ),
              _MiniStatPill(
                label: 'سكاشن',
                value: '${subject.sectionsCount}',
                accent: AppColors.indigo,
              ),
              _MiniStatPill(
                label: 'كويزات',
                value: '$quizCount',
                accent: AppColors.error,
              ),
              _MiniStatPill(
                label: 'شيتات',
                value: '$taskCount',
                accent: AppColors.warning,
              ),
              _MiniStatPill(
                label: 'درجة الطالب',
                value:
                    '${(subject.progress * 100 + 18).clamp(0, 100).round()}%',
                accent: AppColors.success,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleBlock,
                const SizedBox(height: AppSpacing.sm),
                infoChips,
                const SizedBox(height: AppSpacing.sm),
                stats,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: titleBlock),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoChips,
                    const SizedBox(height: AppSpacing.sm),
                    stats,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniStatPill extends StatelessWidget {
  const _MiniStatPill({
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

Color _accentColor(String hex) {
  final sanitized = hex.replaceAll('#', '');
  return Color(int.parse('FF$sanitized', radix: 16));
}
