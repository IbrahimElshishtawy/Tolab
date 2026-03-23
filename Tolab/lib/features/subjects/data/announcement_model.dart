class Announcement {
  final int id;
  final int subjectId;
  final String title;
  final String body;
  final bool pinned;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.body,
    this.pinned = false,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      subjectId: json['subject_id'],
      title: json['title'],
      body: json['body'],
      pinned: json['pinned'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
