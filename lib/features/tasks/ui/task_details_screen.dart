import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../data/models.dart';
import '../redux/tasks_actions.dart';
import 'task_form_screen.dart';
import 'submissions_list_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  final int subjectId;
  const TaskDetailsScreen({super.key, required this.task, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (store) => _ViewModel.fromStore(store),
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details'),
            actions: vm.isEducator
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskFormScreen(subjectId: subjectId, task: task),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirm(context),
                    ),
                  ]
                : null,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Due: ${task.dueDate.toLocal()}', style: const TextStyle(color: Colors.red)),
                const Divider(height: 32),
                const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(task.description),
                const Spacer(),
                if (vm.isEducator)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmissionsListScreen(taskId: task.id, taskTitle: task.title),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('View Submissions'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _showUploadDialog(context),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Submit Assignment'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              StoreProvider.of<AppState>(context).dispatch(DeleteTaskAction(subjectId, task.id));
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Task'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Select your submission file'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission successful!')));
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}

class _ViewModel {
  final bool isEducator;

  _ViewModel({required this.isEducator});

  factory _ViewModel.fromStore(Store<AppState> store) {
    final role = store.state.authState.role;
    return _ViewModel(
      isEducator: role == 'doctor' || role == 'assistant',
    );
  }
}
