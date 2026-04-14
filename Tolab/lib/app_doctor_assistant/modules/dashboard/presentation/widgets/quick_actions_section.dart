import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';
import 'dashboard_view_helpers.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.actions,
    required this.onOpenRoute,
  });

  final List<DashboardQuickAction> actions;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const DashboardSectionCard(
        title: 'Quick Actions',
        child: DashboardSectionEmpty(
          message: 'No quick actions are available for this role right now.',
        ),
      );
    }

    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Quick Actions',
      subtitle: 'Touch-friendly shortcuts into the academic workspace.',
      child: Wrap(
        spacing: DashboardAppSpacing.sm,
        runSpacing: DashboardAppSpacing.sm,
        children: actions
            .map(
              (action) => SizedBox(
                width: 220,
                child: InkWell(
                  onTap: () => onOpenRoute(action.route),
                  borderRadius: BorderRadius.circular(22),
                  child: Ink(
                    padding: const EdgeInsets.all(DashboardAppSpacing.md),
                    decoration: BoxDecoration(
                      color: dashboardToneColor(
                        tokens,
                        action.tone,
                      ).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          dashboardIconForQuickAction(action.icon),
                          color: dashboardToneColor(tokens, action.tone),
                        ),
                        const SizedBox(height: DashboardAppSpacing.sm),
                        Text(
                          action.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: tokens.textPrimary),
                        ),
                        const SizedBox(height: DashboardAppSpacing.xs),
                        Text(
                          action.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
