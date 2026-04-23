import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../models/tasks_workspace_models.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, required this.items});

  final List<TaskWorkspaceActivityItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const DashboardSectionEmpty(
        message:
            'Recent task activity will appear here once students and staff interact with assignments.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _RecentActivityTile(item: items[index]),
          if (index != items.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  const _RecentActivityTile({required this.item});

  final TaskWorkspaceActivityItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final color = switch (item.tone) {
      'danger' => tokens.danger,
      'warning' => tokens.warning,
      'success' => tokens.success,
      _ => tokens.primary,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            item.timeLabel,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}
