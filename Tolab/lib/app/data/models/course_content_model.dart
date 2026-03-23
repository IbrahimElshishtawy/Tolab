class CourseContentModel {
  const CourseContentModel({
    this.lectures = const [],
    this.summaries = const [],
    this.assessments = const [],
    this.exams = const [],
    this.files = const [],
  });

  final List<ContentEntryModel> lectures;
  final List<ContentEntryModel> summaries;
  final List<ContentEntryModel> assessments;
  final List<ContentEntryModel> exams;
  final List<ContentEntryModel> files;

  factory CourseContentModel.fromJson(Map<String, dynamic> json) {
    List<ContentEntryModel> parseList(String key) {
      return (json[key] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ContentEntryModel.fromJson)
          .toList();
    }

    return CourseContentModel(
      lectures: parseList('lectures'),
      summaries: parseList('summaries'),
      assessments: parseList('assessments'),
      exams: parseList('exams'),
      files: parseList('files'),
    );
  }
}

class ContentEntryModel {
  const ContentEntryModel({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    this.date,
  });

  final String id;
  final String title;
  final String? description;
  final String? fileUrl;
  final DateTime? date;

  factory ContentEntryModel.fromJson(Map<String, dynamic> json) {
    return ContentEntryModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Content') as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String? ?? json['url'] as String?,
      date: DateTime.tryParse(
        (json['created_at'] ?? json['date'] ?? '').toString(),
      ),
    );
  }
}
