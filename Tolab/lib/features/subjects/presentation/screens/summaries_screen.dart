import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../../../core/localization/localization_manager.dart';

class SummariesScreen extends StatelessWidget {
  final int subjectId;
  const SummariesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('summaries'.tr())),
      body: StoreConnector<AppState, List<Summary>>(
        converter: (store) => store.state.subjectsState.summaries[subjectId] ?? [],
        builder: (context, summaries) {
          if (summaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.summarize_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No summaries available now', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(summary.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('By: ${summary.studentName}', style: const TextStyle(color: Colors.blue, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(summary.content, style: const TextStyle(color: Colors.black87)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (summary.videoUrl != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text('Video'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                              ),
                            ),
                          if (summary.videoUrl != null && summary.pdfUrl != null) const SizedBox(width: 12),
                          if (summary.pdfUrl != null)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/subjects/$subjectId/summaries/add'),
        label: Text('add_summary'.tr()),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
