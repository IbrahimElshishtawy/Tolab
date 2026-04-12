class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAtLabel,
    required this.category,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final String createdAtLabel;
  final String category;
  final bool isRead;

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? createdAtLabel,
    String? category,
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
    );
  }
}
