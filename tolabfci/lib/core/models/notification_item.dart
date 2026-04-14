class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.createdAtLabel,
    required this.category,
    required this.isRead,
    required this.routeName,
    this.pathParameters = const {},
    this.isImportant = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String createdAtLabel;
  final String category;
  final bool isRead;
  final String routeName;
  final Map<String, String> pathParameters;
  final bool isImportant;

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    String? createdAtLabel,
    String? category,
    bool? isRead,
    String? routeName,
    Map<String, String>? pathParameters,
    bool? isImportant,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      routeName: routeName ?? this.routeName,
      pathParameters: pathParameters ?? this.pathParameters,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
