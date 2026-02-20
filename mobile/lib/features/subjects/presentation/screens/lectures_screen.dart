import 'package:flutter/material.dart';

class LecturesScreen extends StatelessWidget {
  final int subjectId;
  const LecturesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text('Lecture ${index + 1}: Overview'),
            subtitle: const Text('Uploaded on Oct 12, 2023'),
            trailing: const Icon(Icons.download),
            onTap: () {},
          ),
        );
      },
    );
  }
}
