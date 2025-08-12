class LinkModel {
  final String id;
  final String title;
  final String url;

  LinkModel({required this.id, required this.title, required this.url});

  factory LinkModel.fromMap(Map<String, dynamic> data, String documentId) {
    return LinkModel(
      id: documentId,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'url': url};
  }
}
