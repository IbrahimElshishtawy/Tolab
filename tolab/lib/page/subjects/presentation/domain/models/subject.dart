class Subject {
  final String id;
  final String name;
  final String teacher;
  final String imageUrl;
  final String description;
  final double progress;

  Subject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.imageUrl,
    this.description = '',
    this.progress = 0.0,
  });

  factory Subject.fromMap(Map<String, dynamic> data, String documentId) {
    return Subject(
      id: documentId,
      name: data['name'] ?? '',
      teacher: data['teacher'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      progress: (data['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacher': teacher,
      'imageUrl': imageUrl,
      'description': description,
      'progress': progress,
    };
  }
}
