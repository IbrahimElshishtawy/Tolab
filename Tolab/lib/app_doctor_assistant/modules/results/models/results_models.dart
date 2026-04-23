class ResultsOverviewModel {
  const ResultsOverviewModel({
    required this.subjects,
    required this.pendingGrades,
    required this.recentlyPublished,
    required this.needsReview,
    required this.analytics,
  });

  final List<SubjectResultsSummaryModel> subjects;
  final List<GradingActivityItem> pendingGrades;
  final List<GradingActivityItem> recentlyPublished;
  final List<GradingActivityItem> needsReview;
  final GradeAnalyticsModel analytics;

  factory ResultsOverviewModel.fromJson(Map<String, dynamic> json) {
    return ResultsOverviewModel(
      subjects: (json['subjects'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SubjectResultsSummaryModel.fromJson)
          .toList(growable: false),
      pendingGrades: (json['pending_grades'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GradingActivityItem.fromJson)
          .toList(growable: false),
      recentlyPublished: (json['recently_published'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GradingActivityItem.fromJson)
          .toList(growable: false),
      needsReview: (json['needs_review'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GradingActivityItem.fromJson)
          .toList(growable: false),
      analytics: GradeAnalyticsModel.fromJson(
        json['analytics'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class SubjectResultsSummaryModel {
  const SubjectResultsSummaryModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.statusLabel,
    required this.latestActivityLabel,
    this.averageScore = 0,
    this.pendingReviewCount = 0,
    this.publishedResultsCount = 0,
    this.studentsCount = 0,
  });

  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final String statusLabel;
  final String latestActivityLabel;
  final double averageScore;
  final int pendingReviewCount;
  final int publishedResultsCount;
  final int studentsCount;

  factory SubjectResultsSummaryModel.fromJson(Map<String, dynamic> json) {
    return SubjectResultsSummaryModel(
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      subjectName: json['subject_name']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'Draft',
      latestActivityLabel: json['latest_activity_label']?.toString() ?? '',
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      pendingReviewCount:
          (json['pending_review_count'] as num?)?.toInt() ?? 0,
      publishedResultsCount:
          (json['published_results_count'] as num?)?.toInt() ?? 0,
      studentsCount: (json['students_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class SubjectResultsModel {
  const SubjectResultsModel({
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.statusLabel,
    required this.categories,
    required this.students,
    required this.recentActivity,
    required this.analytics,
    required this.allowedCategoryKeys,
    this.averageScore = 0,
    this.pendingReviewCount = 0,
    this.publishedResultsCount = 0,
  });

  final int subjectId;
  final String subjectName;
  final String subjectCode;
  final String statusLabel;
  final List<GradeCategoryModel> categories;
  final List<GradeStudentRowModel> students;
  final List<GradingActivityItem> recentActivity;
  final GradeAnalyticsModel analytics;
  final List<String> allowedCategoryKeys;
  final double averageScore;
  final int pendingReviewCount;
  final int publishedResultsCount;

  factory SubjectResultsModel.fromJson(Map<String, dynamic> json) {
    return SubjectResultsModel(
      subjectId: (json['subject_id'] as num?)?.toInt() ?? 0,
      subjectName: json['subject_name']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'Draft',
      categories: (json['categories'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GradeCategoryModel.fromJson)
          .toList(growable: false),
      students: (json['students'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GradeStudentRowModel.fromJson)
          .toList(growable: false),
      recentActivity: (json['recent_activity'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GradingActivityItem.fromJson)
          .toList(growable: false),
      analytics: GradeAnalyticsModel.fromJson(
        json['analytics'] as Map<String, dynamic>? ?? const {},
      ),
      allowedCategoryKeys: (json['allowed_category_keys'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      pendingReviewCount:
          (json['pending_review_count'] as num?)?.toInt() ?? 0,
      publishedResultsCount:
          (json['published_results_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class GradeCategoryModel {
  const GradeCategoryModel({
    required this.key,
    required this.label,
    required this.maxScore,
    required this.statusLabel,
    this.averageScore = 0,
    this.gradedCount = 0,
    this.missingCount = 0,
    this.isEditable = false,
  });

  final String key;
  final String label;
  final double maxScore;
  final String statusLabel;
  final double averageScore;
  final int gradedCount;
  final int missingCount;
  final bool isEditable;

  factory GradeCategoryModel.fromJson(Map<String, dynamic> json) {
    return GradeCategoryModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
      statusLabel: json['status_label']?.toString() ?? 'Draft',
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      gradedCount: (json['graded_count'] as num?)?.toInt() ?? 0,
      missingCount: (json['missing_count'] as num?)?.toInt() ?? 0,
      isEditable: json['is_editable'] == true,
    );
  }
}

class GradeStudentRowModel {
  const GradeStudentRowModel({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.statusLabel,
    required this.entries,
    this.notes,
  });

  final int studentId;
  final String studentName;
  final String studentCode;
  final String statusLabel;
  final String? notes;
  final Map<String, GradeEntryValueModel> entries;

  factory GradeStudentRowModel.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final entries = <String, GradeEntryValueModel>{};
    if (rawEntries is Map) {
      rawEntries.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          entries[key.toString()] = GradeEntryValueModel.fromJson(value);
        } else if (value is Map) {
          entries[key.toString()] = GradeEntryValueModel.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    return GradeStudentRowModel(
      studentId: (json['student_id'] as num?)?.toInt() ?? 0,
      studentName: json['student_name']?.toString() ?? '',
      studentCode: json['student_code']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      notes: json['notes']?.toString(),
      entries: entries,
    );
  }
}

class GradeEntryValueModel {
  const GradeEntryValueModel({
    required this.maxScore,
    required this.statusLabel,
    this.score,
    this.note,
  });

  final double? score;
  final double maxScore;
  final String statusLabel;
  final String? note;

  factory GradeEntryValueModel.fromJson(Map<String, dynamic> json) {
    return GradeEntryValueModel(
      score: (json['score'] as num?)?.toDouble(),
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
      statusLabel: json['status_label']?.toString() ?? 'Draft',
      note: json['note']?.toString(),
    );
  }
}

class GradingActivityItem {
  const GradingActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String subtitle;
  final String statusLabel;
  final DateTime createdAt;

  factory GradingActivityItem.fromJson(Map<String, dynamic> json) {
    return GradingActivityItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'Draft',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime(2026, 4, 22),
    );
  }
}

class GradeAnalyticsModel {
  const GradeAnalyticsModel({
    this.averageScore = 0,
    this.missingGrades = 0,
    this.attendanceCompletion = 0,
    this.gradedQuizzes = 0,
    this.pendingQuizzes = 0,
    this.topPerformerLabel = '',
    this.lowPerformerLabel = '',
  });

  final double averageScore;
  final int missingGrades;
  final int attendanceCompletion;
  final int gradedQuizzes;
  final int pendingQuizzes;
  final String topPerformerLabel;
  final String lowPerformerLabel;

  factory GradeAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return GradeAnalyticsModel(
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      missingGrades: (json['missing_grades'] as num?)?.toInt() ?? 0,
      attendanceCompletion:
          (json['attendance_completion'] as num?)?.toInt() ?? 0,
      gradedQuizzes: (json['graded_quizzes'] as num?)?.toInt() ?? 0,
      pendingQuizzes: (json['pending_quizzes'] as num?)?.toInt() ?? 0,
      topPerformerLabel: json['top_performer_label']?.toString() ?? '',
      lowPerformerLabel: json['low_performer_label']?.toString() ?? '',
    );
  }
}
