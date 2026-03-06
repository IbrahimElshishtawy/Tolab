class Comment {
  final int id;
  final String studentName;
  final DateTime dateTime;
  final String text;

  Comment({
    required this.id,
    required this.studentName,
    required this.dateTime,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      studentName: json['student_name'] ?? json['user'] ?? '',
      dateTime: DateTime.parse(json['date_time'] ?? json['created_at']),
      text: json['text'],
    );
  }
}

class Post {
  final int id;
  final String text;
  final String authorName;
  final int likes;
  final List<String> reactions;
  final List<Comment> comments;
  final int commentsCount;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.text,
    required this.authorName,
    this.likes = 0,
    required this.reactions,
    required this.comments,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'] ?? json['content'] ?? '',
      authorName: json['author_name'] ?? json['user'] ?? '',
      likes: json['likes'] ?? 0,
      reactions: List<String>.from(json['reactions'] ?? []),
      comments: (json['comments'] as List? ?? []).map((e) => Comment.fromJson(e)).toList(),
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
