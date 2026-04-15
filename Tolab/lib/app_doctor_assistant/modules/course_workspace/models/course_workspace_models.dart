enum CourseWorkspaceTab {
  overview('overview'),
  quizBuilder('quiz-builder'),
  announcements('announcements'),
  group('group'),
  sessions('sessions'),
  schedule('schedule'),
  students('students'),
  analytics('analytics');

  const CourseWorkspaceTab(this.key);

  final String key;

  static CourseWorkspaceTab fromKey(String? value) {
    return CourseWorkspaceTab.values.firstWhere(
      (tab) => tab.key == value,
      orElse: () => CourseWorkspaceTab.overview,
    );
  }
}

enum CourseQuizPublication { draft, published }

enum CourseQuizMode { graded, practice }

enum CourseQuestionType {
  multipleChoice,
  checkbox,
  trueFalse,
  shortAnswer,
  paragraph,
  dropdown,
}

enum CourseAnnouncementPriority { normal, important, urgent }

enum CoursePostVisibility { enrolled, sectionsOnly, assistantsOnly }

enum CourseSessionKind { lecture, section }

enum CourseDeliveryMode { online, offline }

enum CourseEventType { lecture, section, quiz, deadline, exam, reminder }

enum CourseEngagementLevel { high, medium, low }

class CourseWorkspace {
  const CourseWorkspace({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.department,
    required this.termLabel,
    required this.description,
    required this.studentCount,
    required this.activeStudents,
    required this.healthScore,
    required this.healthSummary,
    required this.actionRequired,
    required this.todayFocus,
    required this.studentInsights,
    required this.activityFeed,
    required this.quizzes,
    required this.announcements,
    required this.posts,
    required this.sessions,
    required this.events,
    required this.students,
    required this.analytics,
  });

  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final String department;
  final String termLabel;
  final String description;
  final int studentCount;
  final int activeStudents;
  final int healthScore;
  final String healthSummary;
  final List<CourseActionItem> actionRequired;
  final List<CourseFocusItem> todayFocus;
  final List<CourseInsightItem> studentInsights;
  final List<CourseFeedItem> activityFeed;
  final List<CourseQuiz> quizzes;
  final List<CourseAnnouncement> announcements;
  final List<CourseGroupPost> posts;
  final List<CourseSessionLink> sessions;
  final List<CourseScheduleEvent> events;
  final List<CourseStudent> students;
  final CourseAnalytics analytics;

  CourseWorkspace copyWith({
    List<CourseQuiz>? quizzes,
    List<CourseAnnouncement>? announcements,
    List<CourseGroupPost>? posts,
    List<CourseSessionLink>? sessions,
    List<CourseScheduleEvent>? events,
    List<CourseStudent>? students,
  }) {
    return CourseWorkspace(
      subjectId: subjectId,
      subjectCode: subjectCode,
      subjectName: subjectName,
      department: department,
      termLabel: termLabel,
      description: description,
      studentCount: studentCount,
      activeStudents: activeStudents,
      healthScore: healthScore,
      healthSummary: healthSummary,
      actionRequired: actionRequired,
      todayFocus: todayFocus,
      studentInsights: studentInsights,
      activityFeed: activityFeed,
      quizzes: quizzes ?? this.quizzes,
      announcements: announcements ?? this.announcements,
      posts: posts ?? this.posts,
      sessions: sessions ?? this.sessions,
      events: events ?? this.events,
      students: students ?? this.students,
      analytics: analytics,
    );
  }
}

class CourseActionItem {
  const CourseActionItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.severity,
    required this.targetTab,
  });

  final String id;
  final String title;
  final String caption;
  final String severity;
  final CourseWorkspaceTab targetTab;
}

class CourseFocusItem {
  const CourseFocusItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.timeLabel,
    required this.targetTab,
  });

  final String id;
  final String title;
  final String caption;
  final String timeLabel;
  final CourseWorkspaceTab targetTab;
}

class CourseInsightItem {
  const CourseInsightItem({
    required this.id,
    required this.title,
    required this.value,
    required this.caption,
    required this.tone,
  });

  final String id;
  final String title;
  final String value;
  final String caption;
  final String tone;
}

class CourseFeedItem {
  const CourseFeedItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final String type;
}

class CourseQuiz {
  const CourseQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.durationMinutes,
    required this.publication,
    required this.mode,
    required this.questions,
  });

  final String id;
  final String title;
  final String description;
  final DateTime? startAt;
  final DateTime? endAt;
  final int durationMinutes;
  final CourseQuizPublication publication;
  final CourseQuizMode mode;
  final List<CourseQuizQuestion> questions;

  int get totalMarks => questions.fold<int>(0, (sum, item) => sum + item.marks);

  int get questionCount => questions.length;

  CourseQuiz copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    int? durationMinutes,
    CourseQuizPublication? publication,
    CourseQuizMode? mode,
    List<CourseQuizQuestion>? questions,
  }) {
    return CourseQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      publication: publication ?? this.publication,
      mode: mode ?? this.mode,
      questions: questions ?? this.questions,
    );
  }
}

class CourseQuizQuestion {
  const CourseQuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    this.options = const <String>[],
    this.correctOptionIndexes = const <int>{},
    this.correctAnswerText,
    this.isRequired = true,
    this.marks = 1,
  });

  final String id;
  final CourseQuestionType type;
  final String prompt;
  final List<String> options;
  final Set<int> correctOptionIndexes;
  final String? correctAnswerText;
  final bool isRequired;
  final int marks;

  CourseQuizQuestion copyWith({
    String? id,
    CourseQuestionType? type,
    String? prompt,
    List<String>? options,
    Set<int>? correctOptionIndexes,
    String? correctAnswerText,
    bool? isRequired,
    int? marks,
  }) {
    return CourseQuizQuestion(
      id: id ?? this.id,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      options: options ?? this.options,
      correctOptionIndexes: correctOptionIndexes ?? this.correctOptionIndexes,
      correctAnswerText: correctAnswerText ?? this.correctAnswerText,
      isRequired: isRequired ?? this.isRequired,
      marks: marks ?? this.marks,
    );
  }
}

class CourseAnnouncement {
  const CourseAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.isPublished,
    required this.publishedAt,
    this.attachmentUrl,
  });

  final String id;
  final String title;
  final String body;
  final CourseAnnouncementPriority priority;
  final bool isPublished;
  final DateTime publishedAt;
  final String? attachmentUrl;

  CourseAnnouncement copyWith({
    String? id,
    String? title,
    String? body,
    CourseAnnouncementPriority? priority,
    bool? isPublished,
    DateTime? publishedAt,
    String? attachmentUrl,
  }) {
    return CourseAnnouncement(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      priority: priority ?? this.priority,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}

class CourseGroupPost {
  const CourseGroupPost({
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.visibility,
    required this.comments,
    this.attachmentUrl,
    this.reactionCount = 0,
  });

  final String id;
  final String authorName;
  final String body;
  final DateTime createdAt;
  final CoursePostVisibility visibility;
  final List<CoursePostComment> comments;
  final String? attachmentUrl;
  final int reactionCount;

  CourseGroupPost copyWith({
    List<CoursePostComment>? comments,
  }) {
    return CourseGroupPost(
      id: id,
      authorName: authorName,
      body: body,
      createdAt: createdAt,
      visibility: visibility,
      comments: comments ?? this.comments,
      attachmentUrl: attachmentUrl,
      reactionCount: reactionCount,
    );
  }
}

class CoursePostComment {
  const CoursePostComment({
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String body;
  final DateTime createdAt;
}

class CourseSessionLink {
  const CourseSessionLink({
    required this.id,
    required this.kind,
    required this.title,
    required this.deliveryMode,
    required this.scheduledAt,
    required this.description,
    required this.isPublished,
    this.meetingLink,
    this.locationLabel,
    this.attachmentUrl,
  });

  final String id;
  final CourseSessionKind kind;
  final String title;
  final CourseDeliveryMode deliveryMode;
  final DateTime scheduledAt;
  final String description;
  final bool isPublished;
  final String? meetingLink;
  final String? locationLabel;
  final String? attachmentUrl;

  CourseSessionLink copyWith({
    String? id,
    CourseSessionKind? kind,
    String? title,
    CourseDeliveryMode? deliveryMode,
    DateTime? scheduledAt,
    String? description,
    bool? isPublished,
    String? meetingLink,
    String? locationLabel,
    String? attachmentUrl,
  }) {
    return CourseSessionLink(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      description: description ?? this.description,
      isPublished: isPublished ?? this.isPublished,
      meetingLink: meetingLink ?? this.meetingLink,
      locationLabel: locationLabel ?? this.locationLabel,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}

class CourseScheduleEvent {
  const CourseScheduleEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startsAt,
    required this.endsAt,
    required this.description,
    required this.statusLabel,
  });

  final String id;
  final String title;
  final CourseEventType type;
  final DateTime startsAt;
  final DateTime endsAt;
  final String description;
  final String statusLabel;

  CourseScheduleEvent copyWith({
    String? id,
    String? title,
    CourseEventType? type,
    DateTime? startsAt,
    DateTime? endsAt,
    String? description,
    String? statusLabel,
  }) {
    return CourseScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      description: description ?? this.description,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }
}

class CourseStudent {
  const CourseStudent({
    required this.id,
    required this.name,
    required this.code,
    required this.email,
    required this.activitySummary,
    required this.quizCompletionRate,
    required this.submissionsCount,
    required this.lastActive,
    required this.engagement,
    required this.completedSheets,
    required this.completedQuizzes,
    required this.averageGrade,
  });

  final String id;
  final String name;
  final String code;
  final String email;
  final String activitySummary;
  final int quizCompletionRate;
  final int submissionsCount;
  final DateTime lastActive;
  final CourseEngagementLevel engagement;
  final int completedSheets;
  final int completedQuizzes;
  final double averageGrade;
}

class CourseAnalytics {
  const CourseAnalytics({
    required this.totalStudents,
    required this.activeStudents,
    required this.quizCompleted,
    required this.pendingSubmissions,
    required this.averageGrade,
    required this.activityTrend,
    required this.submissionsTrend,
    required this.performanceDistribution,
    required this.completionBreakdown,
    required this.performerBreakdown,
  });

  final int totalStudents;
  final int activeStudents;
  final int quizCompleted;
  final int pendingSubmissions;
  final double averageGrade;
  final List<CourseChartPoint> activityTrend;
  final List<CourseChartPoint> submissionsTrend;
  final List<CourseChartPoint> performanceDistribution;
  final List<CourseBreakdownSlice> completionBreakdown;
  final List<CourseBreakdownSlice> performerBreakdown;
}

class CourseChartPoint {
  const CourseChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class CourseBreakdownSlice {
  const CourseBreakdownSlice({
    required this.label,
    required this.value,
    required this.hexColor,
  });

  final String label;
  final double value;
  final int hexColor;
}
