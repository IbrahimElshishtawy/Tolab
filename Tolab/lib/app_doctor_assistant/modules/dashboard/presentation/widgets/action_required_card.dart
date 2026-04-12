import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class ActionRequiredCard extends StatelessWidget {
  const ActionRequiredCard({
    super.key,
    required this.item,
    required this.onOpenRoute,
  });

  final DashboardActionRequiredItem item;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final tone = _priorityColor(tokens, item.priority);
    return AppCard(
      backgroundColor: tokens.surface,
      borderColor: tone.withValues(alpha: 0.32),
      borderRadius: DashboardAppRadii.lg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 88,
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(DashboardAppRadii.pill),
            ),
          ),
          const SizedBox(width: DashboardAppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: DashboardAppSpacing.sm,
                  runSpacing: DashboardAppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _PriorityBadge(label: item.priority, color: tone),
                  ],
                ),
                const SizedBox(height: DashboardAppSpacing.xs),
                Text(
                  item.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: DashboardAppSpacing.sm),
          FilledButton(
            onPressed: () => onOpenRoute(item.route),
            child: Text(item.cta),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(DashboardThemeTokens tokens, String priority) {
    switch (priority) {
      case 'HIGH':
        return tokens.danger;
      case 'MEDIUM':
        return tokens.warning;
      default:
        return tokens.secondary;
    }
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label, required this.color});

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
        color: color.withValues(alpha: 0.12),
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
