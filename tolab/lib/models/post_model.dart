class PostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int views;
  final int shares;
  final List<String> viewsUsers;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.views,
    required this.shares,
    required this.viewsUsers,
  });

  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    int? views,
    int? shares,
    List<String>? viewsUsers,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      viewsUsers: viewsUsers ?? this.viewsUsers,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['id'],
    title: json['title'] ?? '',
    content: json['content'],
    authorId: json['author_id'],
    authorName: json['author_name'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
    views: json['views'] ?? 0,
    shares: json['shares'] ?? 0,
    viewsUsers: List<String>.from(json['viewsUsers'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'author_id': authorId,
    'author_name': authorName,
    'created_at': createdAt.toIso8601String(),
    'views': views,
    'shares': shares,
    'viewsUsers': viewsUsers,
  };
}
