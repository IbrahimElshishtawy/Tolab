class SubjectOverview {
  const SubjectOverview({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.creditHours,
    required this.accentHex,
    required this.description,
  });

  final String id;
  final String name;
  final String code;
  final String instructor;
  final int creditHours;
  final String accentHex;
  final String description;
}

class LectureItem {
  const LectureItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.scheduleLabel,
    required this.meetingUrl,
    required this.isOnline,
  });

  final String id;
  final String subjectId;
  final String title;
  final String scheduleLabel;
  final String meetingUrl;
  final bool isOnline;
}

class SectionItem {
  const SectionItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.location,
    required this.scheduleLabel,
  });

  final String id;
  final String subjectId;
  final String title;
  final String location;
  final String scheduleLabel;
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.dueDateLabel,
    required this.status,
  });

  final String id;
  final String subjectId;
  final String title;
  final String dueDateLabel;
  final String status;
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
