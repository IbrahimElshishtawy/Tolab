class PostModel {
  final String id;
  final String content;
  final String authorId;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.content,
    required this.authorId,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['id'],
    content: json['content'],
    authorId: json['author_id'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'author_id': authorId,
    'created_at': createdAt.toIso8601String(),
  };
}
