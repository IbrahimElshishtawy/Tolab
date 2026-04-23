import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../models/tasks_workspace_models.dart';

class NeedsAttentionSection extends StatelessWidget {
  const NeedsAttentionSection({super.key, required this.items});

  final List<TaskWorkspaceAttentionItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const DashboardSectionEmpty(
        message:
            'Everything is currently on track. No urgent academic actions are waiting.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _AttentionTile(item: items[index]),
          if (index != items.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _AttentionTile extends StatelessWidget {
  const _AttentionTile({required this.item});

  final TaskWorkspaceAttentionItem item;

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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    DashboardToneBadge(label: item.subtitle, tone: item.tone),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.caption,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
