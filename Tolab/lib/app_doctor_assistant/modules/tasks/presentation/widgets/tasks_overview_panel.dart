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
import 'tasks_overview/tasks_overview_highlights.dart';
import 'tasks_overview/tasks_overview_insights_wrap.dart';
import 'tasks_overview/tasks_overview_section_label.dart';
import 'tasks_overview/tasks_overview_students_attention_list.dart';

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
          TasksOverviewHighlights(data: data),
          const SizedBox(height: AppSpacing.lg),
          TasksOverviewSectionLabel(title: 'Quick Insights', subtitle: data.healthSummary),
          const SizedBox(height: AppSpacing.md),
          TasksOverviewInsightsWrap(items: data.quickInsights),
          const SizedBox(height: AppSpacing.xl),
          const TasksOverviewSectionLabel(
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
          const TasksOverviewSectionLabel(
            title: 'Needs Attention',
            subtitle:
                'Urgent items surfaced from deadlines, publishing state, and review queues.',
          ),
          const SizedBox(height: AppSpacing.md),
          NeedsAttentionSection(items: data.attentionItems),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const TasksOverviewSectionLabel(
            title: 'Students Needing Attention',
            subtitle:
                'Focus the next follow-up round on learners showing weak attendance or engagement.',
          ),
          const SizedBox(height: AppSpacing.md),
          TasksOverviewStudentsAttentionList(items: data.studentAttention),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const TasksOverviewSectionLabel(
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


