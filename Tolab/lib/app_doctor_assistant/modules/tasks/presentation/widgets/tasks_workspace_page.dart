import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/app_spacing.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/state/async_state.dart';
import '../../../../models/doctor_assistant_models.dart';
import '../../state/tasks_state.dart';
import '../models/tasks_workspace_models.dart';
import 'quick_actions_section.dart';
import 'task_analytics_cards.dart';
import 'task_builder_form.dart';
import 'tasks_overview_panel.dart';

class TasksWorkspacePage extends StatefulWidget {
  const TasksWorkspacePage({
    super.key,
    required this.tasksState,
    required this.workspaceData,
    required this.subjects,
    required this.onReload,
    required this.onSaveTask,
  });

  final TasksState tasksState;
  final TasksWorkspaceData workspaceData;
  final List<TeachingSubject> subjects;
  final VoidCallback onReload;
  final ValueChanged<Map<String, dynamic>> onSaveTask;

  @override
  State<TasksWorkspacePage> createState() => _TasksWorkspacePageState();
}

class _TasksWorkspacePageState extends State<TasksWorkspacePage> {
  final GlobalKey<TaskBuilderFormState> _formKey =
      GlobalKey<TaskBuilderFormState>();
  final GlobalKey _formAnchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;
        final isStacked = constraints.maxWidth < 980;

        final overviewPanel = TasksOverviewPanel(
          data: widget.workspaceData,
          status: widget.tasksState.status,
          errorMessage: widget.tasksState.error,
          onRetry: widget.onReload,
          onCreateTask: _focusBuilder,
          onViewTask: _handleViewTask,
          onRemindStudents: _handleRemindStudents,
          onEditTask: _handleEditTask,
        );

        final builderPanel = KeyedSubtree(
          key: _formAnchorKey,
          child: TaskBuilderForm(
            key: _formKey,
            subjects: widget.subjects,
            onSaveTask: widget.onSaveTask,
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskQuickActionsSection(
              actions: widget.workspaceData.quickActions,
              onOpenRoute: (route) => context.go(route),
            ),
            const SizedBox(height: AppSpacing.lg),
            TaskAnalyticsCards(metrics: widget.workspaceData.metrics),
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: isWide
                  ? Row(
                      key: const ValueKey('wide-workspace'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: overviewPanel),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(flex: 5, child: builderPanel),
                      ],
                    )
                  : Column(
                      key: ValueKey(
                        isStacked ? 'stacked-mobile' : 'stacked-tablet',
                      ),
                      children: [
                        builderPanel,
                        const SizedBox(height: AppSpacing.lg),
                        overviewPanel,
                      ],
                    ),
            ),
            if (widget.tasksState.status == ViewStatus.loading &&
                widget.workspaceData.tasks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const LinearProgressIndicator(minHeight: 3),
            ],
          ],
        );
      },
    );
  }

  void _focusBuilder() {
    final contextForForm = _formAnchorKey.currentContext;
    if (contextForForm == null) {
      return;
    }
    Scrollable.ensureVisible(
      contextForForm,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _handleEditTask(TaskWorkspaceTask task) {
    _focusBuilder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.prefillFromTask(task);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded ${task.title} into the builder.')),
      );
    });
  }

  void _handleRemindStudents(TaskWorkspaceTask task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder prepared for ${task.pendingStudentsCount} pending students in ${task.title}.',
        ),
      ),
    );
  }

  void _handleViewTask(TaskWorkspaceTask task) {
    final route = task.needsReviewCount > 0
        ? AppRoutes.results
        : AppRoutes.students;
    context.go(route);
  }
}
