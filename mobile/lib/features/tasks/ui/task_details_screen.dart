import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/app_state.dart';
import '../data/models.dart';
import '../redux/tasks_actions.dart';
import '../redux/tasks_state.dart';
import '../../../core/ui/widgets/state_view.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StoreConnector<AppState, TaskSubmissionStatus>(
          converter: (store) => store.state.tasksState.submissions[task.id] ?? TaskSubmissionStatus(),
          builder: (context, status) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  status.isSubmitted
                    ? 'Submitted on ${status.submittedAt?.toLocal()}'
                    : 'Due: ${task.dueDate.toLocal()}',
                  style: TextStyle(color: status.isSubmitted ? Colors.green : Colors.red),
                ),
                const Divider(height: 32),
                const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(task.description),
                const Spacer(),
                if (status.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(status.error!, style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton.icon(
                  onPressed: status.isUploading || status.isSubmitted
                      ? null
                      : () => _showUploadDialog(context),
                  icon: status.isUploading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(status.isSubmitted ? Icons.check : Icons.upload_file),
                  label: Text(status.isUploading ? 'Uploading...' : (status.isSubmitted ? 'Already Submitted' : 'Submit Assignment')),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            );
          },
        ),
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
              StoreProvider.of<AppState>(context).dispatch(
                SubmitTaskAction(task.id, 'https://example.com/submission.pdf'),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
