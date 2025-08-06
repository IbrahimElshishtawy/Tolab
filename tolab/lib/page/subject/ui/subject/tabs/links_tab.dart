// lib/ui/subject/tabs/links_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksTab extends StatelessWidget {
  final String subjectId;
  const LinksTab({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectId)
          .collection('links')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('خطأ في تحميل الروابط'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('لا توجد روابط'));
        }

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final title = doc['title'] ?? 'رابط';
            final url = doc['url'] ?? '';
            final uploadedAt = (doc['createdAt'] as Timestamp).toDate();
            final formattedDate =
                "${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}";

            return ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: Text(title),
              subtitle: Text('تم الإضافة: $formattedDate'),
              onTap: () async {
                if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرابط غير صالح')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
