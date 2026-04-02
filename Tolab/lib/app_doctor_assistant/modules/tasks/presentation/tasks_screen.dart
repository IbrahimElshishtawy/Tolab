import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/tasks_actions.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _TasksVm>(
      converter: (store) => _TasksVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadTasksAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Tasks',
          activePath: AppRoutes.tasks,
          items: buildNavigationItems(user),
          trailing: user.hasPermission('tasks.create')
              ? AppButton(
                  label: 'New task',
                  icon: Icons.add_task_rounded,
                  onPressed: () => _showTaskSheet(context, vm.onSave),
                )
              : null,
          body: vm.items == null
              ? const LoadingStateView()
              : ListView(
                  children: vm.items!
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.title),
                              subtitle: Text(
                                '${item.referenceName} • ${item.dueDate ?? 'No deadline'}',
                              ),
                              trailing: AppBadge(label: item.ownerName),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

Future<void> _showTaskSheet(
  BuildContext context,
  void Function(Map<String, dynamic>) onSave,
) {
  final titleController = TextEditingController();
  final dueDateController = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Task title', controller: titleController),
            const SizedBox(height: 12),
            AppTextField(label: 'Due date', controller: dueDateController),
            const SizedBox(height: 12),
            AppButton(
              label: 'Save task',
              onPressed: () {
                onSave({
                  'title': titleController.text.trim(),
                  'due_date': dueDateController.text.trim(),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

class _TasksVm {
  const _TasksVm({
    required this.user,
    required this.items,
    required this.onSave,
  });

  final SessionUser? user;
  final List<TaskModel>? items;
  final void Function(Map<String, dynamic>) onSave;

  factory _TasksVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _TasksVm(
      user: getCurrentUser(store.state),
      items: store.state.tasksState.data,
      onSave: (payload) => store.dispatch(SaveTaskAction(payload)),
    );
  }
}
