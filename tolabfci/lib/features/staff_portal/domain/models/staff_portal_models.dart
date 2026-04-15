import '../../../../core/models/notification_item.dart';

class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.title,
    required this.roleLabel,
    required this.department,
    required this.office,
    required this.phone,
    required this.nationalId,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String title;
  final String roleLabel;
  final String department;
  final String office;
  final String phone;
  final String nationalId;
  final String? avatarUrl;
}

class StaffDashboardData {
  const StaffDashboardData({
    required this.profile,
    required this.quickActions,
    required this.actionRequired,
    required this.todayFocus,
    required this.studentInsights,
    required this.courseHealth,
    required this.activityFeed,
    required this.subjects,
    required this.notifications,
    required this.analytics,
  });

  final StaffProfile profile;
  final List<StaffQuickAction> quickActions;
  final List<StaffActionRequiredItem> actionRequired;
  final List<StaffFocusItem> todayFocus;
  final List<StudentAttentionItem> studentInsights;
  final CourseHealthSummary courseHealth;
  final List<ActivityFeedItem> activityFeed;
  final List<StaffCourseSummary> subjects;
  final List<AppNotificationItem> notifications;
  final StaffAnalyticsData analytics;
}

class StaffQuickAction {
  const StaffQuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    this.subjectId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String? subjectId;
}

class StaffActionRequiredItem {
  const StaffActionRequiredItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.subjectName,
    required this.ctaLabel,
    this.subjectId,
  });

  final String id;
  final String title;
  final String description;
  final StaffPriority priority;
  final String subjectName;
  final String ctaLabel;
  final String? subjectId;
}

class StaffFocusItem {
  const StaffFocusItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.typeLabel,
    this.subjectId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String meta;
  final String typeLabel;
  final String? subjectId;
}

class StudentAttentionItem {
  const StudentAttentionItem({
    required this.studentId,
    required this.name,
    required this.reason,
    required this.severity,
    required this.subjectName,
    required this.engagementLabel,
  });

  final String studentId;
  final String name;
  final String reason;
  final StaffPriority severity;
  final String subjectName;
  final String engagementLabel;
}

class CourseHealthSummary {
  const CourseHealthSummary({
    required this.overallScore,
    required this.statusLabel,
    required this.summary,
    required this.metrics,
  });

  final int overallScore;
  final String statusLabel;
  final String summary;
  final List<HealthMetric> metrics;
}

class HealthMetric {
  const HealthMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final StaffPriority tone;
}

class ActivityFeedItem {
  const ActivityFeedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectName,
    required this.timeLabel,
    required this.typeLabel,
  });

  final String id;
  final String title;
  final String description;
  final String subjectName;
  final String timeLabel;
  final String typeLabel;
}

class StaffCourseSummary {
  const StaffCourseSummary({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.sectionLabel,
    required this.roleLabel,
    required this.accentHex,
    required this.studentCount,
    required this.activeStudents,
    required this.quizCount,
    required this.announcementCount,
    required this.pendingSubmissions,
    required this.healthScore,
    required this.latestUpdate,
  });

  final String id;
  final String name;
  final String code;
  final String department;
  final String sectionLabel;
  final String roleLabel;
  final String accentHex;
  final int studentCount;
  final int activeStudents;
  final int quizCount;
  final int announcementCount;
  final int pendingSubmissions;
  final int healthScore;
  final String latestUpdate;
}

class StaffSubjectWorkspace {
  const StaffSubjectWorkspace({
    required this.subject,
    required this.actionRequired,
    required this.quizzes,
    required this.announcements,
    required this.posts,
    required this.lectures,
    required this.sections,
    required this.schedule,
    required this.students,
    required this.analytics,
  });

  final StaffCourseSummary subject;
  final List<StaffActionRequiredItem> actionRequired;
  final List<StaffQuiz> quizzes;
  final List<StaffAnnouncement> announcements;
  final List<StaffGroupPost> posts;
  final List<StaffSessionLink> lectures;
  final List<StaffSessionLink> sections;
  final List<StaffScheduleEvent> schedule;
  final List<CourseStudentInsight> students;
  final StaffAnalyticsData analytics;
}

enum StaffAnnouncementPriority { normal, important, urgent }

class StaffAnnouncement {
  const StaffAnnouncement({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.priority,
    required this.isPublished,
    required this.createdAt,
    required this.authorName,
    this.attachmentLabel,
  });

  final String id;
  final String subjectId;
  final String title;
  final String content;
  final StaffAnnouncementPriority priority;
  final bool isPublished;
  final DateTime createdAt;
  final String authorName;
  final String? attachmentLabel;

  StaffAnnouncement copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? content,
    StaffAnnouncementPriority? priority,
    bool? isPublished,
    DateTime? createdAt,
    String? authorName,
    String? attachmentLabel,
  }) {
    return StaffAnnouncement(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      attachmentLabel: attachmentLabel ?? this.attachmentLabel,
    );
  }
}

class StaffGroupComment {
  const StaffGroupComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String authorRole;
  final String content;
  final DateTime createdAt;
}

class StaffGroupPost {
  const StaffGroupPost({
    required this.id,
    required this.subjectId,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.createdAt,
    required this.visibilityLabel,
    required this.reactionsCount,
    required this.comments,
    this.attachmentLabel,
  });

  final String id;
  final String subjectId;
  final String authorName;
  final String authorRole;
  final String content;
  final DateTime createdAt;
  final String visibilityLabel;
  final int reactionsCount;
  final List<StaffGroupComment> comments;
  final String? attachmentLabel;

  StaffGroupPost copyWith({
    String? id,
    String? subjectId,
    String? authorName,
    String? authorRole,
    String? content,
    DateTime? createdAt,
    String? visibilityLabel,
    int? reactionsCount,
    List<StaffGroupComment>? comments,
    String? attachmentLabel,
  }) {
    return StaffGroupPost(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      visibilityLabel: visibilityLabel ?? this.visibilityLabel,
      reactionsCount: reactionsCount ?? this.reactionsCount,
      comments: comments ?? this.comments,
      attachmentLabel: attachmentLabel ?? this.attachmentLabel,
    );
  }
}

enum StaffSessionKind { lecture, section }

enum StaffSessionMode { online, offline }

class StaffSessionLink {
  const StaffSessionLink({
    required this.id,
    required this.subjectId,
    required this.kind,
    required this.title,
    required this.description,
    required this.mode,
    required this.startsAt,
    required this.endsAt,
    required this.createdBy,
    this.locationLabel,
    this.meetingLink,
    this.attachmentLabel,
  });

  final String id;
  final String subjectId;
  final StaffSessionKind kind;
  final String title;
  final String description;
  final StaffSessionMode mode;
  final DateTime startsAt;
  final DateTime endsAt;
  final String createdBy;
  final String? locationLabel;
  final String? meetingLink;
  final String? attachmentLabel;

  StaffSessionLink copyWith({
    String? id,
    String? subjectId,
    StaffSessionKind? kind,
    String? title,
    String? description,
    StaffSessionMode? mode,
    DateTime? startsAt,
    DateTime? endsAt,
    String? createdBy,
    String? locationLabel,
    String? meetingLink,
    String? attachmentLabel,
  }) {
    return StaffSessionLink(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      description: description ?? this.description,
      mode: mode ?? this.mode,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      createdBy: createdBy ?? this.createdBy,
      locationLabel: locationLabel ?? this.locationLabel,
      meetingLink: meetingLink ?? this.meetingLink,
      attachmentLabel: attachmentLabel ?? this.attachmentLabel,
    );
  }
}

enum StaffScheduleEventType { quiz, lecture, section, deadline, exam, reminder }

class StaffScheduleEvent {
  const StaffScheduleEvent({
    required this.id,
    required this.subjectId,
    required this.type,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.colorHex,
    this.linkedLabel,
  });

  final String id;
  final String subjectId;
  final StaffScheduleEventType type;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final String colorHex;
  final String? linkedLabel;

  StaffScheduleEvent copyWith({
    String? id,
    String? subjectId,
    StaffScheduleEventType? type,
    String? title,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    String? colorHex,
    String? linkedLabel,
  }) {
    return StaffScheduleEvent(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      colorHex: colorHex ?? this.colorHex,
      linkedLabel: linkedLabel ?? this.linkedLabel,
    );
  }
}

enum EngagementLevel { high, medium, low }

class CourseStudentInsight {
  const CourseStudentInsight({
    required this.id,
    required this.name,
    required this.code,
    required this.email,
    required this.activitySummary,
    required this.quizCompletion,
    required this.submissionsCount,
    required this.lastActiveLabel,
    required this.engagementLevel,
    required this.completedQuizzes,
    required this.totalQuizzes,
    required this.submittedSheets,
    required this.totalSheets,
    required this.averageScore,
  });

  final String id;
  final String name;
  final String code;
  final String email;
  final String activitySummary;
  final double quizCompletion;
  final int submissionsCount;
  final String lastActiveLabel;
  final EngagementLevel engagementLevel;
  final int completedQuizzes;
  final int totalQuizzes;
  final int submittedSheets;
  final int totalSheets;
  final double averageScore;
}

class StaffAnalyticsData {
  const StaffAnalyticsData({
    required this.totalStudents,
    required this.activeStudents,
    required this.quizCompletionRate,
    required this.pendingSubmissions,
    required this.averageScore,
    required this.activityTrend,
    required this.submissionTrend,
    required this.performanceBands,
    required this.completionSplit,
  });

  final int totalStudents;
  final int activeStudents;
  final double quizCompletionRate;
  final int pendingSubmissions;
  final double averageScore;
  final List<AnalyticsPoint> activityTrend;
  final List<AnalyticsPoint> submissionTrend;
  final List<AnalyticsBreakdownItem> performanceBands;
  final List<AnalyticsBreakdownItem> completionSplit;
}

class AnalyticsPoint {
  const AnalyticsPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class AnalyticsBreakdownItem {
  const AnalyticsBreakdownItem({
    required this.label,
    required this.value,
    required this.colorHex,
  });

  final String label;
  final double value;
  final String colorHex;
}

enum StaffQuizStatus { draft, published }

enum StaffQuestionType {
  multipleChoice,
  checkbox,
  trueFalse,
  shortAnswer,
  paragraph,
  dropdown,
}

class StaffQuizChoice {
  const StaffQuizChoice({
    required this.id,
    required this.label,
    this.isCorrect = false,
  });

  final String id;
  final String label;
  final bool isCorrect;

  StaffQuizChoice copyWith({String? id, String? label, bool? isCorrect}) {
    return StaffQuizChoice(
      id: id ?? this.id,
      label: label ?? this.label,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

class StaffQuizQuestion {
  const StaffQuizQuestion({
    required this.id,
    required this.type,
    required this.title,
    required this.points,
    required this.isRequired,
    this.choices = const [],
    this.sampleAnswer,
  });

  final String id;
  final StaffQuestionType type;
  final String title;
  final int points;
  final bool isRequired;
  final List<StaffQuizChoice> choices;
  final String? sampleAnswer;

  StaffQuizQuestion copyWith({
    String? id,
    StaffQuestionType? type,
    String? title,
    int? points,
    bool? isRequired,
    List<StaffQuizChoice>? choices,
    String? sampleAnswer,
  }) {
    return StaffQuizQuestion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      points: points ?? this.points,
      isRequired: isRequired ?? this.isRequired,
      choices: choices ?? this.choices,
      sampleAnswer: sampleAnswer ?? this.sampleAnswer,
    );
  }
}

class StaffQuiz {
  const StaffQuiz({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.durationMinutes,
    required this.status,
    required this.isGraded,
    required this.isPractice,
    required this.questions,
    required this.createdBy,
  });

  final String id;
  final String subjectId;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final int durationMinutes;
  final StaffQuizStatus status;
  final bool isGraded;
  final bool isPractice;
  final List<StaffQuizQuestion> questions;
  final String createdBy;

  int get totalMarks =>
      questions.fold<int>(0, (sum, question) => sum + question.points);

  int get questionCount => questions.length;

  StaffQuiz copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    int? durationMinutes,
    StaffQuizStatus? status,
    bool? isGraded,
    bool? isPractice,
    List<StaffQuizQuestion>? questions,
    String? createdBy,
  }) {
    return StaffQuiz(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      isGraded: isGraded ?? this.isGraded,
      isPractice: isPractice ?? this.isPractice,
      questions: questions ?? this.questions,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

enum StaffPriority { high, medium, low }
