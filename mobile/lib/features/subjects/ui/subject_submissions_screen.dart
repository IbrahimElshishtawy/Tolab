import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../../tasks/redux/tasks_state.dart';
import '../../tasks/data/models.dart';
import '../../tasks/redux/tasks_actions.dart';
import '../../../core/ui/widgets/state_view.dart';
import '../../tasks/ui/submissions_list_screen.dart';

class SubjectSubmissionsScreen extends StatelessWidget {
  final int subjectId;
  const SubjectSubmissionsScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Task>>(
      onInit: (store) => store.dispatch(FetchTasksAction(subjectId)),
      converter: (store) => store.state.tasksState.subjectTasks[subjectId] ?? [],
      builder: (context, tasks) {
        if (tasks.isEmpty) {
          return const Center(child: Text('No tasks found for this subject.'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              leading: const Icon(Icons.assignment_turned_in, color: Colors.blue),
              title: Text(task.title),
              subtitle: const Text('View student submissions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmissionsListScreen(taskId: task.id, taskTitle: task.title),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
