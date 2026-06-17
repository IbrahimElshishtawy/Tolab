enum NotificationUrgency { newItem, important, urgent }

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
    this.subjectName,
    this.urgency = NotificationUrgency.newItem,
    this.data,
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
  final String? subjectName;
  final NotificationUrgency urgency;
  final Map<String, dynamic>? data;

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
    String? subjectName,
    NotificationUrgency? urgency,
    Map<String, dynamic>? data,
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
      subjectName: subjectName ?? this.subjectName,
      urgency: urgency ?? this.urgency,
      data: data ?? this.data,
    );
  }

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdAtLabel: json['createdAtLabel'] as String,
      category: json['category'] as String,
      isRead: json['isRead'] as bool,
      routeName: json['routeName'] as String,
      pathParameters: Map<String, String>.from(json['pathParameters'] as Map? ?? const {}),
      isImportant: json['isImportant'] as bool? ?? false,
      subjectName: json['subjectName'] as String?,
      urgency: NotificationUrgency.values.firstWhere(
        (e) => e.name == json['urgency'],
        orElse: () => NotificationUrgency.newItem,
      ),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'createdAtLabel': createdAtLabel,
      'category': category,
      'isRead': isRead,
      'routeName': routeName,
      'pathParameters': pathParameters,
      'isImportant': isImportant,
      'subjectName': subjectName,
      'urgency': urgency.name,
      'data': data,
    };
  }
}
