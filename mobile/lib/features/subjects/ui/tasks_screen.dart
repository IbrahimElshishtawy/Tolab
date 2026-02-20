import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../redux/tasks_actions.dart';
import '../redux/tasks_state.dart';

class TasksScreen extends StatelessWidget {
  final int subjectId;
  const TasksScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, TasksState>(
      onInit: (store) => store.dispatch(fetchTasksAction(subjectId)),
      converter: (store) => store.state.tasksState,
      builder: (context, state) {
        final tasks = state.subjectTasks[subjectId] ?? [];

        if (state.isLoading) return const Center(child: CircularProgressIndicator());
        if (state.error != null) return Center(child: Text(state.error!));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              child: ListTile(
                title: Text(task.title),
                subtitle: Text('Due: ${task.dueDate.toLocal()}'),
                onTap: () {
                   // Navigate to task details or submission
                },
              ),
            );
          },
        );
      },
    );
  }
}
