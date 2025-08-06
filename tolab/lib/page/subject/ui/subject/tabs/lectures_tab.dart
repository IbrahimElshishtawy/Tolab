// lib/ui/subject/tabs/lectures_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturesTab extends StatelessWidget {
  final String subjectId;
  const LecturesTab({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectId)
          .collection('lectures')
          .orderBy('uploadedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('خطأ في تحميل المحاضرات'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('لا توجد محاضرات'));
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final title = doc['title'] ?? '';
            final uploader = doc['uploaderName'] ?? '---';
            final uploadedAt = (doc['uploadedAt'] as Timestamp).toDate();
            final timeStr =
                '${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}';

            return ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(title),
              subtitle: Text('من قِبل $uploader — $timeStr'),
              onTap: () {
                // فتح الفيديو أو محتوى المحاضرة
              },
            );
          },
        );
      },
    );
  }
}
