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

class Summary {
  final int id;
  final String name;
  final String studentName;
  final String content;
  final String? videoUrl;
  final String? pdfUrl;

  Summary({
    required this.id,
    required this.name,
    required this.studentName,
    required this.content,
    this.videoUrl,
    this.pdfUrl,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      id: json['id'],
      name: json['name'],
      studentName: json['student_name'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['video_url'],
      pdfUrl: json['pdf_url'],
    );
  }
}

class Lecture {
  final int id;
  final int weekNumber;
  final String title;
  final String doctorName;
  final String content;
  final String? videoUrl;
  final String? pdfUrl;

  Lecture({
    required this.id,
    required this.weekNumber,
    required this.title,
    required this.doctorName,
    required this.content,
    this.videoUrl,
    this.pdfUrl,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      weekNumber: json['week_number'] ?? 0,
      title: json['title'],
      doctorName: json['doctor_name'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['video_url'] ?? json['content_url'],
      pdfUrl: json['pdf_url'],
    );
  }
}

class Section {
  final int id;
  final int weekNumber;
  final String title;
  final String assistantName;
  final String content;
  final String? videoUrl;
  final String? pdfUrl;

  Section({
    required this.id,
    required this.weekNumber,
    required this.title,
    required this.assistantName,
    required this.content,
    this.videoUrl,
    this.pdfUrl,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      weekNumber: json['week_number'] ?? 0,
      title: json['title'],
      assistantName: json['assistant_name'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['video_url'],
      pdfUrl: json['pdf_url'],
    );
  }
}

enum QuizType { online, offline }

class Quiz {
  final int id;
  final QuizType type;
  final int weekNumber;
  final String sourceName;
  final String ownerName;
  final DateTime startAt;
  final DateTime? endAt;
  final int? durationMins;
  final int? totalPoints;
  final String? quizUrl;
  final String title;
  final int subjectId;

  Quiz({
    required this.id,
    required this.type,
    required this.weekNumber,
    required this.sourceName,
    required this.ownerName,
    required this.startAt,
    this.endAt,
    this.durationMins,
    this.totalPoints,
    this.quizUrl,
    required this.title,
    required this.subjectId,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      type: json['type'] == 'offline' ? QuizType.offline : QuizType.online,
      weekNumber: json['week_number'] ?? 0,
      sourceName: json['source_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      startAt: DateTime.parse(json['start_at']),
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      durationMins: json['duration_mins'] ?? json['duration'],
      totalPoints: json['total_points'],
      quizUrl: json['quiz_url'],
      title: json['title'] ?? '',
      subjectId: json['subject_id'] ?? 0,
    );
  }
}
