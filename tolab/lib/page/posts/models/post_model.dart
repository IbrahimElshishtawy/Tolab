class PostModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String authorName;
  final String? authorImage;
  final String authorRole; // ⬅️ جديد
  final DateTime createdAt;
  final int viewsCount;
  final int sharesCount;
  final List<String> viewers;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorName,
    this.authorImage,
    required this.authorRole, // ⬅️ جديد
    required this.createdAt,
    this.viewsCount = 0,
    this.sharesCount = 0,
    this.viewers = const [],
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PostModel(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      authorName: map['authorName'] ?? '',
      authorImage: map['authorImage'],
      authorRole: map['authorRole'] ?? 'student', // ⬅️ جديد
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      viewsCount: map['viewsCount'] ?? 0,
      sharesCount: map['sharesCount'] ?? 0,
      viewers: List<String>.from(map['viewers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorName': authorName,
      'authorImage': authorImage,
      'authorRole': authorRole, // ⬅️ جديد
      'createdAt': createdAt.toIso8601String(),
      'viewsCount': viewsCount,
      'sharesCount': sharesCount,
      'viewers': viewers,
    };
  }
}
