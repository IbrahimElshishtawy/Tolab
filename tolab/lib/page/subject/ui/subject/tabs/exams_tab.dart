// lib/ui/subject/tabs/exams_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamsTab extends StatelessWidget {
  final String subjectId;
  const ExamsTab({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectId)
          .collection('exams')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('خطأ في تحميل الاختبارات'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('لا توجد اختبارات سابقة'));
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final title = doc['title'] ?? 'اختبار';
            final dateTimestamp = doc['date'] as Timestamp?;
            final uploader = doc['uploadedBy'] ?? '---';
            final scoreInfo = doc['info'] ?? '';

            final dateStr = dateTimestamp != null
                ? '${dateTimestamp.toDate().day}/${dateTimestamp.toDate().month}/${dateTimestamp.toDate().year}'
                : '';

            return ListTile(
              leading: const Icon(Icons.note_alt),
              title: Text(title),
              subtitle: Text('تاريخ: $dateStr — من قِبل $uploader\n$scoreInfo'),
              isThreeLine: true,
              onTap: () {
                // هنا يمكنك فتح ملف PDF أو عرض تفاصيل الاختبار
              },
            );
          },
        );
      },
    );
  }
}
