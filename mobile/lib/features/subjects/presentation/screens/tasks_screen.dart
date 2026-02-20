import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  final int subjectId;
  const TasksScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.assignment, color: Colors.blue),
                title: const Text('First Assignment'),
                subtitle: const Text('Due: Oct 25, 2023'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File picker opened...')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Submission'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
