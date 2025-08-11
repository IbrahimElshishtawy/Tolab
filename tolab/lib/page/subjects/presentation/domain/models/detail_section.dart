class DetailSection {
  final String id;
  final String title;
  final String content;

  DetailSection({required this.id, required this.title, required this.content});

  factory DetailSection.fromMap(Map<String, dynamic> data, String documentId) {
    return DetailSection(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'content': content};
  }
}
