import 'package:cloud_firestore/cloud_firestore.dart';

class Lecture {
  final String id;
  final String title;
  final String fileUrl;
  final DateTime date;

  Lecture({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.date,
  });

  factory Lecture.fromMap(Map<String, dynamic> data, String documentId) {
    return Lecture(
      id: documentId,
      title: data['title'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'fileUrl': fileUrl, 'date': date};
  }
}
