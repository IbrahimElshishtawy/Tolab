import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/helpers/json_types.dart';

enum ContentType {
  lecture,
  section,
  summary,
  quiz,
  task,
  exam,
  file;

  String get label => switch (this) {
    ContentType.lecture => 'Lecture',
    ContentType.section => 'Section',
    ContentType.summary => 'Summary',
    ContentType.quiz => 'Quiz',
    ContentType.task => 'Task',
    ContentType.exam => 'Exam',
    ContentType.file => 'File',
  };

  String get apiValue => switch (this) {
    ContentType.lecture => 'lecture',
    ContentType.section => 'section',
    ContentType.summary => 'summary',
    ContentType.quiz => 'quiz',
    ContentType.task => 'assignment',
    ContentType.exam => 'exam',
    ContentType.file => 'file',
  };

  IconData get icon => switch (this) {
    ContentType.lecture => Icons.slideshow_rounded,
    ContentType.section => Icons.groups_2_rounded,
    ContentType.summary => Icons.notes_rounded,
    ContentType.quiz => Icons.quiz_rounded,
    ContentType.task => Icons.assignment_rounded,
    ContentType.exam => Icons.timer_rounded,
    ContentType.file => Icons.attach_file_rounded,
  };
}

enum ContentStatus { draft, published, scheduled, archived }

enum ContentVisibility { allStudents, enrolledOnly, hidden }

enum AssessmentMode { mcq, trueFalse, fileSubmission, timedExam }

enum SubmissionStatus { submitted, pending, late, graded }

enum ContentDetailsTab { overview, attachments, submissions, grades }

enum ContentSortField { title, publishDate, dueDate, submissions, engagement }

extension ContentStatusX on ContentStatus {
  String get label => switch (this) {
    ContentStatus.draft => 'Draft',
    ContentStatus.published => 'Published',
    ContentStatus.scheduled => 'Scheduled',
    ContentStatus.archived => 'Archived',
  };
}

extension ContentVisibilityX on ContentVisibility {
  String get label => switch (this) {
    ContentVisibility.allStudents => 'All students',
    ContentVisibility.enrolledOnly => 'Enrolled only',
    ContentVisibility.hidden => 'Hidden',
  };
}

extension AssessmentModeX on AssessmentMode {
  String get label => switch (this) {
    AssessmentMode.mcq => 'MCQ',
    AssessmentMode.trueFalse => 'True / False',
    AssessmentMode.fileSubmission => 'File submission',
    AssessmentMode.timedExam => 'Timed exam',
  };
}

extension SubmissionStatusX on SubmissionStatus {
  String get label => switch (this) {
    SubmissionStatus.submitted => 'Submitted',
    SubmissionStatus.pending => 'Pending',
    SubmissionStatus.late => 'Late',
    SubmissionStatus.graded => 'Graded',
  };
}

class ContentSubjectOption {
  const ContentSubjectOption({
    required this.id,
    required this.code,
    required this.title,
    required this.courseOfferingId,
  });

  final String id;
  final String code;
  final String title;
  final String courseOfferingId;

  String get displayLabel => '$code • $title';
}

class ContentSectionOption {
  const ContentSectionOption({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.capacity,
  });

  final String id;
  final String subjectId;
  final String title;
  final int capacity;
}

class ContentInstructorOption {
  const ContentInstructorOption({
    required this.id,
    required this.name,
    required this.title,
    required this.accentColor,
  });

  final String id;
  final String name;
  final String title;
  final Color accentColor;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    return parts
        .take(2)
        .map((item) => item.characters.first)
        .join()
        .toUpperCase();
  }
}

class ContentPermissionSet {
  const ContentPermissionSet({
    this.canCreate = true,
    this.canEdit = true,
    this.canDelete = true,
    this.canPublish = true,
    this.canArchive = true,
    this.canGrade = true,
  });

  final bool canCreate;
  final bool canEdit;
  final bool canDelete;
  final bool canPublish;
  final bool canArchive;
  final bool canGrade;
}

class ContentAttachment {
  const ContentAttachment({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.url,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  final String id;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final String url;
  final DateTime uploadedAt;
  final String uploadedBy;

  String get sizeLabel => formatBytes(sizeBytes);

  String get extensionLabel {
    final index = name.lastIndexOf('.');
    if (index < 0 || index == name.length - 1) return mimeType;
    return name.substring(index + 1).toUpperCase();
  }

  factory ContentAttachment.fromUploadJson(
    JsonMap json, {
    String fallbackName = 'Upload',
  }) {
    return ContentAttachment(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name:
          json['file_name']?.toString() ??
          json['name']?.toString() ??
          fallbackName,
      mimeType:
          json['mime_type']?.toString() ??
          json['mimeType']?.toString() ??
          'application/octet-stream',
      sizeBytes: _parseInt(json['size']) ?? 0,
      url: json['file_url']?.toString() ?? json['url']?.toString() ?? '#',
      uploadedAt:
          DateTime.tryParse(
            json['created_at']?.toString() ??
                json['uploaded_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      uploadedBy:
          json['uploaded_by']?.toString() ??
          json['uploadedBy']?.toString() ??
          'Admin',
    );
  }
}

class ContentUploadSource {
  const ContentUploadSource({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.mimeType,
    this.bytes,
    this.path,
  });

  final String id;
  final String name;
  final int sizeBytes;
  final String mimeType;
  final Uint8List? bytes;
  final String? path;
}

class ContentUploadTask {
  const ContentUploadTask({
    required this.id,
    required this.source,
    required this.progress,
    required this.statusLabel,
    this.errorMessage,
    this.attachment,
  });

  final String id;
  final ContentUploadSource source;
  final double progress;
  final String statusLabel;
  final String? errorMessage;
  final ContentAttachment? attachment;

  bool get isCompleted => attachment != null && errorMessage == null;
  bool get isUploading => progress > 0 && progress < 1 && errorMessage == null;
  bool get isQueued =>
      progress == 0 && attachment == null && errorMessage == null;
  bool get hasFailed => errorMessage != null;

  ContentUploadTask copyWith({
    double? progress,
    String? statusLabel,
    String? errorMessage,
    bool clearError = false,
    ContentAttachment? attachment,
  }) {
    return ContentUploadTask(
      id: id,
      source: source,
      progress: progress ?? this.progress,
      statusLabel: statusLabel ?? this.statusLabel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      attachment: attachment ?? this.attachment,
    );
  }
}

class ContentStudentSnapshot {
  const ContentStudentSnapshot({
    required this.id,
    required this.name,
    required this.sectionLabel,
    required this.engagementLabel,
    required this.submissionStatus,
    this.gradeLabel,
  });

  final String id;
  final String name;
  final String sectionLabel;
  final String engagementLabel;
  final SubmissionStatus submissionStatus;
  final String? gradeLabel;
}

class ContentSubmissionRecord {
  const ContentSubmissionRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.attempts,
    required this.attachments,
    this.grade,
    this.feedback,
    this.submittedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final SubmissionStatus status;
  final int attempts;
  final List<ContentAttachment> attachments;
  final double? grade;
  final String? feedback;
  final DateTime? submittedAt;

  String get gradeLabel =>
      grade == null ? 'Ungraded' : '${grade!.toStringAsFixed(0)}%';
}

class ContentActivityItem {
  const ContentActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.tone,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color tone;
}

class ContentGradeBand {
  const ContentGradeBand({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;
}

class ContentAssessmentSettings {
  const ContentAssessmentSettings({
    required this.mode,
    required this.questionCount,
    required this.durationMinutes,
    required this.attemptsAllowed,
    required this.allowLateSubmission,
  });

  final AssessmentMode mode;
  final int questionCount;
  final int durationMinutes;
  final int attemptsAllowed;
  final bool allowLateSubmission;
}

class ContentRecord {
  const ContentRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.visibility,
    required this.subject,
    required this.section,
    required this.instructor,
    required this.publishAt,
    required this.dueAt,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
    required this.students,
    required this.submissions,
    required this.activity,
    required this.gradeBands,
    required this.permissions,
    required this.assessmentSettings,
    required this.enrollmentCount,
    required this.viewCount,
    required this.completionRate,
    required this.isPinned,
  });

  final String id;
  final String title;
  final String description;
  final ContentType type;
  final ContentStatus status;
  final ContentVisibility visibility;
  final ContentSubjectOption subject;
  final ContentSectionOption section;
  final ContentInstructorOption instructor;
  final DateTime? publishAt;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ContentAttachment> attachments;
  final List<ContentStudentSnapshot> students;
  final List<ContentSubmissionRecord> submissions;
  final List<ContentActivityItem> activity;
  final List<ContentGradeBand> gradeBands;
  final ContentPermissionSet permissions;
  final ContentAssessmentSettings? assessmentSettings;
  final int enrollmentCount;
  final int viewCount;
  final double completionRate;
  final bool isPinned;

  int get submittedCount => submissions
      .where((item) => item.status != SubmissionStatus.pending)
      .length;

  int get pendingCount => math.max(0, enrollmentCount - submittedCount);

  double get engagementRate {
    if (enrollmentCount == 0) return 0;
    return math.min(1, viewCount / (enrollmentCount * 1.35));
  }

  String get publishDateLabel => _formatDate(publishAt);
  String get dueDateLabel => _formatDate(dueAt);
  String get completionLabel => '${(completionRate * 100).toStringAsFixed(0)}%';

  ContentRecord copyWith({
    String? title,
    String? description,
    ContentType? type,
    ContentStatus? status,
    ContentVisibility? visibility,
    ContentSubjectOption? subject,
    ContentSectionOption? section,
    ContentInstructorOption? instructor,
    DateTime? publishAt,
    bool clearPublishAt = false,
    DateTime? dueAt,
    bool clearDueAt = false,
    DateTime? updatedAt,
    List<ContentAttachment>? attachments,
    List<ContentActivityItem>? activity,
    ContentAssessmentSettings? assessmentSettings,
  }) {
    return ContentRecord(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      subject: subject ?? this.subject,
      section: section ?? this.section,
      instructor: instructor ?? this.instructor,
      publishAt: clearPublishAt ? null : publishAt ?? this.publishAt,
      dueAt: clearDueAt ? null : dueAt ?? this.dueAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: List<ContentAttachment>.unmodifiable(
        attachments ?? this.attachments,
      ),
      students: students,
      submissions: submissions,
      activity: List<ContentActivityItem>.unmodifiable(
        activity ?? this.activity,
      ),
      gradeBands: gradeBands,
      permissions: permissions,
      assessmentSettings: assessmentSettings ?? this.assessmentSettings,
      enrollmentCount: enrollmentCount,
      viewCount: viewCount,
      completionRate: completionRate,
      isPinned: isPinned,
    );
  }
}

class ContentFilters {
  const ContentFilters({
    this.searchQuery = '',
    this.type,
    this.subjectId,
    this.instructorId,
    this.status,
  });

  final String searchQuery;
  final ContentType? type;
  final String? subjectId;
  final String? instructorId;
  final ContentStatus? status;

  ContentFilters copyWith({
    String? searchQuery,
    ContentType? type,
    bool clearType = false,
    String? subjectId,
    bool clearSubjectId = false,
    String? instructorId,
    bool clearInstructorId = false,
    ContentStatus? status,
    bool clearStatus = false,
  }) {
    return ContentFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      type: clearType ? null : type ?? this.type,
      subjectId: clearSubjectId ? null : subjectId ?? this.subjectId,
      instructorId: clearInstructorId
          ? null
          : instructorId ?? this.instructorId,
      status: clearStatus ? null : status ?? this.status,
    );
  }
}

class ContentSort {
  const ContentSort({
    this.field = ContentSortField.publishDate,
    this.ascending = false,
  });

  final ContentSortField field;
  final bool ascending;

  ContentSort copyWith({ContentSortField? field, bool? ascending}) {
    return ContentSort(
      field: field ?? this.field,
      ascending: ascending ?? this.ascending,
    );
  }
}

class ContentPagination {
  const ContentPagination({this.page = 1, this.perPage = 6});

  final int page;
  final int perPage;

  ContentPagination copyWith({int? page, int? perPage}) {
    return ContentPagination(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}

class ContentRepositoryBundle {
  const ContentRepositoryBundle({
    required this.items,
    required this.subjects,
    required this.sections,
    required this.instructors,
  });

  final List<ContentRecord> items;
  final List<ContentSubjectOption> subjects;
  final List<ContentSectionOption> sections;
  final List<ContentInstructorOption> instructors;
}

class ContentMutationResult {
  const ContentMutationResult({
    required this.items,
    required this.message,
    this.selectedContentId,
  });

  final List<ContentRecord> items;
  final String message;
  final String? selectedContentId;
}

class ContentUpsertPayload {
  const ContentUpsertPayload({
    required this.title,
    required this.description,
    required this.type,
    required this.subjectId,
    required this.sectionId,
    required this.instructorId,
    required this.courseOfferingId,
    required this.visibility,
    required this.status,
    required this.assessmentSettings,
    this.publishAt,
    this.dueAt,
  });

  final String title;
  final String description;
  final ContentType type;
  final String subjectId;
  final String sectionId;
  final String instructorId;
  final String courseOfferingId;
  final ContentVisibility visibility;
  final ContentStatus status;
  final DateTime? publishAt;
  final DateTime? dueAt;
  final ContentAssessmentSettings? assessmentSettings;

  JsonMap toApiJson() {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'visibility': visibility.name,
      'status': status.name,
    };
    if (publishAt != null) {
      payload['publish_at'] = publishAt!.toIso8601String();
      payload['date'] = publishAt!.toIso8601String();
      payload['exam_at'] = publishAt!.toIso8601String();
    }
    if (dueAt != null) {
      payload['due_at'] = dueAt!.toIso8601String();
    }
    if (type == ContentType.quiz || type == ContentType.task) {
      payload['type'] = assessmentSettings?.mode == AssessmentMode.trueFalse
          ? 'true_false'
          : type == ContentType.task
          ? 'assignment'
          : 'mcq';
    }
    return payload;
  }
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var size = bytes / 1024;
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${units[unitIndex]}';
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Not scheduled';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '');
}

List<Color> contentAccentPalette() => const [
  AppColors.primary,
  AppColors.secondary,
  AppColors.info,
  AppColors.warning,
  AppColors.purple,
];
