class LectureModel {
  const LectureModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.weekNumber,
    required this.instructorName,
    required this.isPublished,
    this.videoUrl,
    this.fileUrl,
    this.publishedAt,
  });

  final int id;
  final int subjectId;
  final String title;
  final int weekNumber;
  final String instructorName;
  final String? videoUrl;
  final String? fileUrl;
  final bool isPublished;
  final String? publishedAt;

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      weekNumber: (json['week_number'] as num?)?.toInt() ?? 1,
      instructorName: json['instructor_name']?.toString() ?? '',
      videoUrl: json['video_url']?.toString(),
      fileUrl: json['file_url']?.toString(),
      isPublished: json['is_published'] == true,
      publishedAt: json['published_at']?.toString(),
    );
  }
}

class SectionContentModel {
  const SectionContentModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.weekNumber,
    required this.assistantName,
    required this.isPublished,
    this.videoUrl,
    this.fileUrl,
    this.publishedAt,
  });

  final int id;
  final int subjectId;
  final String title;
  final int weekNumber;
  final String assistantName;
  final String? videoUrl;
  final String? fileUrl;
  final bool isPublished;
  final String? publishedAt;

  factory SectionContentModel.fromJson(Map<String, dynamic> json) {
    return SectionContentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      weekNumber: (json['week_number'] as num?)?.toInt() ?? 1,
      assistantName: json['assistant_name']?.toString() ?? '',
      videoUrl: json['video_url']?.toString(),
      fileUrl: json['file_url']?.toString(),
      isPublished: json['is_published'] == true,
      publishedAt: json['published_at']?.toString(),
    );
  }
}

class QuizModel {
  const QuizModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.ownerName,
    required this.quizType,
    required this.quizDate,
    required this.isPublished,
    this.quizLink,
  });

  final int id;
  final int subjectId;
  final String title;
  final String ownerName;
  final String quizType;
  final String quizDate;
  final bool isPublished;
  final String? quizLink;

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      quizType: json['quiz_type']?.toString() ?? 'offline',
      quizDate: json['quiz_date']?.toString() ?? '',
      isPublished: json['is_published'] == true,
      quizLink: json['quiz_link']?.toString(),
    );
  }
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.ownerName,
    required this.referenceName,
    required this.isPublished,
    this.fileUrl,
    this.dueDate,
  });

  final int id;
  final int subjectId;
  final String title;
  final String ownerName;
  final String referenceName;
  final String? fileUrl;
  final String? dueDate;
  final bool isPublished;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      referenceName: json['lecture_or_section_name']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      dueDate: json['due_date']?.toString(),
      isPublished: json['is_published'] == true,
    );
  }
}
