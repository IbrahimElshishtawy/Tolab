import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    _notificationsController.add(_notifications);
  }

  final _notificationsController = StreamController<List<AppNotificationItem>>.broadcast();

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
      description: 'Architecture, performance, and production delivery for mobile apps.',
    ),
    SubjectOverview(
      id: 'subject-2',
      name: 'Cloud Computing',
      code: 'CS409',
      instructor: 'Dr. Heba Mostafa',
      creditHours: 3,
      accentHex: '#3DB6B0',
      description: 'Distributed systems fundamentals with cloud deployment practices.',
    ),
    SubjectOverview(
      id: 'subject-3',
      name: 'Human Computer Interaction',
      code: 'IS330',
      instructor: 'Dr. Nourhan Fawzy',
      creditHours: 2,
      accentHex: '#6D73F8',
      description: 'Interaction design, usability, and interface evaluation methods.',
    ),
  ];

  final List<LectureItem> _lectures = const [
    LectureItem(
      id: 'lecture-1',
      subjectId: 'subject-1',
      title: 'State orchestration patterns',
      scheduleLabel: 'Today, 11:30 AM',
      meetingUrl: 'https://meet.tolab.edu/mobile',
      isOnline: true,
    ),
    LectureItem(
      id: 'lecture-2',
      subjectId: 'subject-2',
      title: 'Container scheduling',
      scheduleLabel: 'Tomorrow, 9:00 AM',
      meetingUrl: 'https://meet.tolab.edu/cloud',
      isOnline: true,
    ),
    LectureItem(
      id: 'lecture-3',
      subjectId: 'subject-3',
      title: 'Accessibility review lab',
      scheduleLabel: 'Tue, 1:00 PM',
      meetingUrl: '',
      isOnline: false,
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

  final List<TaskItem> _tasks = const [
    TaskItem(
      id: 'task-1',
      subjectId: 'subject-1',
      title: 'Submit architecture review',
      dueDateLabel: 'Due in 2 days',
      status: 'Pending',
    ),
    TaskItem(
      id: 'task-2',
      subjectId: 'subject-2',
      title: 'Deploy service mesh lab',
      dueDateLabel: 'Due this week',
      status: 'In progress',
    ),
    TaskItem(
      id: 'task-3',
      subjectId: 'subject-3',
      title: 'Heuristic evaluation report',
      dueDateLabel: 'Submitted',
      status: 'Completed',
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

  final List<QuizItem> _quizzes = const [
    QuizItem(
      id: 'quiz-1',
      subjectId: 'subject-1',
      title: 'Async flows quiz',
      typeLabel: 'Online quiz',
      startAtLabel: 'Today, 6:00 PM',
      durationLabel: '20 min',
      isOnline: true,
      instructions: [
        'Use a stable connection before starting.',
        'Submit before the timer expires.',
        'Keep the quiz screen active throughout the attempt.',
      ],
    ),
    QuizItem(
      id: 'quiz-2',
      subjectId: 'subject-2',
      title: 'Cloud security check',
      typeLabel: 'Offline quiz',
      startAtLabel: 'Thu, 10:00 AM',
      durationLabel: '30 min',
      isOnline: false,
      instructions: [
        'Bring your university ID card.',
        'Arrive 15 minutes early.',
      ],
    ),
  ];

  List<CommunityPost> _posts = const [
    CommunityPost(
      id: 'post-1',
      subjectId: 'subject-1',
      authorName: 'Dr. Omar Nabil',
      authorRole: 'Instructor',
      content: 'Please review the clean architecture walkthrough before the next live session.',
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
      content: 'I shared a short note set for container scheduling and autoscaling.',
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

  List<AppNotificationItem> _notifications = const [
    AppNotificationItem(
      id: 'notification-1',
      title: 'Quiz opens tonight',
      body: 'Async flows quiz starts at 6:00 PM.',
      createdAtLabel: '10 min ago',
      category: 'Quiz',
      isRead: false,
    ),
    AppNotificationItem(
      id: 'notification-2',
      title: 'New summary added',
      body: 'Mona uploaded notes for Cloud Computing.',
      createdAtLabel: '1h ago',
      category: 'Summary',
      isRead: false,
    ),
    AppNotificationItem(
      id: 'notification-3',
      title: 'Section room updated',
      body: 'HCI research discussion moved to Room B201.',
      createdAtLabel: 'Yesterday',
      category: 'Section',
      isRead: true,
    ),
  ];

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
    if (email.trim().toLowerCase() == _profile.email && password == 'student123') {
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
    return _lectures.where((item) => subjectId == null || item.subjectId == subjectId).toList();
  }

  Future<List<SectionItem>> fetchSections(String subjectId) async {
    return _sections.where((item) => item.subjectId == subjectId).toList();
  }

  Future<List<TaskItem>> fetchTasks(String subjectId) async {
    return _tasks.where((item) => item.subjectId == subjectId).toList();
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
    return _quizzes.where((item) => subjectId == null || item.subjectId == subjectId).toList();
  }

  Future<HomeDashboardData> fetchHomeDashboard() async {
    return HomeDashboardData(
      profile: _profile,
      notifications: _notifications,
      upcomingLectures: _lectures.take(2).toList(),
      upcomingQuizzes: _quizzes.take(2).toList(),
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
    final scoped = _chatMessages.where((message) => message.subjectId == subjectId).toList();
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

  Stream<List<AppNotificationItem>> watchNotifications() => _notificationsController.stream;

  Future<List<AppNotificationItem>> fetchNotifications() async => _notifications;

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
}
