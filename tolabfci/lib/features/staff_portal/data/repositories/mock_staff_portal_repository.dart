import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification_item.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/app_session.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/staff_portal_models.dart';
import '../../domain/repositories/staff_portal_repository.dart';

final staffPortalRepositoryProvider = Provider<StaffPortalRepository>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return MockStaffPortalRepository(role: role);
});

class MockStaffPortalRepository implements StaffPortalRepository {
  MockStaffPortalRepository({required AppUserRole role})
    : _profile = _buildProfile(role) {
    final now = DateTime.now();
    _subjects = _buildSubjects(role);
    _quizzesBySubject = _buildQuizzes(now);
    _announcementsBySubject = _buildAnnouncements(now);
    _postsBySubject = _buildPosts(now);
    _lecturesBySubject = _buildLectures(now);
    _sectionsBySubject = _buildSections(now);
    _scheduleBySubject = _buildSchedule(now);
    _studentsBySubject = _buildStudents();
    _notifications = _buildNotifications(now);
    _notificationsController.add(_notifications);
  }

  final StaffProfile _profile;
  final _notificationsController =
      StreamController<List<AppNotificationItem>>.broadcast();

  late List<StaffCourseSummary> _subjects;
  late Map<String, List<StaffQuiz>> _quizzesBySubject;
  late Map<String, List<StaffAnnouncement>> _announcementsBySubject;
  late Map<String, List<StaffGroupPost>> _postsBySubject;
  late Map<String, List<StaffSessionLink>> _lecturesBySubject;
  late Map<String, List<StaffSessionLink>> _sectionsBySubject;
  late Map<String, List<StaffScheduleEvent>> _scheduleBySubject;
  late Map<String, List<CourseStudentInsight>> _studentsBySubject;
  late List<AppNotificationItem> _notifications;

  @override
  Future<StaffDashboardData> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final subjects = await fetchCourses();

    return StaffDashboardData(
      profile: _profile,
      quickActions: [
        StaffQuickAction(
          id: 'add_quiz',
          title: 'Add Quiz',
          subtitle: 'Draft, review, and publish assessments.',
          iconName: 'quiz',
          subjectId: subjects.first.id,
        ),
        StaffQuickAction(
          id: 'add_announcement',
          title: 'Publish Announcement',
          subtitle: 'Notify students with a role-aware update.',
          iconName: 'campaign',
          subjectId: subjects.first.id,
        ),
        StaffQuickAction(
          id: 'add_lecture',
          title: 'Add Lecture',
          subtitle: 'Share a lecture link or offline location quickly.',
          iconName: 'smart_display',
          subjectId: subjects.first.id,
        ),
        StaffQuickAction(
          id: 'view_students',
          title: 'View Students',
          subtitle: 'Track activity, completion, and engagement.',
          iconName: 'groups',
          subjectId: subjects.first.id,
        ),
      ],
      actionRequired: _buildActionRequired(),
      todayFocus: _buildTodayFocus(),
      studentInsights: _buildStudentAttentionItems(),
      courseHealth: _buildCourseHealthSummary(),
      activityFeed: _buildActivityFeed(),
      subjects: subjects,
      notifications: _notifications.take(5).toList(),
      analytics: _aggregateAnalytics(),
    );
  }

  @override
  Future<StaffProfile> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _profile;
  }

  @override
  Future<List<StaffCourseSummary>> fetchCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return _subjects.map(_decorateCourseSummary).toList();
  }

  @override
  Future<StaffSubjectWorkspace> fetchSubjectWorkspace(String subjectId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final subject = _subjects.firstWhere((item) => item.id == subjectId);

    return StaffSubjectWorkspace(
      subject: _decorateCourseSummary(subject),
      actionRequired: _buildActionRequired()
          .where((item) => item.subjectName == subject.name)
          .toList(),
      quizzes: [..._quizzesBySubject[subjectId] ?? const []]
        ..sort((a, b) => b.startsAt.compareTo(a.startsAt)),
      announcements: [..._announcementsBySubject[subjectId] ?? const []]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      posts: [..._postsBySubject[subjectId] ?? const []]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      lectures: [..._lecturesBySubject[subjectId] ?? const []]
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
      sections: [..._sectionsBySubject[subjectId] ?? const []]
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
      schedule: [..._scheduleBySubject[subjectId] ?? const []]
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
      students: [..._studentsBySubject[subjectId] ?? const []]
        ..sort((a, b) => b.averageScore.compareTo(a.averageScore)),
      analytics: _analyticsForSubject(subjectId),
    );
  }

  @override
  Future<List<StaffScheduleEvent>> fetchSchedule() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _scheduleBySubject.values.expand((items) => items).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<List<AppNotificationItem>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _notifications;
  }

  @override
  Stream<List<AppNotificationItem>> watchNotifications() =>
      _notificationsController.stream;

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    _notifications = _notifications
        .map(
          (item) =>
              item.id == notificationId ? item.copyWith(isRead: true) : item,
        )
        .toList();
    _notificationsController.add(_notifications);
  }

  @override
  Future<StaffQuiz> saveQuiz({
    required String subjectId,
    required StaffQuiz quiz,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final existing = _quizzesBySubject[subjectId] ?? <StaffQuiz>[];
    final nextQuiz = quiz.copyWith(
      subjectId: subjectId,
      id: quiz.id.isEmpty ? 'quiz-${existing.length + 1}-$subjectId' : quiz.id,
    );

    _quizzesBySubject[subjectId] = _upsertById(
      existing,
      nextQuiz,
      (item) => item.id,
    );
    _pushNotification(
      title: nextQuiz.status == StaffQuizStatus.published
          ? 'Quiz published'
          : 'Quiz draft saved',
      body: '${nextQuiz.title} was updated for ${_subjectName(subjectId)}.',
      category: 'Quizzes',
      routeName: RouteNames.subjectDetails,
      subjectId: subjectId,
      isImportant: nextQuiz.status == StaffQuizStatus.published,
    );
    return nextQuiz;
  }

  @override
  Future<StaffAnnouncement> saveAnnouncement({
    required String subjectId,
    required StaffAnnouncement announcement,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final existing =
        _announcementsBySubject[subjectId] ?? <StaffAnnouncement>[];
    final nextAnnouncement = announcement.copyWith(
      subjectId: subjectId,
      id: announcement.id.isEmpty
          ? 'announcement-${existing.length + 1}-$subjectId'
          : announcement.id,
      createdAt: DateTime.now(),
      authorName: _profile.fullName,
    );
    _announcementsBySubject[subjectId] = _upsertById(
      existing,
      nextAnnouncement,
      (item) => item.id,
    );
    _pushNotification(
      title: nextAnnouncement.isPublished
          ? 'Announcement published'
          : 'Announcement saved',
      body: nextAnnouncement.title,
      category: 'Announcements',
      routeName: RouteNames.subjectDetails,
      subjectId: subjectId,
      isImportant:
          nextAnnouncement.priority == StaffAnnouncementPriority.urgent,
    );
    return nextAnnouncement;
  }

  @override
  Future<void> deleteAnnouncement({
    required String subjectId,
    required String announcementId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    _announcementsBySubject[subjectId] = [
      ...?_announcementsBySubject[subjectId],
    ].where((item) => item.id != announcementId).toList();
  }

  @override
  Future<StaffAnnouncement> toggleAnnouncementPublication({
    required String subjectId,
    required String announcementId,
  }) async {
    final announcements = [...?_announcementsBySubject[subjectId]];
    final current = announcements.firstWhere(
      (item) => item.id == announcementId,
    );
    final updated = current.copyWith(isPublished: !current.isPublished);
    _announcementsBySubject[subjectId] = _upsertById(
      announcements,
      updated,
      (item) => item.id,
    );
    return updated;
  }

  @override
  Future<StaffGroupPost> savePost({
    required String subjectId,
    required StaffGroupPost post,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final posts = _postsBySubject[subjectId] ?? <StaffGroupPost>[];
    final nextPost = post.copyWith(
      id: post.id.isEmpty ? 'post-${posts.length + 1}-$subjectId' : post.id,
      subjectId: subjectId,
      createdAt: DateTime.now(),
    );
    _postsBySubject[subjectId] = _upsertById(
      posts,
      nextPost,
      (item) => item.id,
    );
    return nextPost;
  }

  @override
  Future<void> addComment({
    required String subjectId,
    required String postId,
    required StaffGroupComment comment,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final posts = [...?_postsBySubject[subjectId]];
    _postsBySubject[subjectId] = posts.map((post) {
      if (post.id != postId) {
        return post;
      }
      return post.copyWith(
        comments: [
          ...post.comments,
          StaffGroupComment(
            id: comment.id.isEmpty
                ? 'comment-${post.comments.length + 1}-$postId'
                : comment.id,
            authorName: comment.authorName,
            authorRole: comment.authorRole,
            content: comment.content,
            createdAt: DateTime.now(),
          ),
        ],
      );
    }).toList();
  }

  @override
  Future<StaffSessionLink> saveSession({
    required String subjectId,
    required StaffSessionLink session,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final targetMap = session.kind == StaffSessionKind.lecture
        ? _lecturesBySubject
        : _sectionsBySubject;
    final sessions = targetMap[subjectId] ?? <StaffSessionLink>[];
    final nextSession = session.copyWith(
      id: session.id.isEmpty
          ? '${session.kind.name}-${sessions.length + 1}-$subjectId'
          : session.id,
      subjectId: subjectId,
      createdBy: _profile.fullName,
    );
    targetMap[subjectId] = _upsertById(
      sessions,
      nextSession,
      (item) => item.id,
    );
    return nextSession;
  }

  @override
  Future<StaffScheduleEvent> saveScheduleEvent({
    required String subjectId,
    required StaffScheduleEvent event,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final events = _scheduleBySubject[subjectId] ?? <StaffScheduleEvent>[];
    final nextEvent = event.copyWith(
      id: event.id.isEmpty ? 'event-${events.length + 1}-$subjectId' : event.id,
      subjectId: subjectId,
    );
    _scheduleBySubject[subjectId] = _upsertById(
      events,
      nextEvent,
      (item) => item.id,
    );
    return nextEvent;
  }

  @override
  Future<void> deleteScheduleEvent({
    required String subjectId,
    required String eventId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _scheduleBySubject[subjectId] = [
      ...?_scheduleBySubject[subjectId],
    ].where((item) => item.id != eventId).toList();
  }

  void _pushNotification({
    required String title,
    required String body,
    required String category,
    required String routeName,
    required String subjectId,
    bool isImportant = false,
  }) {
    _notifications = [
      AppNotificationItem(
        id: 'staff-notification-${_notifications.length + 1}',
        title: title,
        body: body,
        createdAt: DateTime.now(),
        createdAtLabel: 'just now',
        category: category,
        isRead: false,
        routeName: routeName,
        pathParameters: {'subjectId': subjectId},
        isImportant: isImportant,
      ),
      ..._notifications,
    ];
    _notificationsController.add(_notifications);
  }

  StaffCourseSummary _decorateCourseSummary(StaffCourseSummary subject) {
    final subjectId = subject.id;
    final quizzes = _quizzesBySubject[subjectId] ?? const [];
    final announcements = _announcementsBySubject[subjectId] ?? const [];
    final students = _studentsBySubject[subjectId] ?? const [];
    final pendingSubmissions = students
        .where((student) => student.submittedSheets < student.totalSheets)
        .length;
    final healthScore = _analyticsForSubject(
      subjectId,
    ).averageScore.round().clamp(54, 98);

    return StaffCourseSummary(
      id: subject.id,
      name: subject.name,
      code: subject.code,
      department: subject.department,
      sectionLabel: subject.sectionLabel,
      roleLabel: subject.roleLabel,
      accentHex: subject.accentHex,
      studentCount: students.length,
      activeStudents: students
          .where((student) => student.engagementLevel != EngagementLevel.low)
          .length,
      quizCount: quizzes.length,
      announcementCount: announcements.length,
      pendingSubmissions: pendingSubmissions,
      healthScore: healthScore,
      latestUpdate: announcements.isEmpty
          ? subject.latestUpdate
          : announcements.first.title,
    );
  }

  List<StaffActionRequiredItem> _buildActionRequired() {
    final items = <StaffActionRequiredItem>[];

    for (final subject in _subjects) {
      final quizzes = _quizzesBySubject[subject.id] ?? const [];
      final lectures = _lecturesBySubject[subject.id] ?? const [];
      final students = _studentsBySubject[subject.id] ?? const [];

      if (quizzes.any((quiz) => quiz.status == StaffQuizStatus.draft)) {
        items.add(
          StaffActionRequiredItem(
            id: 'draft-quiz-${subject.id}',
            title: 'Quiz draft still needs review',
            description:
                'One assessment is still saved as draft and not visible to students.',
            priority: StaffPriority.high,
            subjectName: subject.name,
            ctaLabel: 'Open quiz builder',
            subjectId: subject.id,
          ),
        );
      }

      if (lectures.isEmpty) {
        items.add(
          StaffActionRequiredItem(
            id: 'lecture-missing-${subject.id}',
            title: 'Upcoming lecture is missing a direct access link',
            description:
                'Students still need a meeting link or classroom confirmation.',
            priority: StaffPriority.medium,
            subjectName: subject.name,
            ctaLabel: 'Add lecture',
            subjectId: subject.id,
          ),
        );
      }

      if (students.any(
        (student) => student.engagementLevel == EngagementLevel.low,
      )) {
        items.add(
          StaffActionRequiredItem(
            id: 'engagement-${subject.id}',
            title: 'Low engagement students need attention',
            description:
                'A focused reminder or quick follow-up could improve attendance.',
            priority: StaffPriority.medium,
            subjectName: subject.name,
            ctaLabel: 'View students',
            subjectId: subject.id,
          ),
        );
      }
    }

    return items;
  }

  List<StaffFocusItem> _buildTodayFocus() {
    final now = DateTime.now();
    final schedule =
        _scheduleBySubject.values
            .expand((items) => items)
            .where(
              (event) => event.startsAt.isAfter(
                now.subtract(const Duration(hours: 2)),
              ),
            )
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return schedule.take(4).map((event) {
      return StaffFocusItem(
        id: event.id,
        title: event.title,
        subtitle: _subjectName(event.subjectId),
        meta:
            '${event.startsAt.hour.toString().padLeft(2, '0')}:${event.startsAt.minute.toString().padLeft(2, '0')}',
        typeLabel: event.type.name,
        subjectId: event.subjectId,
      );
    }).toList();
  }

  List<StudentAttentionItem> _buildStudentAttentionItems() {
    return _studentsBySubject.entries
        .expand(
          (entry) => entry.value
              .where(
                (student) => student.engagementLevel != EngagementLevel.high,
              )
              .take(2)
              .map(
                (student) => StudentAttentionItem(
                  studentId: student.id,
                  name: student.name,
                  reason: student.engagementLevel == EngagementLevel.low
                      ? 'Low participation and pending work are increasing.'
                      : 'Participation is stable but still needs follow-up.',
                  severity: student.engagementLevel == EngagementLevel.low
                      ? StaffPriority.high
                      : StaffPriority.medium,
                  subjectName: _subjectName(entry.key),
                  engagementLabel: student.activitySummary,
                ),
              ),
        )
        .take(6)
        .toList();
  }

  CourseHealthSummary _buildCourseHealthSummary() {
    final analytics = _aggregateAnalytics();
    final score = analytics.averageScore.round().clamp(58, 96);

    return CourseHealthSummary(
      overallScore: score,
      statusLabel: score >= 85
          ? 'Healthy'
          : score >= 70
          ? 'Watch'
          : 'At risk',
      summary: score >= 80
          ? 'Delivery pace, engagement, and assessment completion are trending well.'
          : 'Some courses need attention around participation and pending submissions.',
      metrics: [
        HealthMetric(
          label: 'Active students',
          value: '${analytics.activeStudents}',
          tone: StaffPriority.low,
        ),
        HealthMetric(
          label: 'Pending submissions',
          value: '${analytics.pendingSubmissions}',
          tone: analytics.pendingSubmissions > 8
              ? StaffPriority.high
              : StaffPriority.medium,
        ),
        HealthMetric(
          label: 'Quiz completion',
          value: '${analytics.quizCompletionRate.round()}%',
          tone: analytics.quizCompletionRate >= 75
              ? StaffPriority.low
              : StaffPriority.medium,
        ),
      ],
    );
  }

  List<ActivityFeedItem> _buildActivityFeed() {
    final items = <ActivityFeedItem>[];

    for (final subject in _subjects) {
      final announcements = _announcementsBySubject[subject.id] ?? const [];
      final posts = _postsBySubject[subject.id] ?? const [];
      final quizzes = _quizzesBySubject[subject.id] ?? const [];

      if (announcements.isNotEmpty) {
        final latest = announcements.first;
        items.add(
          ActivityFeedItem(
            id: latest.id,
            title: latest.title,
            description: latest.content,
            subjectName: subject.name,
            timeLabel: 'recently',
            typeLabel: 'Announcement',
          ),
        );
      }

      if (posts.isNotEmpty) {
        final latest = posts.first;
        items.add(
          ActivityFeedItem(
            id: latest.id,
            title: '${latest.authorName} posted in group',
            description: latest.content,
            subjectName: subject.name,
            timeLabel: 'today',
            typeLabel: 'Group',
          ),
        );
      }

      if (quizzes.isNotEmpty) {
        final latest = quizzes.first;
        items.add(
          ActivityFeedItem(
            id: latest.id,
            title: latest.title,
            description: latest.status == StaffQuizStatus.published
                ? 'Quiz is live for students.'
                : 'Quiz is still in draft state.',
            subjectName: subject.name,
            timeLabel: 'this week',
            typeLabel: 'Quiz',
          ),
        );
      }
    }

    return items.take(8).toList();
  }

  StaffAnalyticsData _aggregateAnalytics() {
    final students = _studentsBySubject.values
        .expand((items) => items)
        .toList();
    final totalStudents = students.length;
    final activeStudents = students
        .where((student) => student.engagementLevel != EngagementLevel.low)
        .length;
    final pendingSubmissions = students
        .where((student) => student.submittedSheets < student.totalSheets)
        .length;
    final quizCompletionRate = totalStudents == 0
        ? 0.0
        : students
                  .map((student) => student.quizCompletion)
                  .reduce((a, b) => a + b) /
              totalStudents.toDouble();
    final averageScore = totalStudents == 0
        ? 0.0
        : students
                  .map((student) => student.averageScore)
                  .reduce((a, b) => a + b) /
              totalStudents.toDouble();

    return StaffAnalyticsData(
      totalStudents: totalStudents,
      activeStudents: activeStudents,
      quizCompletionRate: quizCompletionRate,
      pendingSubmissions: pendingSubmissions,
      averageScore: averageScore,
      activityTrend: const [
        AnalyticsPoint(label: 'Mon', value: 44),
        AnalyticsPoint(label: 'Tue', value: 58),
        AnalyticsPoint(label: 'Wed', value: 72),
        AnalyticsPoint(label: 'Thu', value: 64),
        AnalyticsPoint(label: 'Fri', value: 81),
      ],
      submissionTrend: const [
        AnalyticsPoint(label: 'W1', value: 14),
        AnalyticsPoint(label: 'W2', value: 20),
        AnalyticsPoint(label: 'W3', value: 27),
        AnalyticsPoint(label: 'W4', value: 23),
        AnalyticsPoint(label: 'W5', value: 29),
      ],
      performanceBands: const [
        AnalyticsBreakdownItem(label: 'High', value: 42, colorHex: '#4E7CF5'),
        AnalyticsBreakdownItem(label: 'Medium', value: 38, colorHex: '#3DB6B0'),
        AnalyticsBreakdownItem(label: 'Low', value: 20, colorHex: '#E17878'),
      ],
      completionSplit: [
        AnalyticsBreakdownItem(
          label: 'Completed',
          value: quizCompletionRate,
          colorHex: '#4DAA73',
        ),
        AnalyticsBreakdownItem(
          label: 'Pending',
          value: (100 - quizCompletionRate).clamp(0, 100).toDouble(),
          colorHex: '#F1B95D',
        ),
      ],
    );
  }

  StaffAnalyticsData _analyticsForSubject(String subjectId) {
    final students = _studentsBySubject[subjectId] ?? const [];
    if (students.isEmpty) {
      return const StaffAnalyticsData(
        totalStudents: 0,
        activeStudents: 0,
        quizCompletionRate: 0,
        pendingSubmissions: 0,
        averageScore: 0,
        activityTrend: [],
        submissionTrend: [],
        performanceBands: [],
        completionSplit: [],
      );
    }

    final quizCompletionRate =
        students.map((item) => item.quizCompletion).reduce((a, b) => a + b) /
        students.length.toDouble();
    final averageScore =
        students.map((item) => item.averageScore).reduce((a, b) => a + b) /
        students.length.toDouble();

    return StaffAnalyticsData(
      totalStudents: students.length,
      activeStudents: students
          .where((student) => student.engagementLevel != EngagementLevel.low)
          .length,
      quizCompletionRate: quizCompletionRate,
      pendingSubmissions: students
          .where((student) => student.submittedSheets < student.totalSheets)
          .length,
      averageScore: averageScore,
      activityTrend: const [
        AnalyticsPoint(label: 'Sat', value: 22),
        AnalyticsPoint(label: 'Sun', value: 35),
        AnalyticsPoint(label: 'Mon', value: 48),
        AnalyticsPoint(label: 'Tue', value: 41),
        AnalyticsPoint(label: 'Wed', value: 63),
      ],
      submissionTrend: const [
        AnalyticsPoint(label: 'Quiz 1', value: 72),
        AnalyticsPoint(label: 'Quiz 2', value: 84),
        AnalyticsPoint(label: 'Sheet 1', value: 66),
        AnalyticsPoint(label: 'Sheet 2', value: 78),
      ],
      performanceBands: const [
        AnalyticsBreakdownItem(label: 'High', value: 34, colorHex: '#4E7CF5'),
        AnalyticsBreakdownItem(label: 'Medium', value: 46, colorHex: '#3DB6B0'),
        AnalyticsBreakdownItem(label: 'Low', value: 20, colorHex: '#E17878'),
      ],
      completionSplit: [
        AnalyticsBreakdownItem(
          label: 'Completed',
          value: quizCompletionRate,
          colorHex: '#4DAA73',
        ),
        AnalyticsBreakdownItem(
          label: 'Pending',
          value: (100 - quizCompletionRate).clamp(0, 100).toDouble(),
          colorHex: '#F1B95D',
        ),
      ],
    );
  }

  String _subjectName(String subjectId) {
    return _subjects.firstWhere((subject) => subject.id == subjectId).name;
  }

  static StaffProfile _buildProfile(AppUserRole role) {
    return switch (role) {
      AppUserRole.doctor => const StaffProfile(
        id: 'doctor-1',
        fullName: 'Dr. Omar Nabil',
        email: 'omar.nabil@tolab.edu',
        title: 'Principal Lecturer',
        roleLabel: 'Doctor',
        department: 'Computer Science',
        office: 'A4-216',
        phone: '+20 100 200 3000',
        nationalId: '28601011234567',
      ),
      AppUserRole.assistant => const StaffProfile(
        id: 'assistant-1',
        fullName: 'Eng. Nora Sameh',
        email: 'nora.sameh@tolab.edu',
        title: 'Teaching Assistant',
        roleLabel: 'Assistant',
        department: 'Computer Science',
        office: 'Lab-3',
        phone: '+20 100 555 2299',
        nationalId: '29701011234567',
      ),
      AppUserRole.student => const StaffProfile(
        id: 'doctor-1',
        fullName: 'Dr. Omar Nabil',
        email: 'omar.nabil@tolab.edu',
        title: 'Principal Lecturer',
        roleLabel: 'Doctor',
        department: 'Computer Science',
        office: 'A4-216',
        phone: '+20 100 200 3000',
        nationalId: '28601011234567',
      ),
    };
  }

  static List<StaffCourseSummary> _buildSubjects(AppUserRole role) {
    final roleLabel = role == AppUserRole.assistant
        ? 'Assistant lead'
        : 'Course owner';
    return [
      StaffCourseSummary(
        id: 'subject-1',
        name: 'Advanced Mobile Applications',
        code: 'CS401',
        department: 'Computer Science',
        sectionLabel: 'Section A',
        roleLabel: roleLabel,
        accentHex: '#4E7CF5',
        studentCount: 0,
        activeStudents: 0,
        quizCount: 0,
        announcementCount: 0,
        pendingSubmissions: 0,
        healthScore: 0,
        latestUpdate: 'New lecture materials were published.',
      ),
      StaffCourseSummary(
        id: 'subject-2',
        name: 'Cloud Computing',
        code: 'CS409',
        department: 'Information Systems',
        sectionLabel: 'Section B',
        roleLabel: roleLabel,
        accentHex: '#3DB6B0',
        studentCount: 0,
        activeStudents: 0,
        quizCount: 0,
        announcementCount: 0,
        pendingSubmissions: 0,
        healthScore: 0,
        latestUpdate: 'Reminder: practical deadline closes tomorrow.',
      ),
    ];
  }

  static Map<String, List<StaffQuiz>> _buildQuizzes(DateTime now) {
    return {
      'subject-1': [
        StaffQuiz(
          id: 'quiz-1',
          subjectId: 'subject-1',
          title: 'State Management Design Checkpoint',
          description:
              'Short graded quiz covering async flows and clean architecture boundaries.',
          startsAt: now.add(const Duration(days: 1, hours: 2)),
          endsAt: now.add(const Duration(days: 1, hours: 2, minutes: 35)),
          durationMinutes: 35,
          status: StaffQuizStatus.draft,
          isGraded: true,
          isPractice: false,
          createdBy: 'Dr. Omar Nabil',
          questions: [
            StaffQuizQuestion(
              id: 'q1',
              type: StaffQuestionType.multipleChoice,
              title: 'Which layer should own DTO to domain mapping?',
              points: 5,
              isRequired: true,
              choices: const [
                StaffQuizChoice(id: 'a', label: 'Presentation layer'),
                StaffQuizChoice(id: 'b', label: 'Data layer', isCorrect: true),
                StaffQuizChoice(id: 'c', label: 'Widget tree'),
              ],
            ),
            StaffQuizQuestion(
              id: 'q2',
              type: StaffQuestionType.trueFalse,
              title: 'A repository should call UI code directly.',
              points: 3,
              isRequired: true,
              choices: const [
                StaffQuizChoice(id: 'true', label: 'True'),
                StaffQuizChoice(id: 'false', label: 'False', isCorrect: true),
              ],
            ),
          ],
        ),
      ],
      'subject-2': [
        StaffQuiz(
          id: 'quiz-2',
          subjectId: 'subject-2',
          title: 'Cloud Security Pulse Quiz',
          description:
              'Practice quiz for IAM, policies, and workload isolation.',
          startsAt: now.add(const Duration(hours: 6)),
          endsAt: now.add(const Duration(hours: 6, minutes: 25)),
          durationMinutes: 25,
          status: StaffQuizStatus.published,
          isGraded: false,
          isPractice: true,
          createdBy: 'Eng. Nora Sameh',
          questions: [
            StaffQuizQuestion(
              id: 'q3',
              type: StaffQuestionType.checkbox,
              title: 'Select all examples of identity controls.',
              points: 6,
              isRequired: true,
              choices: const [
                StaffQuizChoice(id: 'a', label: 'RBAC', isCorrect: true),
                StaffQuizChoice(
                  id: 'b',
                  label: 'IAM policies',
                  isCorrect: true,
                ),
                StaffQuizChoice(id: 'c', label: 'CPU scaling'),
              ],
            ),
          ],
        ),
      ],
    };
  }

  static Map<String, List<StaffAnnouncement>> _buildAnnouncements(
    DateTime now,
  ) {
    return {
      'subject-1': [
        StaffAnnouncement(
          id: 'announcement-1',
          subjectId: 'subject-1',
          title: 'Project milestone briefing',
          content:
              'Please review the project evaluation rubric before next week lecture.',
          priority: StaffAnnouncementPriority.important,
          isPublished: true,
          createdAt: now.subtract(const Duration(hours: 4)),
          authorName: 'Dr. Omar Nabil',
          attachmentLabel: 'rubric.pdf',
        ),
      ],
      'subject-2': [
        StaffAnnouncement(
          id: 'announcement-2',
          subjectId: 'subject-2',
          title: 'Urgent lab reminder',
          content: 'Tomorrow section starts in Lab 2 instead of Lab 4.',
          priority: StaffAnnouncementPriority.urgent,
          isPublished: true,
          createdAt: now.subtract(const Duration(hours: 1)),
          authorName: 'Eng. Nora Sameh',
        ),
      ],
    };
  }

  static Map<String, List<StaffGroupPost>> _buildPosts(DateTime now) {
    return {
      'subject-1': [
        StaffGroupPost(
          id: 'post-1',
          subjectId: 'subject-1',
          authorName: 'Dr. Omar Nabil',
          authorRole: 'Doctor',
          content:
              'Share your blocker for the architecture assignment so we can address it in the next session.',
          createdAt: now.subtract(const Duration(hours: 6)),
          visibilityLabel: 'Course group',
          reactionsCount: 18,
          comments: [
            StaffGroupComment(
              id: 'comment-1',
              authorName: 'Mariam Hassan',
              authorRole: 'Student',
              content: 'Can we submit the sequence diagram separately?',
              createdAt: now.subtract(const Duration(hours: 5, minutes: 20)),
            ),
          ],
        ),
      ],
      'subject-2': [
        StaffGroupPost(
          id: 'post-2',
          subjectId: 'subject-2',
          authorName: 'Eng. Nora Sameh',
          authorRole: 'Assistant',
          content:
              'A quick note set about IAM and zero-trust is now attached for revision.',
          createdAt: now.subtract(const Duration(hours: 3)),
          visibilityLabel: 'Course group',
          reactionsCount: 11,
          comments: const [],
          attachmentLabel: 'iam-notes.pdf',
        ),
      ],
    };
  }

  static Map<String, List<StaffSessionLink>> _buildLectures(DateTime now) {
    return {
      'subject-1': [
        StaffSessionLink(
          id: 'lecture-1',
          subjectId: 'subject-1',
          kind: StaffSessionKind.lecture,
          title: 'Clean Architecture Studio',
          description: 'Live design review for the mobile project structure.',
          mode: StaffSessionMode.online,
          startsAt: now.add(const Duration(hours: 3)),
          endsAt: now.add(const Duration(hours: 4, minutes: 30)),
          createdBy: 'Dr. Omar Nabil',
          meetingLink: 'https://meet.tolab.edu/mobile-architecture',
          locationLabel: 'Tolab Meet',
        ),
      ],
      'subject-2': [
        StaffSessionLink(
          id: 'lecture-2',
          subjectId: 'subject-2',
          kind: StaffSessionKind.lecture,
          title: 'Cloud Cost Optimization',
          description:
              'Lecture with optimization scenarios and practical trade-offs.',
          mode: StaffSessionMode.offline,
          startsAt: now.add(const Duration(days: 1, hours: 1)),
          endsAt: now.add(const Duration(days: 1, hours: 2, minutes: 30)),
          createdBy: 'Dr. Heba Mostafa',
          locationLabel: 'Hall B201',
        ),
      ],
    };
  }

  static Map<String, List<StaffSessionLink>> _buildSections(DateTime now) {
    return {
      'subject-1': [
        StaffSessionLink(
          id: 'section-1',
          subjectId: 'subject-1',
          kind: StaffSessionKind.section,
          title: 'Performance Profiling Lab',
          description: 'Hands-on performance instrumentation and profiling.',
          mode: StaffSessionMode.offline,
          startsAt: now.add(const Duration(days: 1, hours: 4)),
          endsAt: now.add(const Duration(days: 1, hours: 6)),
          createdBy: 'Eng. Nora Sameh',
          locationLabel: 'Lab 3',
        ),
      ],
      'subject-2': [
        StaffSessionLink(
          id: 'section-2',
          subjectId: 'subject-2',
          kind: StaffSessionKind.section,
          title: 'Kubernetes Incident Walkthrough',
          description: 'Assistant-led scenario session for logs and policies.',
          mode: StaffSessionMode.online,
          startsAt: now.add(const Duration(days: 2, hours: 2)),
          endsAt: now.add(const Duration(days: 2, hours: 3, minutes: 30)),
          createdBy: 'Eng. Nora Sameh',
          meetingLink: 'https://meet.tolab.edu/cloud-lab',
          locationLabel: 'Tolab Meet',
        ),
      ],
    };
  }

  static Map<String, List<StaffScheduleEvent>> _buildSchedule(DateTime now) {
    return {
      'subject-1': [
        StaffScheduleEvent(
          id: 'event-1',
          subjectId: 'subject-1',
          type: StaffScheduleEventType.lecture,
          title: 'Lecture: Clean Architecture Studio',
          description: 'Weekly lecture delivery window.',
          startsAt: now.add(const Duration(hours: 3)),
          endsAt: now.add(const Duration(hours: 4, minutes: 30)),
          colorHex: '#4E7CF5',
          linkedLabel: 'Lecture link attached',
        ),
        StaffScheduleEvent(
          id: 'event-2',
          subjectId: 'subject-1',
          type: StaffScheduleEventType.deadline,
          title: 'Architecture checkpoint deadline',
          description: 'Project package submission closes.',
          startsAt: now.add(const Duration(days: 2, hours: 6)),
          endsAt: now.add(const Duration(days: 2, hours: 6, minutes: 30)),
          colorHex: '#F1B95D',
        ),
      ],
      'subject-2': [
        StaffScheduleEvent(
          id: 'event-3',
          subjectId: 'subject-2',
          type: StaffScheduleEventType.quiz,
          title: 'Cloud Security Pulse Quiz',
          description: 'Practice quiz availability window.',
          startsAt: now.add(const Duration(hours: 6)),
          endsAt: now.add(const Duration(hours: 6, minutes: 25)),
          colorHex: '#3DB6B0',
        ),
        StaffScheduleEvent(
          id: 'event-4',
          subjectId: 'subject-2',
          type: StaffScheduleEventType.section,
          title: 'Lab switch reminder',
          description: 'Section will be hosted from Lab 2.',
          startsAt: now.add(const Duration(days: 1, hours: 5)),
          endsAt: now.add(const Duration(days: 1, hours: 6)),
          colorHex: '#E17878',
        ),
      ],
    };
  }

  static Map<String, List<CourseStudentInsight>> _buildStudents() {
    return {
      'subject-1': const [
        CourseStudentInsight(
          id: 'student-1',
          name: 'Mariam Hassan',
          code: '20241182',
          email: 'mariam.hassan@tolab.edu',
          activitySummary:
              'Strong class participation and frequent group engagement.',
          quizCompletion: 92,
          submissionsCount: 5,
          lastActiveLabel: '22 min ago',
          engagementLevel: EngagementLevel.high,
          completedQuizzes: 3,
          totalQuizzes: 3,
          submittedSheets: 5,
          totalSheets: 5,
          averageScore: 91,
        ),
        CourseStudentInsight(
          id: 'student-2',
          name: 'Aly Samir',
          code: '20241003',
          email: 'aly.samir@tolab.edu',
          activitySummary: 'Needs one nudge on pending sheet submissions.',
          quizCompletion: 74,
          submissionsCount: 3,
          lastActiveLabel: '3 h ago',
          engagementLevel: EngagementLevel.medium,
          completedQuizzes: 2,
          totalQuizzes: 3,
          submittedSheets: 3,
          totalSheets: 5,
          averageScore: 78,
        ),
        CourseStudentInsight(
          id: 'student-3',
          name: 'Sara Tarek',
          code: '20241244',
          email: 'sara.tarek@tolab.edu',
          activitySummary:
              'Low attendance this week and missing submission follow-up.',
          quizCompletion: 48,
          submissionsCount: 2,
          lastActiveLabel: 'Yesterday',
          engagementLevel: EngagementLevel.low,
          completedQuizzes: 1,
          totalQuizzes: 3,
          submittedSheets: 2,
          totalSheets: 5,
          averageScore: 63,
        ),
      ],
      'subject-2': const [
        CourseStudentInsight(
          id: 'student-4',
          name: 'Mena Tarek',
          code: '20241321',
          email: 'mena.tarek@tolab.edu',
          activitySummary: 'Solid engagement and good attendance trend.',
          quizCompletion: 88,
          submissionsCount: 4,
          lastActiveLabel: '15 min ago',
          engagementLevel: EngagementLevel.high,
          completedQuizzes: 2,
          totalQuizzes: 2,
          submittedSheets: 4,
          totalSheets: 4,
          averageScore: 86,
        ),
        CourseStudentInsight(
          id: 'student-5',
          name: 'Youssef Adel',
          code: '20241774',
          email: 'youssef.adel@tolab.edu',
          activitySummary:
              'Good quiz completion but still missing one lab sheet.',
          quizCompletion: 81,
          submissionsCount: 3,
          lastActiveLabel: '1 h ago',
          engagementLevel: EngagementLevel.medium,
          completedQuizzes: 2,
          totalQuizzes: 2,
          submittedSheets: 3,
          totalSheets: 4,
          averageScore: 79,
        ),
        CourseStudentInsight(
          id: 'student-6',
          name: 'Salma Fawzy',
          code: '20241801',
          email: 'salma.fawzy@tolab.edu',
          activitySummary:
              'Participation dropped after the last section change.',
          quizCompletion: 54,
          submissionsCount: 2,
          lastActiveLabel: '2 days ago',
          engagementLevel: EngagementLevel.low,
          completedQuizzes: 1,
          totalQuizzes: 2,
          submittedSheets: 2,
          totalSheets: 4,
          averageScore: 67,
        ),
      ],
    };
  }

  static List<AppNotificationItem> _buildNotifications(DateTime now) {
    return [
      AppNotificationItem(
        id: 'notification-1',
        title: 'Draft quiz still not published',
        body: 'State Management Design Checkpoint is still in draft state.',
        createdAt: now.subtract(const Duration(minutes: 24)),
        createdAtLabel: '24 min ago',
        category: 'Quizzes',
        isRead: false,
        routeName: RouteNames.subjectDetails,
        pathParameters: const {'subjectId': 'subject-1'},
        isImportant: true,
      ),
      AppNotificationItem(
        id: 'notification-2',
        title: 'Urgent section update delivered',
        body: 'Lab location reminder was published to Cloud Computing.',
        createdAt: now.subtract(const Duration(hours: 1)),
        createdAtLabel: '1 h ago',
        category: 'Announcements',
        isRead: false,
        routeName: RouteNames.subjectDetails,
        pathParameters: const {'subjectId': 'subject-2'},
        isImportant: true,
      ),
      AppNotificationItem(
        id: 'notification-3',
        title: 'Student attention risk raised',
        body: 'Sara Tarek has low engagement and two pending sheets.',
        createdAt: now.subtract(const Duration(hours: 5)),
        createdAtLabel: '5 h ago',
        category: 'Students',
        isRead: true,
        routeName: RouteNames.subjectDetails,
        pathParameters: const {'subjectId': 'subject-1'},
      ),
    ];
  }
}

List<T> _upsertById<T>(
  List<T> items,
  T next,
  String Function(T item) idSelector,
) {
  final index = items.indexWhere(
    (item) => idSelector(item) == idSelector(next),
  );
  if (index < 0) {
    return [next, ...items];
  }

  final updated = [...items];
  updated[index] = next;
  return updated;
}
