import 'package:flutter/material.dart';
import '../../tasks/data/models.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
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
