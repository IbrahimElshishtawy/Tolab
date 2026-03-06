import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../../tasks/data/models.dart';
import '../../../tasks/redux/tasks_actions.dart';
import '../../../../core/localization/localization_manager.dart';

class TasksScreen extends StatelessWidget {
  final int subjectId;
  const TasksScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('tasks'.tr())),
      body: StoreConnector<AppState, List<Task>>(
        onInit: (store) => store.dispatch(FetchTasksAction(subjectId)),
        converter: (store) => store.state.tasksState.subjectTasks[subjectId] ?? [],
        builder: (context, tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No tasks available now', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Week ${task.weekNumber}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          Text(task.ownerName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(task.description, style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (task.pdfUrl != null) ...[
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Open PDF'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload feature coming soon')));
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Submission'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
