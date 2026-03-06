class NotificationModel {
  final int id;
  final String title;
  final String content;
  final DateTime dateTime;
  final String? type; // quiz, lecture, section
  final String? deepLink;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.type,
    this.deepLink,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? json['message'] ?? '',
      dateTime: DateTime.parse(json['date_time'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      type: json['type'],
      deepLink: json['deep_link'],
    );
  }
}
