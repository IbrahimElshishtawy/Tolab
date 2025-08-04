import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String content;
  final String type; // post, file, update
  final String referenceId;
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
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : data['timestamp'] as DateTime,
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

  // Optional for HTTP/JSON APIs
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        type: json['type'] ?? '',
        referenceId: json['referenceId'] ?? '',
        timestamp: DateTime.parse(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type,
    'referenceId': referenceId,
    'timestamp': timestamp.toIso8601String(),
  };
}
