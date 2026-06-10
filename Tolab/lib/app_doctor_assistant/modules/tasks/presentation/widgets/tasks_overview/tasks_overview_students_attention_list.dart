import 'package:flutter/material.dart';

import '../../../../../core/design/app_spacing.dart';
import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../models/tasks_workspace_models.dart';

class TasksOverviewStudentsAttentionList extends StatelessWidget {
  const TasksOverviewStudentsAttentionList({super.key, required this.items});

  final List<TaskWorkspaceStudentAlert> items;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    if (items.isEmpty) {
      return const DashboardSectionEmpty(
        message:
            'Student risk alerts will appear here when the workspace detects repeated late work or low engagement.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[index].name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${items[index].subjectCode} - ${items[index].reason}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        items[index].caption,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DashboardToneBadge(
                  label: items[index].tone == 'danger'
                      ? 'High priority'
                      : items[index].tone == 'warning'
                      ? 'Watch list'
                      : 'Monitor',
                  tone: items[index].tone,
                ),
              ],
            ),
          ),
          if (index != items.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
