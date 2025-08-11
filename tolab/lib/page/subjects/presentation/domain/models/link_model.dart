class SubjectLink {
  final String id;
  final String title;
  final String url;

  SubjectLink({required this.id, required this.title, required this.url});

  factory SubjectLink.fromMap(Map<String, dynamic> data, String documentId) {
    return SubjectLink(
      id: documentId,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'url': url};
  }
}
