import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

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
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: DashboardAppSpacing.sm),
        Text(
          'Launch the next staff task without digging through menus.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: DashboardAppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 5
                : constraints.maxWidth >= 620
                ? 3
                : 2;
            final width =
                (constraints.maxWidth -
                    ((columns - 1) * DashboardAppSpacing.md)) /
                columns;

            return Wrap(
              spacing: DashboardAppSpacing.md,
              runSpacing: DashboardAppSpacing.md,
              children: [
                for (final action in actions)
                  SizedBox(
                    width: width.clamp(140, 280),
                    child: AppCard(
                      interactive: true,
                      onTap: () => onOpenRoute(action.route),
                      backgroundColor: tokens.surface,
                      borderColor: tokens.border,
                      borderRadius: DashboardAppRadii.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _actionColor(
                              tokens,
                              action.id,
                            ).withValues(alpha: 0.14),
                            child: Icon(
                              _actionIcon(action.id),
                              color: _actionColor(tokens, action.id),
                            ),
                          ),
                          const SizedBox(height: DashboardAppSpacing.sm),
                          Text(
                            action.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: DashboardAppSpacing.xs),
                          Text(
                            action.description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  IconData _actionIcon(String id) {
    switch (id) {
      case 'add_lecture':
        return Icons.co_present_rounded;
      case 'add_section':
        return Icons.science_rounded;
      case 'add_quiz':
        return Icons.quiz_rounded;
      case 'add_task':
        return Icons.assignment_rounded;
      case 'add_post':
        return Icons.campaign_rounded;
      default:
        return Icons.arrow_outward_rounded;
    }
  }

  Color _actionColor(DashboardThemeTokens tokens, String id) {
    switch (id) {
      case 'add_section':
        return tokens.secondary;
      case 'add_quiz':
        return tokens.warning;
      case 'add_task':
        return tokens.success;
      case 'add_post':
        return tokens.danger;
      default:
        return tokens.primary;
    }
  }
}
