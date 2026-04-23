import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';

class TaskQuickActionsSection extends StatelessWidget {
  const TaskQuickActionsSection({
    super.key,
    required this.actions,
    required this.onOpenRoute,
  });

  final List<WorkspaceQuickAction> actions;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Quick Actions',
      subtitle:
          'Jump directly into the most common doctor and assistant workflows.',
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        children: actions
            .map((action) {
              return SizedBox(
                width: 230,
                child: InkWell(
                  onTap: () => onOpenRoute(action.route),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Ink(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: tokens.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            color: tokens.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(action.icon, color: tokens.primary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          action.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: tokens.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          action.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
