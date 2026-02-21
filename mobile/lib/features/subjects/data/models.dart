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

class Quiz {
  final int id;
  final String title;
  final int subjectId;
  final DateTime startAt;
  final DateTime endAt;
  final int durationMins;
  final int totalPoints;

  Quiz({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.startAt,
    required this.endAt,
    required this.durationMins,
    required this.totalPoints,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      subjectId: json['subject_id'],
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      durationMins: json['duration_mins'],
      totalPoints: json['total_points'],
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
