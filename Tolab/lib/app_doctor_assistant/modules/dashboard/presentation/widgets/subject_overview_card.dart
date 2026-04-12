import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class SubjectOverviewCard extends StatelessWidget {
  const SubjectOverviewCard({
    super.key,
    required this.subject,
    required this.onOpenRoute,
  });

  final DashboardSubjectPreview subject;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return AppCard(
      backgroundColor: tokens.surface,
      borderColor: tokens.border,
      borderRadius: DashboardAppRadii.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: DashboardAppSpacing.sm,
            runSpacing: DashboardAppSpacing.xs,
            children: [
              _StatPill(label: subject.code, color: tokens.primary),
              _StatPill(
                label: '${subject.studentCount} students',
                color: tokens.secondary,
              ),
              _StatPill(
                label: '${subject.sectionsCount} sections',
                color: tokens.warning,
              ),
            ],
          ),
          const SizedBox(height: DashboardAppSpacing.sm),
          Text(subject.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: DashboardAppSpacing.xs),
          Text(
            '${subject.department}  ${subject.batch}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: DashboardAppSpacing.sm),
          Wrap(
            spacing: DashboardAppSpacing.sm,
            runSpacing: DashboardAppSpacing.sm,
            children: [
              for (final link in subject.routes.take(4))
                OutlinedButton(
                  onPressed: () => onOpenRoute(link.route),
                  child: Text(link.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardAppSpacing.sm,
        vertical: DashboardAppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(DashboardAppRadii.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
