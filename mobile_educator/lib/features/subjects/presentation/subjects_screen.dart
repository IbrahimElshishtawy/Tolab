import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/subjects_models.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data
    final subjects = [
      Subject(id: 1, academicYearName: '2023/2024', batchName: 'Level 3', departmentName: 'CS', subjectName: 'Software Engineering'),
      Subject(id: 2, academicYearName: '2023/2024', batchName: 'Level 2', departmentName: 'IS', subjectName: 'Database Systems'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Subjects')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(subject.subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${subject.departmentName} - ${subject.batchName} (${subject.academicYearName})'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {}, // Navigate to Details
            ),
          );
        },
      ),
    );
  }
}
