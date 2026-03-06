import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../tasks/redux/tasks_actions.dart';
import '../../tasks/ui/task_details_screen.dart';
import '../../tasks/ui/task_form_screen.dart';
import '../../../core/ui/widgets/state_view.dart';
import '../../tasks/data/models.dart';

class TasksScreen extends StatelessWidget {
  final int subjectId;
  const TasksScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (store) => store.dispatch(FetchTasksAction(subjectId)),
      converter: (store) => _ViewModel.fromStore(store, subjectId),
      builder: (context, vm) {
        return Scaffold(
          body: StateView(
            isLoading: vm.isLoading,
            error: vm.error,
            isEmpty: vm.tasks.isEmpty,
            onRetry: vm.onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.tasks.length,
              itemBuilder: (context, index) {
                final task = vm.tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text('Due: ${task.dueDate.toLocal()}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsScreen(
                            task: task,
                            subjectId: subjectId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          floatingActionButton: vm.isEducator
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskFormScreen(subjectId: subjectId),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}

class _ViewModel {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final bool isEducator;
  final VoidCallback onRefresh;

  _ViewModel({
    required this.tasks,
    required this.isLoading,
    this.error,
    required this.isEducator,
    required this.onRefresh,
  });

  factory _ViewModel.fromStore(Store<AppState> store, int subjectId) {
    final role = store.state.authState.role;
    return _ViewModel(
      tasks: store.state.tasksState.subjectTasks[subjectId] ?? [],
      isLoading: store.state.tasksState.isLoading,
      error: store.state.tasksState.error,
      isEducator: role == 'doctor' || role == 'assistant',
      onRefresh: () => store.dispatch(FetchTasksAction(subjectId)),
    );
  }
}
