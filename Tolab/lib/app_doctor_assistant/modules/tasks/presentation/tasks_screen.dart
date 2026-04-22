import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/models/content_models.dart';
import '../../../state/app_state.dart';
import '../state/tasks_actions.dart';
import '../state/tasks_state.dart';
import '../../../presentation/widgets/doctor_assistant_content_form.dart';

class TasksScreen extends DoctorAssistantContentFormScreen<TaskModel> {
  const TasksScreen({super.key})
    : super(
        route: AppRoutes.tasks,
        pageTitle: 'Add Task',
        pageSubtitle:
            'Publish a task or assignment milestone using the shared admin-style form treatment.',
        primaryActionLabel: 'Save task',
        subjectHint: 'Algorithms / Software Engineering / AI',
        scopeHint: 'All lecture groups / project teams / section D1',
        scheduleHint: 'Due Thu 17 Apr • 23:59',
        stateSelector: _stateSelector,
        onLoad: _onLoad,
        onSave: _onSave,
        itemTitle: _itemTitle,
        itemSubtitle: _itemSubtitle,
        itemMeta: _itemMeta,
        itemStatusLabel: _itemStatus,
        itemIcon: Icons.assignment_rounded,
        existingPanelTitle: 'Existing tasks',
        existingPanelSubtitle:
            'Assignments and follow-up tasks stay visible while you add the next local draft.',
        emptyTitle: 'No tasks yet',
        emptySubtitle:
            'Add a mock assignment to activate the task flow.',
      );
}

TasksState _stateSelector(DoctorAssistantAppState state) => state.tasksState;

void _onLoad(Store<DoctorAssistantAppState> store) =>
    store.dispatch(LoadTasksAction());

void _onSave(Store<DoctorAssistantAppState> store, Map<String, dynamic> payload) =>
    store.dispatch(SaveTaskAction(payload));

String _itemTitle(TaskModel item) => item.title;

String _itemSubtitle(TaskModel item) =>
    '${item.ownerName} - ${item.referenceName}';

String _itemMeta(TaskModel item) => item.dueDate ?? 'No due date configured';

String _itemStatus(TaskModel item) => item.isPublished ? 'Published' : 'Draft';
