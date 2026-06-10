import 'package:flutter/material.dart';

import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../../../core/design/app_spacing.dart';

class QuizBuilderHero extends StatelessWidget {
  const QuizBuilderHero({
    super.key,
    required this.subjectLabel,
    required this.scheduleLabel,
    required this.statusLabel,
    required this.totalSummary,
  });

  final String subjectLabel;
  final String scheduleLabel;
  final String statusLabel;
  final String totalSummary;

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
          HeroChip(icon: Icons.menu_book_rounded, label: subjectLabel),
          HeroChip(icon: Icons.schedule_rounded, label: scheduleLabel),
          HeroChip(icon: Icons.rule_folder_rounded, label: totalSummary),
          HeroChip(icon: Icons.verified_rounded, label: statusLabel),
        ],
      ),
    );
  }
}

class HeroChip extends StatelessWidget {
  const HeroChip({
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
