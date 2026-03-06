import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../../../core/localization/localization_manager.dart';

class SectionsScreen extends StatelessWidget {
  final int subjectId;
  const SectionsScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('sections'.tr())),
      body: StoreConnector<AppState, List<Section>>(
        converter: (store) => store.state.subjectsState.sections[subjectId] ?? [],
        builder: (context, sections) {
          if (sections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No sections available now', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
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
                          Text('Week ${section.weekNumber}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Text(section.assistantName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(section.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(section.content, style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (section.videoUrl != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text('Video'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                              ),
                            ),
                          if (section.videoUrl != null && section.pdfUrl != null) const SizedBox(width: 12),
                          if (section.pdfUrl != null)
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
