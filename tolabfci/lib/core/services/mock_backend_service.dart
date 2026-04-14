import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../errors/app_exception.dart';
import '../models/community_models.dart';
import '../models/home_dashboard.dart';
import '../models/notification_item.dart';
import '../models/quiz_models.dart';
import '../models/result_item.dart';
import '../models/student_profile.dart';
import '../models/subject_models.dart';
import '../utils/formatters.dart';

final mockBackendServiceProvider = Provider<MockBackendService>((ref) {
  return MockBackendService();
});

class MockBackendService {
  MockBackendService() {
    _notifications = _buildNotifications(DateTime.now());
    _notificationsController.add(_notifications);
  }

  final _notificationsController =
      StreamController<List<AppNotificationItem>>.broadcast();

  final StudentProfile _profile = const StudentProfile(
    id: 'student-1',
    fullName: 'Mariam Hassan',
    email: 'mariam.hassan@tolab.edu',
    avatarUrl: '',
    nationalId: '29801011234567',
    faculty: 'Faculty of Computer and Information',
    department: 'Computer Science',
    level: 'Level 4',
    academicAdvisor: 'Dr. Salma Adel',
    gpa: 3.72,
    seatNumber: 'FCI-24-1182',
    previousQualification: 'STEM High School',
  );

  final List<SubjectOverview> _subjects = const [
    SubjectOverview(
      id: 'subject-1',
      name: 'Advanced Mobile Systems',
      code: 'CS401',
      instructor: 'Dr. Omar Nabil',
      creditHours: 3,
      accentHex: '#4E7CF5',
      description:
          'Architecture, performance, and production delivery for mobile apps.',
    ),
    SubjectOverview(
      id: 'subject-2',
      name: 'Cloud Computing',
      code: 'CS409',
      instructor: 'Dr. Heba Mostafa',
      creditHours: 3,
      accentHex: '#3DB6B0',
      description:
          'Distributed systems fundamentals with cloud deployment practices.',
    ),
    SubjectOverview(
      id: 'subject-3',
      name: 'Human Computer Interaction',
      code: 'IS330',
      instructor: 'Dr. Nourhan Fawzy',
      creditHours: 2,
      accentHex: '#6D73F8',
      description:
          'Interaction design, usability, and interface evaluation methods.',
    ),
  ];

  final List<SectionItem> _sections = const [
    SectionItem(
      id: 'section-1',
      subjectId: 'subject-1',
      title: 'Architecture studio',
      location: 'Lab 3',
      scheduleLabel: 'Sun, 1:00 PM',
    ),
    SectionItem(
      id: 'section-2',
      subjectId: 'subject-2',
      title: 'Kubernetes workshop',
      location: 'Online',
      scheduleLabel: 'Mon, 12:00 PM',
    ),
    SectionItem(
      id: 'section-3',
      subjectId: 'subject-3',
      title: 'Research discussion',
      location: 'Room B201',
      scheduleLabel: 'Wed, 10:30 AM',
    ),
  ];

  List<SummaryItem> _summaries = const [
    SummaryItem(
      id: 'summary-1',
      subjectId: 'subject-1',
      authorName: 'Mariam Hassan',
      title: 'Riverpod state boundaries',
      createdAtLabel: 'Today',
      videoUrl: 'https://video.tolab.edu/riverpod',
      attachmentName: 'riverpod-notes.pdf',
    ),
    SummaryItem(
      id: 'summary-2',
      subjectId: 'subject-2',
      authorName: 'Ali Samir',
      title: 'Cloud architecture glossary',
      createdAtLabel: 'Yesterday',
      attachmentName: 'cloud-glossary.png',
    ),
  ];

  List<CommunityPost> _posts = const [
    CommunityPost(
      id: 'post-1',
      subjectId: 'subject-1',
      authorName: 'Dr. Omar Nabil',
      authorRole: 'Instructor',
      content:
          'Please review the clean architecture walkthrough before the next live session.',
      createdAtLabel: '2h ago',
      reactions: 18,
      comments: [
        CommunityComment(
          id: 'comment-1',
          authorName: 'Mariam Hassan',
          content: 'Will the case study be discussed in class too?',
          createdAtLabel: '1h ago',
        ),
      ],
    ),
    CommunityPost(
      id: 'post-2',
      subjectId: 'subject-2',
      authorName: 'Mona Tarek',
      authorRole: 'Student',
      content:
          'I shared a short note set for container scheduling and autoscaling.',
      createdAtLabel: 'Yesterday',
      reactions: 11,
      comments: [],
    ),
  ];

  List<ChatMessage> _chatMessages = const [
    ChatMessage(
      id: 'chat-1',
      subjectId: 'subject-1',
      authorName: 'Nour',
      content: 'Did anyone finish the repository abstraction task?',
      sentAtLabel: '10:18 AM',
      isMine: false,
    ),
    ChatMessage(
      id: 'chat-2',
      subjectId: 'subject-1',
      authorName: 'Mariam Hassan',
      content: 'Yes, I can share my notes after the lecture.',
      sentAtLabel: '10:20 AM',
      isMine: true,
    ),
    ChatMessage(
      id: 'chat-3',
      subjectId: 'subject-2',
      authorName: 'Karim',
      content: 'Reminder: security quiz is offline this week.',
      sentAtLabel: '8:42 AM',
      isMine: false,
    ),
  ];

  late List<AppNotificationItem> _notifications;

  final List<SubjectResult> _results = const [
    SubjectResult(
      subjectId: 'subject-1',
      subjectName: 'Advanced Mobile Systems',
      totalGrade: 91,
      letterGrade: 'A',
      status: 'Passed',
    ),
    SubjectResult(
      subjectId: 'subject-2',
      subjectName: 'Cloud Computing',
      totalGrade: 88,
      letterGrade: 'B+',
      status: 'Passed',
    ),
    SubjectResult(
      subjectId: 'subject-3',
      subjectName: 'Human Computer Interaction',
      totalGrade: 94,
      letterGrade: 'A',
      status: 'Passed',
    ),
  ];

  Future<String> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (email.trim().toLowerCase() == _profile.email &&
        password == 'student123') {
      return 'mock-access-token';
    }
    throw const AppException(
      'Invalid email or password. Please use the assigned student account.',
      code: 'invalid_credentials',
    );
  }

  Future<void> verifyNationalId(String nationalId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (nationalId.trim() != _profile.nationalId) {
      throw const AppException(
        'National ID verification failed. Please review your number and try again.',
        code: 'invalid_national_id',
      );
    }
  }

  Future<StudentProfile> fetchProfile() async => _profile;

  Future<List<SubjectOverview>> fetchSubjects() async => _subjects;

  Future<SubjectOverview> fetchSubjectById(String subjectId) async {
    return _subjects.firstWhere((subject) => subject.id == subjectId);
  }

  Future<List<LectureItem>> fetchLectures({String? subjectId}) async {
    final lectures = _buildLectures(DateTime.now());
    return lectures
        .where((item) => subjectId == null || item.subjectId == subjectId)
        .toList();
  }

  Future<List<SectionItem>> fetchSections(String subjectId) async {
    return _sections.where((item) => item.subjectId == subjectId).toList();
  }

  Future<List<TaskItem>> fetchTasks(String subjectId) async {
    return _buildTasks(
      DateTime.now(),
    ).where((item) => item.subjectId == subjectId).toList();
  }

  Future<List<SummaryItem>> fetchSummaries(String subjectId) async {
    return _summaries.where((item) => item.subjectId == subjectId).toList();
  }

  Future<void> addSummary({
    required String subjectId,
    required String title,
    String? videoUrl,
    String? attachmentName,
  }) async {
    _summaries = [
      SummaryItem(
        id: 'summary-${_summaries.length + 1}',
        subjectId: subjectId,
        authorName: _profile.fullName,
        title: title,
        createdAtLabel: formatNow('MMM d'),
        videoUrl: videoUrl,
        attachmentName: attachmentName,
      ),
      ..._summaries,
    ];
  }

  Future<List<QuizItem>> fetchQuizzes({String? subjectId}) async {
    final quizzes = _buildQuizzes(DateTime.now());
    return quizzes
        .where((item) => subjectId == null || item.subjectId == subjectId)
        .toList();
  }

  Future<HomeDashboardData> fetchHomeDashboard() async {
    final now = DateTime.now();
    final lectures = _buildLectures(now);
    final quizzes = _buildQuizzes(now);
    final tasks = _buildTasks(now);

    return HomeDashboardData(
      profile: _profile,
      notifications: _notifications,
      subjects: _subjects,
      upcomingLectures: lectures,
      upcomingQuizzes: quizzes,
      tasks: tasks,
      courseActivities: _buildCourseActivities(now),
      studyInsights: _buildStudyInsights(tasks),
    );
  }

  Future<List<CommunityPost>> fetchCommunityPosts(String subjectId) async {
    return _posts.where((post) => post.subjectId == subjectId).toList();
  }

  Future<void> addComment({
    required String subjectId,
    required String postId,
    required String content,
  }) async {
    _posts = _posts.map((post) {
      if (post.id != postId || post.subjectId != subjectId) {
        return post;
      }
      return post.copyWith(
        comments: [
          ...post.comments,
          CommunityComment(
            id: 'comment-${post.comments.length + 1}',
            authorName: _profile.fullName,
            content: content,
            createdAtLabel: 'Just now',
          ),
        ],
      );
    }).toList();
  }

  Future<void> reactToPost({
    required String subjectId,
    required String postId,
  }) async {
    _posts = _posts.map((post) {
      if (post.id != postId || post.subjectId != subjectId) {
        return post;
      }
      return post.copyWith(reactions: post.reactions + 1);
    }).toList();
  }

  Future<List<ChatMessage>> fetchChatMessages(
    String subjectId, {
    int page = 0,
    int pageSize = 15,
  }) async {
    final scoped = _chatMessages
        .where((message) => message.subjectId == subjectId)
        .toList();
    final end = scoped.length - (page * pageSize);
    if (end <= 0) {
      return [];
    }
    final start = (end - pageSize).clamp(0, end);
    return scoped.sublist(start, end);
  }

  Future<void> sendChatMessage({
    required String subjectId,
    required String content,
  }) async {
    _chatMessages = [
      ..._chatMessages,
      ChatMessage(
        id: 'chat-${_chatMessages.length + 1}',
        subjectId: subjectId,
        authorName: _profile.fullName,
        content: content,
        sentAtLabel: formatNow('h:mm a'),
        isMine: true,
      ),
    ];
  }

  Stream<List<AppNotificationItem>> watchNotifications() =>
      _notificationsController.stream;

  Future<List<AppNotificationItem>> fetchNotifications() async =>
      _notifications;

  Future<void> markNotificationAsRead(String notificationId) async {
    _notifications = _notifications
        .map(
          (notification) => notification.id == notificationId
              ? notification.copyWith(isRead: true)
              : notification,
        )
        .toList();
    _notificationsController.add(_notifications);
  }

  Future<List<SubjectResult>> fetchResults() async => _results;

  List<LectureItem> _buildLectures(DateTime now) {
    final firstLectureStart = now.add(const Duration(hours: 1, minutes: 15));
    final secondLectureStart = now.add(const Duration(days: 1, hours: 3));
    final thirdLectureStart = now.add(const Duration(days: 3, hours: 2));

    return [
      LectureItem(
        id: 'lecture-1',
        subjectId: 'subject-1',
        subjectName: 'Advanced Mobile Systems',
        title: 'State orchestration studio',
        scheduleLabel: _formatSchedule(firstLectureStart),
        startsAt: firstLectureStart,
        endsAt: firstLectureStart.add(const Duration(hours: 1, minutes: 30)),
        meetingUrl: 'https://meet.tolab.edu/mobile',
        isOnline: true,
        locationLabel: 'Live on Tolab Meet',
      ),
      LectureItem(
        id: 'lecture-2',
        subjectId: 'subject-2',
        subjectName: 'Cloud Computing',
        title: 'Container scheduling review',
        scheduleLabel: _formatSchedule(secondLectureStart),
        startsAt: secondLectureStart,
        endsAt: secondLectureStart.add(const Duration(hours: 1)),
        meetingUrl: 'https://meet.tolab.edu/cloud',
        isOnline: true,
        locationLabel: 'Live on Tolab Meet',
      ),
      LectureItem(
        id: 'lecture-3',
        subjectId: 'subject-3',
        subjectName: 'Human Computer Interaction',
        title: 'Accessibility critique lab',
        scheduleLabel: _formatSchedule(thirdLectureStart),
        startsAt: thirdLectureStart,
        endsAt: thirdLectureStart.add(const Duration(hours: 2)),
        meetingUrl: '',
        isOnline: false,
        locationLabel: 'Room B201',
      ),
    ];
  }

  List<TaskItem> _buildTasks(DateTime now) {
    final urgentDeadline = now.add(const Duration(hours: 6));
    final tomorrowDeadline = now.add(const Duration(days: 1, hours: 5));
    final laterDeadline = now.add(const Duration(days: 3, hours: 2));

    return [
      TaskItem(
        id: 'task-1',
        subjectId: 'subject-2',
        subjectName: 'Cloud Computing',
        title: 'Submit service mesh lab',
        dueDateLabel: _formatDueLabel(urgentDeadline, now),
        dueAt: urgentDeadline,
        status: 'Missing submission',
        isMissingSubmission: true,
      ),
      TaskItem(
        id: 'task-2',
        subjectId: 'subject-1',
        subjectName: 'Advanced Mobile Systems',
        title: 'Architecture review memo',
        dueDateLabel: _formatDueLabel(tomorrowDeadline, now),
        dueAt: tomorrowDeadline,
        status: 'Pending',
      ),
      TaskItem(
        id: 'task-3',
        subjectId: 'subject-3',
        subjectName: 'Human Computer Interaction',
        title: 'Heuristic evaluation report',
        dueDateLabel: _formatDueLabel(laterDeadline, now),
        dueAt: laterDeadline,
        status: 'In progress',
      ),
      TaskItem(
        id: 'task-4',
        subjectId: 'subject-1',
        subjectName: 'Advanced Mobile Systems',
        title: 'Weekly architecture checkpoint',
        dueDateLabel: 'Submitted',
        dueAt: now.subtract(const Duration(days: 1, hours: 2)),
        status: 'Completed',
        isCompleted: true,
      ),
    ];
  }

  List<QuizItem> _buildQuizzes(DateTime now) {
    final openQuizStart = now.subtract(const Duration(minutes: 25));
    final openQuizClose = now.add(const Duration(minutes: 50));
    final upcomingQuizStart = now.add(const Duration(days: 1, hours: 4));

    return [
      QuizItem(
        id: 'quiz-1',
        subjectId: 'subject-1',
        subjectName: 'Advanced Mobile Systems',
        title: 'Async flows checkpoint',
        typeLabel: 'Online quiz',
        startAtLabel: _formatSchedule(openQuizStart),
        startsAt: openQuizStart,
        closesAt: openQuizClose,
        durationLabel: '20 min',
        isOnline: true,
        instructions: const [
          'Use a stable connection before starting.',
          'Submit before the timer expires.',
          'Keep the quiz screen active throughout the attempt.',
        ],
      ),
      QuizItem(
        id: 'quiz-2',
        subjectId: 'subject-2',
        subjectName: 'Cloud Computing',
        title: 'Cloud security readiness',
        typeLabel: 'Offline quiz',
        startAtLabel: _formatSchedule(upcomingQuizStart),
        startsAt: upcomingQuizStart,
        closesAt: upcomingQuizStart.add(const Duration(minutes: 45)),
        durationLabel: '45 min',
        isOnline: false,
        instructions: const [
          'Bring your university ID card.',
          'Arrive 15 minutes early.',
        ],
      ),
    ];
  }

  List<CourseActivityItem> _buildCourseActivities(DateTime now) {
    return [
      CourseActivityItem(
        id: 'activity-1',
        subjectId: 'subject-1',
        subjectName: 'Advanced Mobile Systems',
        title: 'New lecture uploaded',
        description:
            'System design recap slides and recording are ready to review.',
        type: CourseActivityType.lecture,
        createdAtLabel: _formatRelativeTimestamp(
          now.subtract(const Duration(minutes: 35)),
          now,
        ),
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
      CourseActivityItem(
        id: 'activity-2',
        subjectId: 'subject-2',
        subjectName: 'Cloud Computing',
        title: 'New task assigned',
        description:
            'Complete the service mesh deployment worksheet before tomorrow night.',
        type: CourseActivityType.task,
        createdAtLabel: _formatRelativeTimestamp(
          now.subtract(const Duration(hours: 2, minutes: 15)),
          now,
        ),
        createdAt: now.subtract(const Duration(hours: 2, minutes: 15)),
      ),
      CourseActivityItem(
        id: 'activity-3',
        subjectId: 'subject-3',
        subjectName: 'Human Computer Interaction',
        title: 'New announcement',
        description:
            'Lab seating was updated for the accessibility critique session.',
        type: CourseActivityType.announcement,
        createdAtLabel: _formatRelativeTimestamp(
          now.subtract(const Duration(days: 1, hours: 1)),
          now,
        ),
        createdAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
    ];
  }

  StudyInsightsData _buildStudyInsights(List<TaskItem> tasks) {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;

    return StudyInsightsData(
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      viewedLectures: 8,
      engagementScore: 0.82,
      engagementLabel: 'Strong engagement',
    );
  }

  List<AppNotificationItem> _buildNotifications(DateTime now) {
    return [
      AppNotificationItem(
        id: 'notification-1',
        title: 'Quiz is live now',
        body: 'Async flows checkpoint is open for the next 50 minutes.',
        createdAtLabel: _formatRelativeTimestamp(
          now.subtract(const Duration(minutes: 10)),
          now,
        ),
        category: 'Quiz',
        isRead: false,
      ),
      AppNotificationItem(
        id: 'notification-2',
        title: 'Lecture starts soon',
        body: 'State orchestration studio begins in a little over an hour.',
        createdAtLabel: _formatRelativeTimestamp(
          now.subtract(const Duration(hours: 1)),
          now,
        ),
        category: 'Lecture',
        isRead: false,
      ),
      AppNotificationItem(
        id: 'notification-3',
        title: 'Deadline moved to top priority',
        body: 'Submit service mesh lab before the portal closes tonight.',
        createdAtLabel: _formatRelativeTimestamp(
          now.subtract(const Duration(days: 1)),
          now,
        ),
        category: 'Task',
        isRead: true,
      ),
    ];
  }

  String _formatSchedule(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final differenceInDays = target.difference(today).inDays;

    final prefix = switch (differenceInDays) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => DateFormat('EEE, MMM d').format(dateTime),
    };

    return '$prefix, ${DateFormat('h:mm a').format(dateTime)}';
  }

  String _formatDueLabel(DateTime dueAt, DateTime now) {
    final hours = dueAt.difference(now).inHours;
    if (hours < 24) {
      return 'Due in ${hours.clamp(1, 23)}h';
    }

    final days = dueAt.difference(now).inDays;
    if (days == 1) {
      return 'Due tomorrow';
    }

    return 'Due in $days days';
  }

  String _formatRelativeTimestamp(DateTime dateTime, DateTime now) {
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes.clamp(1, 59)} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays == 1) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(dateTime);
  }
}
