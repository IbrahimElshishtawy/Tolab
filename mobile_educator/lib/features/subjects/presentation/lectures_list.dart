import 'package:flutter/material.dart';
import '../domain/subjects_models.dart';

class LecturesList extends StatelessWidget {
  final List<Lecture> lectures;
  const LecturesList({super.key, required this.lectures});

  @override
  Widget build(BuildContext context) {
    if (lectures.isEmpty) return const Center(child: Text('No lectures yet'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        final lecture = lectures[index];
        return Card(
          child: ExpansionTile(
            title: Text('Week ${lecture.weekNumber}: ${lecture.lectureName}'),
            subtitle: Text('By ${lecture.doctorName}'),
            children: [
              ListTile(
                leading: const Icon(Icons.video_collection),
                title: const Text('Watch Video'),
                onTap: () {}, // Open webview
                enabled: lecture.videoUrl != null,
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('View PDF'),
                onTap: () {}, // Open PDF viewer
                enabled: lecture.pdfUrl != null,
              ),
            ],
          ),
        );
      },
    );
  }
}
