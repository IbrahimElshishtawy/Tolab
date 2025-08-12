/// نموذج الروابط
class LinkModel {
  final String id;
  final String title;
  final String url;

  LinkModel({required this.id, required this.title, required this.url});

  /// إنشاء الكائن من Map
  factory LinkModel.fromMap(Map<String, dynamic> data, String documentId) {
    return LinkModel(
      id: documentId,
      title: data['title'] ?? '',
      url: data['url'] ?? '',
    );
  }

  /// تحويل الكائن إلى Map
  Map<String, dynamic> toMap() {
    return {'title': title, 'url': url};
  }

  /// نسخة معدلة من الكائن
  LinkModel copyWith({String? id, String? title, String? url}) {
    return LinkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }

  @override
  String toString() {
    return 'LinkModel(id: $id, title: $title, url: $url)';
  }
}
