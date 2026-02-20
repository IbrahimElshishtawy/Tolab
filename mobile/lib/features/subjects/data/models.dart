class Subject {
  final int id;
  final String code;
  final String name;
  final String? description;

  Subject({required this.id, required this.code, required this.name, this.description});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Lecture {
  final int id;
  final String title;
  final String? contentUrl;

  Lecture({required this.id, required this.title, this.contentUrl});

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      title: json['title'],
      contentUrl: json['content_url'],
    );
  }
}
