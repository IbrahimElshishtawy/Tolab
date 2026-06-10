import 'package:flutter/material.dart';

import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../../../core/design/app_spacing.dart';

class SectionBuilderHero extends StatelessWidget {
  const SectionBuilderHero({
    super.key,
    required this.subjectLabel,
    required this.sectionType,
    required this.scheduleLabel,
    required this.publishState,
  });

  final String subjectLabel;
  final String sectionType;
  final String scheduleLabel;
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
          HeroChip(icon: Icons.menu_book_rounded, label: subjectLabel),
          HeroChip(icon: Icons.widgets_rounded, label: sectionType),
          HeroChip(icon: Icons.schedule_rounded, label: scheduleLabel),
          HeroChip(icon: Icons.verified_rounded, label: publishState),
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
