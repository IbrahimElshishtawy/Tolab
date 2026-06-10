import 'package:flutter/material.dart';

import '../../../../../core/design/app_spacing.dart';
import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../models/tasks_workspace_models.dart';

class TasksOverviewHighlights extends StatelessWidget {
  const TasksOverviewHighlights({super.key, required this.data});

  final TasksWorkspaceData data;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: 250,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 96,
                  width: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: data.submissionRate,
                        strokeWidth: 10,
                        backgroundColor: tokens.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          tokens.primary,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(data.submissionRate * 100).round()}%',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: tokens.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              'Submitted',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: tokens.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${data.totalSubmitted} submitted - ${data.totalPending} pending',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 280,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Deadlines',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (data.upcomingDeadlines.isEmpty)
                  Text(
                    'No pending deadlines in the current mock task queue.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  )
                else
                  Column(
                    children: [
                      for (
                        var index = 0;
                        index < data.upcomingDeadlines.length;
                        index++
                      ) ...[
                        TasksOverviewDeadlineRow(item: data.upcomingDeadlines[index]),
                        if (index != data.upcomingDeadlines.length - 1)
                          const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 280,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: tokens.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Health',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DashboardToneBadge(
                  label: data.healthLabel,
                  tone: data.healthTone,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  data.healthSummary,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final point in data.completionTrend)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TasksOverviewTrendRow(point: point),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TasksOverviewDeadlineRow extends StatelessWidget {
  const TasksOverviewDeadlineRow({super.key, required this.item});

  final TaskWorkspaceDeadlineItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: tokens.warning.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.event_note_rounded,
            color: tokens.warning,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${item.subjectLabel} - ${item.deadlineLabel}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        DashboardToneBadge(
          label: '${item.pendingStudentsCount} pending',
          tone: item.tone,
        ),
      ],
    );
  }
}

class TasksOverviewTrendRow extends StatelessWidget {
  const TasksOverviewTrendRow({super.key, required this.point});

  final TaskWorkspaceTrendPoint point;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final color = switch (point.tone) {
      'danger' => tokens.danger,
      'warning' => tokens.warning,
      'success' => tokens.success,
      _ => tokens.primary,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                point.label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
              ),
            ),
            Text(
              '${(point.value * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: point.value,
            minHeight: 6,
            backgroundColor: tokens.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
