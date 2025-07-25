class PostModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String authorName;
  final String? authorImage;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.authorName,
    this.authorImage,
    required this.createdAt,
  });

  // لإنشاء كائن PostModel من بيانات Firestore
  factory PostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PostModel(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      authorName: map['authorName'] ?? '',
      authorImage: map['authorImage'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // لتحويل الكائن إلى خريطة لحفظه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorName': authorName,
      'authorImage': authorImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
