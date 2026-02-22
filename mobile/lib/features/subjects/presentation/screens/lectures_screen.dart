import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../../../core/localization/localization_manager.dart';

class LecturesScreen extends StatelessWidget {
  final int subjectId;
  const LecturesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('lectures'.tr())),
      body: StoreConnector<AppState, List<Lecture>>(
        converter: (store) => store.state.subjectsState.lectures[subjectId] ?? [],
        builder: (context, lectures) {
          if (lectures.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_lesson_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No lectures available now', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              final lecture = lectures[index];
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
                          Text('Week ${lecture.weekNumber}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          Text(lecture.doctorName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(lecture.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(lecture.content, style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (lecture.videoUrl != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text('Video'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                              ),
                            ),
                          if (lecture.videoUrl != null && lecture.pdfUrl != null) const SizedBox(width: 12),
                          if (lecture.pdfUrl != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.picture_as_pdf_outlined),
                                label: const Text('PDF'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ),
                        ],
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
