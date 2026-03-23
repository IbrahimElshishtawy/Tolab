class NotificationItemModel {
  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.type = 'info',
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String type;
  final bool isRead;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['message'] ?? 'Notification') as String,
      body: (json['body'] ?? json['message'] ?? '') as String,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      type: (json['type'] ?? 'info') as String,
      isRead: json['read_at'] != null || json['is_read'] == true,
    );
  }
}
