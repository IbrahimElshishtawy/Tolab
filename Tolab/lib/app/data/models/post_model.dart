class PostModel {
  const PostModel({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.commentCount = 0,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int commentCount;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return PostModel(
      id: (json['id'] ?? '').toString(),
      authorName:
          (author?['name'] ?? json['author_name'] ?? 'Unknown') as String,
      content: (json['content'] ?? json['body'] ?? '') as String,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      commentCount:
          (json['comments_count'] as num?)?.toInt() ??
          (json['comment_count'] as num?)?.toInt() ??
          0,
    );
  }
}
