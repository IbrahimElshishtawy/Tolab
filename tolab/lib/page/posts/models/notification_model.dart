// lib/Features/notifications/models/notification_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String content;
  final String type; // post, file, update
  final String referenceId; // ID للبوست أو الملف
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.referenceId,
    required this.timestamp,
  });

  factory AppNotification.fromMap(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: data['type'] ?? '',
      referenceId: data['referenceId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'type': type,
      'referenceId': referenceId,
      'timestamp': timestamp,
    };
  }
}
