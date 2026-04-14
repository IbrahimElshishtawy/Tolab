class SubjectOverview {
  const SubjectOverview({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.assistantName,
    required this.creditHours,
    required this.accentHex,
    required this.description,
    required this.lecturesCount,
    required this.sectionsCount,
    required this.quizCount,
    required this.sheetCount,
    required this.lastActivityLabel,
    required this.progress,
    required this.status,
  });

  final String id;
  final String name;
  final String code;
  final String instructor;
  final String assistantName;
  final int creditHours;
  final String accentHex;
  final String description;
  final int lecturesCount;
  final int sectionsCount;
  final int quizCount;
  final int sheetCount;
  final String lastActivityLabel;
  final double progress;
  final String status;
}

class LectureItem {
  const LectureItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.scheduleLabel,
    required this.meetingUrl,
    required this.isOnline,
    this.instructorName,
    this.subjectName,
    this.startsAt,
    this.endsAt,
    this.locationLabel,
  });

  final String id;
  final String subjectId;
  final String title;
  final String scheduleLabel;
  final String meetingUrl;
  final bool isOnline;
  final String? instructorName;
  final String? subjectName;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? locationLabel;
}

class SectionItem {
  const SectionItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.location,
    required this.scheduleLabel,
    required this.assistantName,
    this.subjectName,
    this.isOnline = false,
    this.meetingUrl = '',
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String subjectId;
  final String title;
  final String location;
  final String scheduleLabel;
  final String assistantName;
  final String? subjectName;
  final bool isOnline;
  final String meetingUrl;
  final DateTime? startsAt;
  final DateTime? endsAt;
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.dueDateLabel,
    required this.status,
    this.subjectName,
    this.dueAt,
    this.isCompleted = false,
    this.isMissingSubmission = false,
    this.allowResubmission = false,
    this.uploadedFileName,
    this.gradeLabel,
    this.supportedTypes = const ['pdf', 'docx', 'png'],
  });

  final String id;
  final String subjectId;
  final String title;
  final String description;
  final String dueDateLabel;
  final String status;
  final String? subjectName;
  final DateTime? dueAt;
  final bool isCompleted;
  final bool isMissingSubmission;
  final bool allowResubmission;
  final String? uploadedFileName;
  final String? gradeLabel;
  final List<String> supportedTypes;

  TaskItem copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? description,
    String? dueDateLabel,
    String? status,
    String? subjectName,
    DateTime? dueAt,
    bool? isCompleted,
    bool? isMissingSubmission,
    bool? allowResubmission,
    String? uploadedFileName,
    String? gradeLabel,
    List<String>? supportedTypes,
  }) {
    return TaskItem(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDateLabel: dueDateLabel ?? this.dueDateLabel,
      status: status ?? this.status,
      subjectName: subjectName ?? this.subjectName,
      dueAt: dueAt ?? this.dueAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isMissingSubmission: isMissingSubmission ?? this.isMissingSubmission,
      allowResubmission: allowResubmission ?? this.allowResubmission,
      uploadedFileName: uploadedFileName ?? this.uploadedFileName,
      gradeLabel: gradeLabel ?? this.gradeLabel,
      supportedTypes: supportedTypes ?? this.supportedTypes,
    );
  }
}

class SummaryItem {
  const SummaryItem({
    required this.id,
    required this.subjectId,
    required this.authorName,
    required this.title,
    required this.createdAtLabel,
    this.videoUrl,
    this.attachmentName,
  });

  final String id;
  final String subjectId;
  final String authorName;
  final String title;
  final String createdAtLabel;
  final String? videoUrl;
  final String? attachmentName;

  SummaryItem copyWith({
    String? id,
    String? subjectId,
    String? authorName,
    String? title,
    String? createdAtLabel,
    String? videoUrl,
    String? attachmentName,
  }) {
    return SummaryItem(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      videoUrl: videoUrl ?? this.videoUrl,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }
}

class SubjectFileItem {
  const SubjectFileItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.fileName,
    required this.typeLabel,
    required this.createdAtLabel,
  });

  final String id;
  final String subjectId;
  final String title;
  final String fileName;
  final String typeLabel;
  final String createdAtLabel;
}
