import 'package:flutter/material.dart';

import '../../../../../core/design/app_spacing.dart';
import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';

class TaskBuilderHero extends StatelessWidget {
  const TaskBuilderHero({
    super.key,
    required this.subjectLabel,
    required this.taskType,
    required this.deadlineLabel,
    required this.publishState,
  });

  final String subjectLabel;
  final String taskType;
  final String deadlineLabel;
  final String publishState;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          TaskBuilderHeroChip(icon: Icons.menu_book_rounded, label: subjectLabel),
          TaskBuilderHeroChip(icon: Icons.category_rounded, label: taskType),
          TaskBuilderHeroChip(icon: Icons.schedule_rounded, label: deadlineLabel),
          TaskBuilderHeroChip(icon: Icons.verified_rounded, label: publishState),
        ],
      ),
    );
  }
}

class TaskBuilderHeroChip extends StatelessWidget {
  const TaskBuilderHeroChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: tokens.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
