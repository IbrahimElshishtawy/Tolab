import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المحاضرة
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

  /// إنشاء الكائن من Map
  factory Lecture.fromMap(Map<String, dynamic> data, String documentId) {
    return Lecture(
      id: documentId,
      title: data['title'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  /// تحويل الكائن إلى Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fileUrl': fileUrl,
      'date': Timestamp.fromDate(date),
    };
  }

  /// نسخة معدلة من الكائن
  Lecture copyWith({
    String? id,
    String? title,
    String? fileUrl,
    DateTime? date,
  }) {
    return Lecture(
      id: id ?? this.id,
      title: title ?? this.title,
      fileUrl: fileUrl ?? this.fileUrl,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Lecture(id: $id, title: $title, fileUrl: $fileUrl, date: $date)';
  }
}
