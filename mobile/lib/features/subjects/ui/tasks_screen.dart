import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../redux/tasks_actions.dart';
import '../redux/tasks_state.dart';
import '../../tasks/ui/task_details_screen.dart';
import '../../../core/ui/widgets/state_view.dart';

class TasksScreen extends StatelessWidget {
  final int subjectId;
  const TasksScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, TasksState>(
      onInit: (store) => store.dispatch(FetchTasksAction(subjectId)),
      converter: (store) => store.state.tasksState,
      builder: (context, state) {
        final tasks = state.subjectTasks[subjectId] ?? [];

        return StateView(
          isLoading: state.isLoading,
          error: state.error,
          isEmpty: tasks.isEmpty,
          onRetry: () => StoreProvider.of<AppState>(context).dispatch(FetchTasksAction(subjectId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              child: ListTile(
                title: Text(task.title),
                subtitle: Text('Due: ${task.dueDate.toLocal()}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
                  );
                },
              ),
                );
              },
            ),
        );
      },
    );
  }
}
