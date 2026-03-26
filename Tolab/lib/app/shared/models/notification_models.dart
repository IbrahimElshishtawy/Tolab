class AdminNotification {
  const AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAtLabel,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final String createdAtLabel;
  final bool isRead;
}
