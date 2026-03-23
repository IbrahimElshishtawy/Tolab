class CommentModel {
  const CommentModel({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return CommentModel(
      id: (json['id'] ?? '').toString(),
      authorName:
          (author?['name'] ?? json['author_name'] ?? 'Unknown') as String,
      content: (json['content'] ?? json['body'] ?? '') as String,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
