import 'package:flutter/material.dart';
import '../data/models.dart';

class SubmissionDetailsScreen extends StatelessWidget {
  final Submission submission;
  const SubmissionDetailsScreen({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${submission.studentName}\'s Submission')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Student Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(submission.studentName),
              subtitle: const Text('Student ID: 2021001'),
            ),
            const Divider(),
            const Text('Submission Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Submitted at: ${submission.submittedAt.toLocal()}'),
            const SizedBox(height: 16),
            if (submission.fileUrl != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_file, color: Colors.blue),
                  title: const Text('assignment_v1.zip'),
                  subtitle: const Text('2.4 MB'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading file...')));
                    },
                  ),
                ),
              ),
            const Spacer(),
            if (submission.grade == null)
              ElevatedButton(
                onPressed: () => _showGradeDialog(context),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Grade Now'),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Grade: ${submission.grade}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showGradeDialog(BuildContext context) {
    // This would typically dispatch a Redux action
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Grade'),
        content: const TextField(
          decoration: InputDecoration(hintText: 'Enter grade (A, B+, 95, etc.)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission graded!')));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
