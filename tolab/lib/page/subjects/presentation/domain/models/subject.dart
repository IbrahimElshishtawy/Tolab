class Subject {
  final String id;
  final String name;
  final String teacher;
  final String imageUrl;

  Subject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.imageUrl,
  });

  factory Subject.fromMap(Map<String, dynamic> data, String documentId) {
    return Subject(
      id: documentId,
      name: data['name'] ?? '',
      teacher: data['teacher'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  get length => null;

  Map<String, dynamic> toMap() {
    return {'name': name, 'teacher': teacher, 'imageUrl': imageUrl};
  }
}
