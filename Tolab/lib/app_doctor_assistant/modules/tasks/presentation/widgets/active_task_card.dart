import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../models/tasks_workspace_models.dart';

class ActiveTaskCard extends StatelessWidget {
  const ActiveTaskCard({
    super.key,
    required this.task,
    required this.onView,
    required this.onRemind,
    required this.onEdit,
  });

  final TaskWorkspaceTask task;
  final VoidCallback onView;
  final VoidCallback onRemind;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: task.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(Icons.assignment_rounded, color: task.accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${task.subjectLabel} - ${task.scopeLabel}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DashboardToneBadge(
                label: task.statusLabel,
                tone: task.statusTone,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: task.deadlineLabel, color: task.accentColor),
              AppBadge(
                label:
                    '${task.submissionsCount}/${task.totalStudents} submitted',
                color: tokens.success,
              ),
              AppBadge(
                label: '${task.pendingStudentsCount} pending',
                color: task.pendingStudentsCount == 0
                    ? tokens.primary
                    : tokens.warning,
              ),
              if (task.needsReviewCount > 0)
                AppBadge(
                  label: '${task.needsReviewCount} need review',
                  color: tokens.warning,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: task.completionRatio.clamp(0, 1),
              minHeight: 8,
              backgroundColor: task.accentColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(task.accentColor),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            task.quickInsight,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('View'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onRemind,
                  icon: const Icon(
                    Icons.notifications_active_rounded,
                    size: 18,
                  ),
                  label: const Text('Remind Students'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
