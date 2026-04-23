import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';

class EmptyTasksState extends StatelessWidget {
  const EmptyTasksState({super.key, required this.onCreateTask});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        gradient: tokens.panelGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: tokens.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.post_add_rounded,
              size: 34,
              color: tokens.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Start by creating your first assignment',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The workspace will begin tracking submissions, deadlines, and student attention once the first task is drafted or published.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onCreateTask,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Create Task'),
          ),
        ],
      ),
    );
  }
}
