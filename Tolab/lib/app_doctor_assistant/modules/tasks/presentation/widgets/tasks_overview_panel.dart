import 'package:flutter/material.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/state/async_state.dart';
import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../models/tasks_workspace_models.dart';
import 'active_task_card.dart';
import 'empty_tasks_state.dart';
import 'needs_attention_section.dart';
import 'recent_activity_section.dart';

class TasksOverviewPanel extends StatelessWidget {
  const TasksOverviewPanel({
    super.key,
    required this.data,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
    required this.onCreateTask,
    required this.onViewTask,
    required this.onRemindStudents,
    required this.onEditTask,
  });

  final TasksWorkspaceData data;
  final ViewStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onCreateTask;
  final ValueChanged<TaskWorkspaceTask> onViewTask;
  final ValueChanged<TaskWorkspaceTask> onRemindStudents;
  final ValueChanged<TaskWorkspaceTask> onEditTask;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Task Operations Board',
      subtitle:
          'Live assignment tracking, submission pressure, and student follow-up in one operational view.',
      trailing: DashboardToneBadge(
        label: data.healthLabel,
        tone: data.healthTone,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverviewHighlights(data: data),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel(title: 'Quick Insights', subtitle: data.healthSummary),
          const SizedBox(height: AppSpacing.md),
          _InsightsWrap(items: data.quickInsights),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Active Tasks',
            subtitle:
                'Each task exposes operational status, submission pressure, and direct actions.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (status == ViewStatus.loading && data.tasks.isEmpty)
            const LoadingStateView(lines: 4)
          else if (status == ViewStatus.failure && data.tasks.isEmpty)
            ErrorStateView(
              message: errorMessage ?? 'Unable to load tasks right now.',
              onRetry: onRetry,
            )
          else if (data.tasks.isEmpty)
            EmptyTasksState(onCreateTask: onCreateTask)
          else
            Column(
              children: [
                for (var index = 0; index < data.tasks.length; index++) ...[
                  ActiveTaskCard(
                    task: data.tasks[index],
                    onView: () => onViewTask(data.tasks[index]),
                    onRemind: () => onRemindStudents(data.tasks[index]),
                    onEdit: () => onEditTask(data.tasks[index]),
                  ),
                  if (index != data.tasks.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Needs Attention',
            subtitle:
                'Urgent items surfaced from deadlines, publishing state, and review queues.',
          ),
          const SizedBox(height: AppSpacing.md),
          NeedsAttentionSection(items: data.attentionItems),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Students Needing Attention',
            subtitle:
                'Focus the next follow-up round on learners showing weak attendance or engagement.',
          ),
          const SizedBox(height: AppSpacing.md),
          _StudentsAttentionList(items: data.studentAttention),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Recent Activity',
            subtitle:
                'Submissions, announcements, and interactions that changed the task picture recently.',
          ),
          const SizedBox(height: AppSpacing.md),
          RecentActivitySection(items: data.recentActivity),
          if (status == ViewStatus.loading && data.tasks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: tokens.surfaceAlt,
            ),
          ],
        ],
      ),
    );
  }
}

class _OverviewHighlights extends StatelessWidget {
  const _OverviewHighlights({required this.data});

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
                        _DeadlineRow(item: data.upcomingDeadlines[index]),
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
                    child: _TrendRow(point: point),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  const _DeadlineRow({required this.item});

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

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.point});

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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
      ],
    );
  }
}

class _InsightsWrap extends StatelessWidget {
  const _InsightsWrap({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: items
          .map((item) {
            return Container(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 340),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: tokens.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    color: tokens.warning,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _StudentsAttentionList extends StatelessWidget {
  const _StudentsAttentionList({required this.items});

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
