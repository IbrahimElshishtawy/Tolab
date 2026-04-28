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
import '../router/route_names.dart';
import '../session/app_session.dart';
import '../utils/formatters.dart';

final mockBackendServiceProvider = Provider<MockBackendService>((ref) {
  return MockBackendService();
});

class MockBackendService {
  MockBackendService() {
    final now = DateTime.now();
    _lectures = _buildLectures(now);
    _sections = _buildSections(now);
    _tasks = _buildTasks(now);
    _quizzes = _buildQuizzes(now);
    _subjectFiles = _buildSubjectFiles(now);
    _notifications = _buildNotifications(now);
    _notificationsController.add(_notifications);
  }

  final _notificationsController =
      StreamController<List<AppNotificationItem>>.broadcast();

  late final List<LectureItem> _lectures;
  late final List<SectionItem> _sections;
  late List<TaskItem> _tasks;
  late List<QuizItem> _quizzes;
  late final List<SubjectFileItem> _subjectFiles;
  late List<AppNotificationItem> _notifications;

  final StudentProfile _profile = const StudentProfile(
    id: 'student-1',
    fullName: 'مريم حسن',
    email: 'student@test.com',
    avatarUrl: '',
    studentNumber: '20241182',
    nationalId: '12345678901234',
    faculty: 'كلية الحاسبات والمعلومات',
    department: 'علوم الحاسب',
    level: 'الفرقة الرابعة',
    academicAdvisor: 'د. سلمى عادل',
    academicStatus: 'منتظم أكاديميًا',
    gpa: 3.72,
    completedHours: 102,
    registeredHours: 15,
    seatNumber: 'FCI-24-1182',
    previousQualification: 'STEM High School',
  );

  final AuthSessionData _studentSession = const AuthSessionData(
    token: 'mock-student-access-token',
    role: AppUserRole.student,
    email: 'student@test.com',
    nationalId: '12345678901234',
  );

  final AuthSessionData _doctorSession = const AuthSessionData(
    token: 'mock-doctor-access-token',
    role: AppUserRole.doctor,
    email: 'omar.nabil@tolab.edu',
    nationalId: '12345678901234',
  );

  final AuthSessionData _assistantSession = const AuthSessionData(
    token: 'mock-assistant-access-token',
    role: AppUserRole.assistant,
    email: 'nora.sameh@tolab.edu',
    nationalId: '12345678901234',
  );

  String nationalIdForRole(AppUserRole role) {
    return switch (role) {
      AppUserRole.student => _studentSession.nationalId,
      AppUserRole.doctor => _doctorSession.nationalId,
      AppUserRole.assistant => _assistantSession.nationalId,
    };
  }

  final List<SubjectOverview> _subjects = const [
    SubjectOverview(
      id: 'subject-1',
      name: 'تطوير تطبيقات الهاتف المتقدمة',
      code: 'CS401',
      instructor: 'د. عمر نبيل',
      assistantName: 'م. نورا سامح',
      creditHours: 3,
      accentHex: '#4E7CF5',
      description:
          'معمارية التطبيقات، الأداء، وبناء منتجات موبايل جاهزة للإطلاق.',
      lecturesCount: 12,
      sectionsCount: 8,
      quizCount: 3,
      sheetCount: 5,
      lastActivityLabel: 'تم رفع محاضرة جديدة منذ 35 دقيقة',
      progress: 0.74,
      status: 'نشطة',
    ),
    SubjectOverview(
      id: 'subject-2',
      name: 'الحوسبة السحابية',
      code: 'CS409',
      instructor: 'د. هبة مصطفى',
      assistantName: 'م. كريم راضي',
      creditHours: 3,
      accentHex: '#3DB6B0',
      description:
          'النظم الموزعة، النشر السحابي، وأمن الخدمات على البيئات الحديثة.',
      lecturesCount: 10,
      sectionsCount: 7,
      quizCount: 2,
      sheetCount: 4,
      lastActivityLabel: 'موعد تسليم قريب الليلة',
      progress: 0.48,
      status: 'مطلوب تسليم',
    ),
    SubjectOverview(
      id: 'subject-3',
      name: 'التفاعل بين الإنسان والحاسوب',
      code: 'IS330',
      instructor: 'د. نورهان فوزي',
      assistantName: 'م. منة طارق',
      creditHours: 2,
      accentHex: '#6D73F8',
      description: 'التصميم التفاعلي، سهولة الاستخدام، وتقييم واجهات المستخدم.',
      lecturesCount: 9,
      sectionsCount: 6,
      quizCount: 1,
      sheetCount: 3,
      lastActivityLabel: 'تم فتح ملخص جديد أمس',
      progress: 0.82,
      status: 'جديد',
    ),
    SubjectOverview(
      id: 'subject-4',
      name: 'الذكاء الاصطناعي',
      code: 'CS420',
      instructor: 'د. ياسر عادل',
      assistantName: 'م. سارة كمال',
      creditHours: 3,
      accentHex: '#9B6AFB',
      description: 'البحث، الاستدلال، التعلم الآلي، وتطبيقات النماذج الذكية.',
      lecturesCount: 11,
      sectionsCount: 7,
      quizCount: 2,
      sheetCount: 4,
      lastActivityLabel: 'تم نشر تدريب جديد على خوارزميات البحث',
      progress: 0.63,
      status: 'نشطة',
    ),
    SubjectOverview(
      id: 'subject-5',
      name: 'أمن المعلومات',
      code: 'CS415',
      instructor: 'د. أحمد فاروق',
      assistantName: 'م. ليلى هشام',
      creditHours: 3,
      accentHex: '#F07F5A',
      description: 'التشفير، أمن الشبكات، إدارة الهوية، ومراجعة المخاطر.',
      lecturesCount: 10,
      sectionsCount: 6,
      quizCount: 2,
      sheetCount: 3,
      lastActivityLabel: 'تنبيه هام بخصوص معمل التشفير',
      progress: 0.57,
      status: 'مطلوب تسليم',
    ),
  ];

  List<SummaryItem> _summaries = const [
    SummaryItem(
      id: 'summary-1',
      subjectId: 'subject-1',
      authorName: 'مريم حسن',
      title: 'ملخص حدود Riverpod في التطبيق',
      createdAtLabel: 'اليوم',
      videoUrl: 'https://video.tolab.edu/riverpod',
      attachmentName: 'riverpod-notes.pdf',
    ),
    SummaryItem(
      id: 'summary-2',
      subjectId: 'subject-2',
      authorName: 'علي سمير',
      title: 'قاموس مصطلحات البنية السحابية',
      createdAtLabel: 'أمس',
      attachmentName: 'cloud-glossary.png',
    ),
    SummaryItem(
      id: 'summary-3',
      subjectId: 'subject-4',
      authorName: 'ندى خالد',
      title: 'خريطة مراجعة Search Strategies',
      createdAtLabel: 'منذ يومين',
      videoUrl: 'https://video.tolab.edu/ai-search',
      attachmentName: 'ai-search-map.pdf',
    ),
    SummaryItem(
      id: 'summary-4',
      subjectId: 'subject-5',
      authorName: 'مريم حسن',
      title: 'ملخص أساسيات التشفير',
      createdAtLabel: 'هذا الأسبوع',
      attachmentName: 'crypto-basics.pdf',
    ),
  ];

  List<CommunityPost> _posts = const [
    CommunityPost(
      id: 'post-1',
      subjectId: 'subject-1',
      authorName: 'د. عمر نبيل',
      authorRole: 'الدكتور',
      content:
          'راجعوا تسجيل شرح clean architecture قبل محاضرة الأحد، وسيتم حل case study مباشرة في اللقاء.',
      createdAtLabel: 'منذ ساعتين',
      reactions: 18,
      type: CommunityPostType.announcement,
      isPinned: true,
      attachmentName: 'clean-architecture-case-study.pdf',
      comments: [
        CommunityComment(
          id: 'comment-1',
          authorName: 'مريم حسن',
          content: 'هل سيكون الجزء العملي من التسجيل داخل الكويز القادم؟',
          createdAtLabel: 'منذ ساعة',
        ),
      ],
    ),
    CommunityPost(
      id: 'post-2',
      subjectId: 'subject-2',
      authorName: 'م. كريم راضي',
      authorRole: 'المعيد',
      content:
          'تم رفع ملف ملاحظات سريع عن autoscaling والـ scheduling ضمن مرفقات المادة.',
      createdAtLabel: 'أمس',
      reactions: 11,
      type: CommunityPostType.announcement,
      attachmentName: 'autoscaling-notes.pdf',
      comments: [],
    ),
    CommunityPost(
      id: 'post-3',
      subjectId: 'subject-3',
      authorName: 'د. نورهان فوزي',
      authorRole: 'الدكتور',
      content:
          'تم تثبيت Rubric المشروع الصغير. الأولوية هذا الأسبوع لمراجعة القابلية والوصول عبر mobile.',
      createdAtLabel: 'منذ 5 ساعات',
      reactions: 26,
      type: CommunityPostType.announcement,
      isPinned: true,
      attachmentName: 'hci-mini-project-rubric.pdf',
      comments: [],
    ),
    CommunityPost(
      id: 'post-4',
      subjectId: 'subject-4',
      authorName: 'د. ياسر عادل',
      authorRole: 'الدكتور',
      content:
          'تدريب خوارزميات البحث متاح الآن، والمناقشة العملية ستكون على A* وMinimax في السكشن القادم.',
      createdAtLabel: 'منذ 40 دقيقة',
      reactions: 21,
      type: CommunityPostType.announcement,
      isPinned: true,
      isImportant: true,
      attachmentName: 'ai-search-practice.pdf',
      comments: [],
    ),
    CommunityPost(
      id: 'post-5',
      subjectId: 'subject-5',
      authorName: 'م. ليلى هشام',
      authorRole: 'المعيدة',
      content:
          'ملف معمل التشفير مرفق هنا. اقرأ التعليمات قبل الحضور لأن التسليم سيكون داخل المعمل.',
      createdAtLabel: 'اليوم',
      reactions: 17,
      type: CommunityPostType.announcement,
      isImportant: true,
      attachmentName: 'crypto-lab-guide.pdf',
      comments: [],
    ),
  ];

  List<ChatMessage> _chatMessages = const [
    ChatMessage(
      id: 'chat-1',
      subjectId: 'subject-1',
      authorName: 'نور',
      content: 'هل انتهى أحد من sheet الـ repository abstraction؟',
      sentAtLabel: '10:18 ص',
      isMine: false,
      authorRole: 'student',
    ),
    ChatMessage(
      id: 'chat-2',
      subjectId: 'subject-1',
      authorName: 'مريم حسن',
      content: 'نعم، سأشارك ملاحظاتي بعد المحاضرة مباشرة.',
      sentAtLabel: '10:20 ص',
      isMine: true,
      authorRole: 'student',
    ),
    ChatMessage(
      id: 'chat-3',
      subjectId: 'subject-2',
      authorName: 'كريم',
      content: 'تذكير: كويز الأمن غدًا داخل المعمل وليس أونلاين.',
      sentAtLabel: '8:42 ص',
      isMine: false,
      authorRole: 'assistant',
    ),
    ChatMessage(
      id: 'chat-4',
      subjectId: 'subject-1',
      authorName: 'م. نورا سامح',
      content: 'رابط المعمل التجريبي هيتثبت هنا قبل السكشن بنصف ساعة.',
      sentAtLabel: '10:24 ص',
      isMine: false,
      authorRole: 'assistant',
    ),
    ChatMessage(
      id: 'chat-5',
      subjectId: 'subject-4',
      authorName: 'سارة',
      content: 'هل تدريب A* محتاج تسليم كود ولا شرح خطوات فقط؟',
      sentAtLabel: '11:05 ص',
      isMine: false,
      authorRole: 'assistant',
    ),
    ChatMessage(
      id: 'chat-6',
      subjectId: 'subject-5',
      authorName: 'مريم حسن',
      content: 'راجعت ملف التشفير، هل نحتاج تثبيت أدوات معينة قبل المعمل؟',
      sentAtLabel: '12:18 م',
      isMine: true,
      authorRole: 'student',
    ),
    ChatMessage(
      id: 'chat-7',
      subjectId: 'subject-5',
      authorName: 'م. ليلى هشام',
      content: 'نعم، سيتم نشر checklist قبل المحاضرة بساعتين.',
      sentAtLabel: '12:22 م',
      isMine: false,
      authorRole: 'assistant',
    ),
  ];

  final List<SubjectResult> _results = const [
    SubjectResult(
      subjectId: 'subject-1',
      subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
      totalGrade: 91,
      letterGrade: 'A',
      status: 'ناجح',
      quizGrade: 18,
      assignmentGrade: 28,
      midtermGrade: 21,
      finalGrade: 24,
      notes: 'مستوى ممتاز في التطبيق العملي، حافظي على نفس الأداء في النهائي.',
    ),
    SubjectResult(
      subjectId: 'subject-2',
      subjectName: 'الحوسبة السحابية',
      totalGrade: 78,
      letterGrade: 'B',
      status: 'يحتاج متابعة',
      quizGrade: 14,
      assignmentGrade: 20,
      midtermGrade: 18,
      finalGrade: 26,
      notes: 'يوجد تراجع بسيط في الشيتات، ركزي على التسليمات القادمة.',
    ),
    SubjectResult(
      subjectId: 'subject-3',
      subjectName: 'التفاعل بين الإنسان والحاسوب',
      totalGrade: 94,
      letterGrade: 'A+',
      status: 'ناجح',
      quizGrade: 19,
      assignmentGrade: 29,
      midtermGrade: 22,
      finalGrade: 24,
      notes: 'أداء قوي جدًا في التحليل والتقييم.',
    ),
    SubjectResult(
      subjectId: 'subject-4',
      subjectName: 'الذكاء الاصطناعي',
      totalGrade: 84,
      letterGrade: 'B+',
      status: 'ناجح',
      quizGrade: 16,
      assignmentGrade: 25,
      midtermGrade: 20,
      finalGrade: 23,
      notes:
          'فهم جيد لخوارزميات البحث. ركزي على تفسير خطوات الحل في الأسئلة العملية.',
    ),
    SubjectResult(
      subjectId: 'subject-5',
      subjectName: 'أمن المعلومات',
      totalGrade: 81,
      letterGrade: 'B',
      status: 'يحتاج متابعة',
      quizGrade: 15,
      assignmentGrade: 23,
      midtermGrade: 19,
      finalGrade: 24,
      notes:
          'المستوى جيد، لكن مطلوب مراجعة إضافية في مفاهيم المفاتيح العامة والتوقيع الرقمي.',
    ),
  ];

  Future<AuthSessionData> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail == _studentSession.email && password == '123456') {
      return _studentSession;
    }
    if (normalizedEmail == _doctorSession.email && password == 'doctor123') {
      return _doctorSession;
    }
    if (normalizedEmail == _assistantSession.email &&
        password == 'assistant123') {
      return _assistantSession;
    }
    throw const AppException(
      'بيانات الدخول غير صحيحة. استخدم حساب الطالب المعتمد.',
      code: 'invalid_credentials',
    );
  }

  Future<void> verifyNationalId(
    String nationalId, {
    required String expectedNationalId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final enteredNationalId = _normalizeNationalId(nationalId);
    final normalizedExpectedNationalId = _normalizeNationalId(
      expectedNationalId,
    );

    if (enteredNationalId != normalizedExpectedNationalId) {
      throw const AppException(
        'تعذر التحقق من الرقم القومي. راجع الرقم وحاول مرة أخرى.',
        code: '12345678901234',
      );
    }
  }

  Future<StudentProfile> fetchProfile() async => _profile;

  String _normalizeNationalId(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), '');
  }

  Future<List<SubjectOverview>> fetchSubjects() async => _subjects;

  Future<SubjectOverview> fetchSubjectById(String subjectId) async {
    return _subjects.firstWhere((subject) => subject.id == subjectId);
  }

  Future<List<LectureItem>> fetchLectures({String? subjectId}) async {
    return _lectures
        .where((item) => subjectId == null || item.subjectId == subjectId)
        .toList();
  }

  Future<List<SectionItem>> fetchSections(String subjectId) async {
    return _sections.where((item) => item.subjectId == subjectId).toList();
  }

  Future<List<TaskItem>> fetchTasks(String subjectId) async {
    return _tasks.where((item) => item.subjectId == subjectId).toList();
  }

  Future<List<SubjectFileItem>> fetchSubjectFiles(String subjectId) async {
    return _subjectFiles.where((item) => item.subjectId == subjectId).toList();
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
        createdAtLabel: formatNow('d MMM', locale: 'ar'),
        videoUrl: videoUrl,
        attachmentName: attachmentName,
      ),
      ..._summaries,
    ];
  }

  Future<List<QuizItem>> fetchQuizzes({String? subjectId}) async {
    return _quizzes
        .where((item) => subjectId == null || item.subjectId == subjectId)
        .toList();
  }

  Future<void> submitQuiz(String quizId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _quizzes = _quizzes.map((quiz) {
      if (quiz.id != quizId) {
        return quiz;
      }
      return quiz.copyWith(
        attemptsUsed: quiz.attemptsUsed + 1,
        isSubmitted: true,
        submissionStateLabel: 'تم التسليم',
        scoreLabel: quiz.subjectId == 'subject-1' ? '18 / 20' : null,
      );
    }).toList();
  }

  Future<TaskItem> uploadAssignment({
    required String subjectId,
    required String taskId,
    required String fileName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    late TaskItem updatedTask;
    _tasks = _tasks.map((task) {
      if (task.id != taskId || task.subjectId != subjectId) {
        return task;
      }

      updatedTask = task.copyWith(
        status: 'تم الرفع',
        isCompleted: true,
        isMissingSubmission: false,
        allowResubmission: true,
        uploadedFileName: fileName,
      );
      return updatedTask;
    }).toList();

    _notifications = [
      AppNotificationItem(
        id: 'notification-${_notifications.length + 1}',
        title: 'تم رفع الحل بنجاح',
        body: 'تم استلام ملف "$fileName" وسيظهر ضمن المادة مباشرة.',
        createdAt: DateTime.now(),
        createdAtLabel: 'الآن',
        category: 'شيتات',
        isRead: false,
        routeName: RouteNames.assignmentUpload,
        pathParameters: {'subjectId': subjectId, 'taskId': taskId},
        subjectName: _subjects
            .firstWhere((subject) => subject.id == subjectId)
            .name,
        urgency: NotificationUrgency.important,
      ),
      ..._notifications,
    ];
    _notificationsController.add(_notifications);

    return updatedTask;
  }

  Future<HomeDashboardData> fetchHomeDashboard() async {
    return HomeDashboardData(
      profile: _profile,
      notifications: _notifications,
      subjects: _subjects,
      upcomingLectures: _lectures,
      upcomingSections: _sections,
      upcomingQuizzes: _quizzes,
      tasks: _tasks,
      courseActivities: _buildCourseActivities(DateTime.now()),
      studyInsights: _buildStudyInsights(_tasks),
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
            createdAtLabel: 'الآن',
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
        sentAtLabel: formatArabicTime(DateTime.now()),
        isMine: true,
        authorRole: 'student',
      ),
    ];
  }

  Future<void> deleteChatMessage({
    required String subjectId,
    required String messageId,
  }) async {
    _chatMessages = _chatMessages
        .where(
          (message) =>
              message.subjectId != subjectId ||
              message.id != messageId ||
              !message.isMine,
        )
        .toList();
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
    final recapLectureStart = now.subtract(const Duration(days: 1, hours: 3));
    final firstLectureStart = now.add(const Duration(hours: 1, minutes: 15));
    final secondLectureStart = now.add(const Duration(days: 1, hours: 3));
    final thirdLectureStart = now.add(const Duration(days: 3, hours: 2));
    final fourthLectureStart = now.add(const Duration(days: 2, hours: 1));
    final fifthLectureStart = now.add(const Duration(days: 4, hours: 4));

    return [
      LectureItem(
        id: 'lecture-0',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'تسجيل مراجعة Architecture Decisions',
        scheduleLabel: formatArabicSchedule(recapLectureStart, reference: now),
        startsAt: recapLectureStart,
        endsAt: recapLectureStart.add(const Duration(hours: 1, minutes: 10)),
        meetingUrl: 'https://video.tolab.edu/architecture-decisions',
        isOnline: true,
        instructorName: 'د. عمر نبيل',
        locationLabel: 'مسجل على المنصة',
      ),
      LectureItem(
        id: 'lecture-1',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'معمارية إدارة الحالة',
        scheduleLabel: formatArabicSchedule(firstLectureStart, reference: now),
        startsAt: firstLectureStart,
        endsAt: firstLectureStart.add(const Duration(hours: 1, minutes: 30)),
        meetingUrl: 'https://meet.tolab.edu/mobile',
        isOnline: true,
        instructorName: 'د. عمر نبيل',
        locationLabel: 'Tolab Meet',
      ),
      LectureItem(
        id: 'lecture-2',
        subjectId: 'subject-2',
        subjectName: 'الحوسبة السحابية',
        title: 'جدولة الخدمات السحابية',
        scheduleLabel: formatArabicSchedule(secondLectureStart, reference: now),
        startsAt: secondLectureStart,
        endsAt: secondLectureStart.add(const Duration(hours: 1)),
        meetingUrl: 'https://meet.tolab.edu/cloud',
        isOnline: true,
        instructorName: 'د. هبة مصطفى',
        locationLabel: 'Tolab Meet',
      ),
      LectureItem(
        id: 'lecture-3',
        subjectId: 'subject-3',
        subjectName: 'التفاعل بين الإنسان والحاسوب',
        title: 'تحليل قابلية الوصول',
        scheduleLabel: formatArabicSchedule(thirdLectureStart, reference: now),
        startsAt: thirdLectureStart,
        endsAt: thirdLectureStart.add(const Duration(hours: 2)),
        meetingUrl: '',
        isOnline: false,
        instructorName: 'د. نورهان فوزي',
        locationLabel: 'قاعة B201',
      ),
      LectureItem(
        id: 'lecture-4',
        subjectId: 'subject-4',
        subjectName: 'الذكاء الاصطناعي',
        title: 'خوارزميات البحث والاستدلال',
        scheduleLabel: formatArabicSchedule(fourthLectureStart, reference: now),
        startsAt: fourthLectureStart,
        endsAt: fourthLectureStart.add(const Duration(hours: 1, minutes: 30)),
        meetingUrl: 'https://meet.tolab.edu/ai-search',
        isOnline: true,
        instructorName: 'د. ياسر عادل',
        locationLabel: 'Tolab Meet',
      ),
      LectureItem(
        id: 'lecture-5',
        subjectId: 'subject-5',
        subjectName: 'أمن المعلومات',
        title: 'مقدمة في التشفير العملي',
        scheduleLabel: formatArabicSchedule(fifthLectureStart, reference: now),
        startsAt: fifthLectureStart,
        endsAt: fifthLectureStart.add(const Duration(hours: 2)),
        meetingUrl: '',
        isOnline: false,
        instructorName: 'د. أحمد فاروق',
        locationLabel: 'معمل أمن 1',
      ),
    ];
  }

  List<SectionItem> _buildSections(DateTime now) {
    final firstSectionStart = now.add(const Duration(hours: 3, minutes: 20));
    final secondSectionStart = now.add(const Duration(days: 1, hours: 1));
    final thirdSectionStart = now.add(const Duration(days: 2, hours: 5));
    final fourthSectionStart = now.add(const Duration(days: 2, hours: 7));
    final fifthSectionStart = now.add(const Duration(days: 5, hours: 2));

    return [
      SectionItem(
        id: 'section-1',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'سكشن معمل الأداء',
        location: 'معمل 3',
        scheduleLabel: formatArabicSchedule(firstSectionStart, reference: now),
        assistantName: 'م. نورا سامح',
        startsAt: firstSectionStart,
        endsAt: firstSectionStart.add(const Duration(hours: 2)),
      ),
      SectionItem(
        id: 'section-2',
        subjectId: 'subject-2',
        subjectName: 'الحوسبة السحابية',
        title: 'سكشن Kubernetes',
        location: 'أونلاين',
        scheduleLabel: formatArabicSchedule(secondSectionStart, reference: now),
        assistantName: 'م. كريم راضي',
        isOnline: true,
        meetingUrl: 'https://meet.tolab.edu/k8s',
        startsAt: secondSectionStart,
        endsAt: secondSectionStart.add(const Duration(hours: 1, minutes: 30)),
      ),
      SectionItem(
        id: 'section-3',
        subjectId: 'subject-3',
        subjectName: 'التفاعل بين الإنسان والحاسوب',
        title: 'نقاش البحث العملي',
        location: 'قاعة B201',
        scheduleLabel: formatArabicSchedule(thirdSectionStart, reference: now),
        assistantName: 'م. منة طارق',
        startsAt: thirdSectionStart,
        endsAt: thirdSectionStart.add(const Duration(hours: 1)),
      ),
      SectionItem(
        id: 'section-4',
        subjectId: 'subject-4',
        subjectName: 'الذكاء الاصطناعي',
        title: 'سكشن A* وMinimax',
        location: 'معمل 5',
        scheduleLabel: formatArabicSchedule(fourthSectionStart, reference: now),
        assistantName: 'م. سارة كمال',
        startsAt: fourthSectionStart,
        endsAt: fourthSectionStart.add(const Duration(hours: 1, minutes: 30)),
      ),
      SectionItem(
        id: 'section-5',
        subjectId: 'subject-5',
        subjectName: 'أمن المعلومات',
        title: 'معمل التشفير',
        location: 'معمل أمن 1',
        scheduleLabel: formatArabicSchedule(fifthSectionStart, reference: now),
        assistantName: 'م. ليلى هشام',
        startsAt: fifthSectionStart,
        endsAt: fifthSectionStart.add(const Duration(hours: 2)),
      ),
    ];
  }

  List<TaskItem> _buildTasks(DateTime now) {
    final urgentDeadline = now.add(const Duration(hours: 6));
    final tomorrowDeadline = now.add(const Duration(days: 1, hours: 5));
    final laterDeadline = now.add(const Duration(days: 3, hours: 2));
    final gradedDeadline = now.subtract(const Duration(days: 1, hours: 2));
    final aiDeadline = now.add(const Duration(days: 2, hours: 8));
    final securityDeadline = now.add(const Duration(hours: 10));

    return [
      TaskItem(
        id: 'task-1',
        subjectId: 'subject-2',
        subjectName: 'الحوسبة السحابية',
        title: 'شيت Service Mesh',
        description:
            'ارفع ملف PDF يشرح خطوات النشر والـ traffic policy المستخدمة.',
        dueDateLabel: formatDueLabelArabic(urgentDeadline, reference: now),
        dueAt: urgentDeadline,
        status: 'لم يتم الرفع',
        isMissingSubmission: true,
        allowResubmission: true,
      ),
      TaskItem(
        id: 'task-2',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'ورقة مراجعة المعمارية',
        description:
            'اكتب مقارنة مختصرة بين Clean Architecture وFeature-first layers.',
        dueDateLabel: formatDueLabelArabic(tomorrowDeadline, reference: now),
        dueAt: tomorrowDeadline,
        status: 'تم الرفع',
        isCompleted: true,
        allowResubmission: true,
        uploadedFileName: 'architecture-review.pdf',
      ),
      TaskItem(
        id: 'task-3',
        subjectId: 'subject-3',
        subjectName: 'التفاعل بين الإنسان والحاسوب',
        title: 'تقرير Heuristic Evaluation',
        description: 'حلل واجهة تعليمية مع 5 ملاحظات أساسية واقتراحات التحسين.',
        dueDateLabel: formatDueLabelArabic(laterDeadline, reference: now),
        dueAt: laterDeadline,
        status: 'لم يتم الرفع',
        allowResubmission: false,
      ),
      TaskItem(
        id: 'task-4',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'Checkpoint الأسبوعي',
        description:
            'تمت مراجعة التسليم مع ملاحظات على جودة الـ architecture diagram.',
        dueDateLabel: formatArabicDate(gradedDeadline),
        dueAt: gradedDeadline,
        status: 'تم التقييم',
        isCompleted: true,
        uploadedFileName: 'weekly-checkpoint.pdf',
        gradeLabel: '9 / 10',
        allowResubmission: false,
      ),
      TaskItem(
        id: 'task-5',
        subjectId: 'subject-4',
        subjectName: 'الذكاء الاصطناعي',
        title: 'تدريب خوارزميات البحث',
        description:
            'قارن بين BFS وA* في مسألة قصيرة مع توضيح cost function وخطوات الوصول للحل.',
        dueDateLabel: formatDueLabelArabic(aiDeadline, reference: now),
        dueAt: aiDeadline,
        status: 'لم يتم الرفع',
        allowResubmission: true,
      ),
      TaskItem(
        id: 'task-6',
        subjectId: 'subject-5',
        subjectName: 'أمن المعلومات',
        title: 'تقرير مفاتيح RSA',
        description:
            'ارفع تقرير PDF يشرح خطوات توليد المفاتيح وسيناريو توقيع رقمي بسيط.',
        dueDateLabel: formatDueLabelArabic(securityDeadline, reference: now),
        dueAt: securityDeadline,
        status: 'لم يتم الرفع',
        isMissingSubmission: true,
        allowResubmission: true,
      ),
    ];
  }

  List<QuizItem> _buildQuizzes(DateTime now) {
    final openQuizStart = now.subtract(const Duration(minutes: 25));
    final openQuizClose = now.add(const Duration(minutes: 50));
    final upcomingQuizStart = now.add(const Duration(days: 1, hours: 4));
    final closedQuizStart = now.subtract(const Duration(days: 3, hours: 2));
    final aiQuizStart = now.add(const Duration(days: 2, hours: 2));
    final securityQuizStart = now.subtract(const Duration(days: 5, hours: 1));

    return [
      QuizItem(
        id: 'quiz-1',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'كويز Async Flows',
        typeLabel: 'كويز أونلاين',
        startAtLabel: formatArabicSchedule(openQuizStart, reference: now),
        startsAt: openQuizStart,
        closesAt: openQuizClose,
        durationLabel: '20 دقيقة',
        isOnline: true,
        description: 'أسئلة قصيرة حول إدارة الأحداث والـ state transitions.',
        locationLabel: 'على تطبيق طلاب',
        instructions: const [
          'تأكد من ثبات الاتصال قبل البدء.',
          'يجب إنهاء الإجابة قبل انتهاء العداد.',
          'لا تغلق الشاشة أثناء محاولة الكويز.',
        ],
      ),
      QuizItem(
        id: 'quiz-2',
        subjectId: 'subject-2',
        subjectName: 'الحوسبة السحابية',
        title: 'كويز Cloud Security',
        typeLabel: 'كويز حضوري',
        startAtLabel: formatArabicSchedule(upcomingQuizStart, reference: now),
        startsAt: upcomingQuizStart,
        closesAt: upcomingQuizStart.add(const Duration(minutes: 45)),
        durationLabel: '45 دقيقة',
        isOnline: false,
        description: 'اختبار قصير على الهوية والصلاحيات وأفضل ممارسات التأمين.',
        locationLabel: 'معمل 2',
        maxAttempts: 1,
        instructions: const [
          'أحضر البطاقة الجامعية قبل بداية الكويز.',
          'الحضور قبل الموعد بـ 15 دقيقة.',
        ],
      ),
      QuizItem(
        id: 'quiz-3',
        subjectId: 'subject-3',
        subjectName: 'التفاعل بين الإنسان والحاسوب',
        title: 'كويز Usability Metrics',
        typeLabel: 'كويز منتهي',
        startAtLabel: formatArabicSchedule(closedQuizStart, reference: now),
        startsAt: closedQuizStart,
        closesAt: closedQuizStart.add(const Duration(minutes: 30)),
        durationLabel: '30 دقيقة',
        isOnline: true,
        description: 'تم إنهاء الكويز السابق واحتساب الدرجة.',
        locationLabel: 'على تطبيق طلاب',
        attemptsUsed: 1,
        maxAttempts: 1,
        isSubmitted: true,
        submissionStateLabel: 'تم التسليم',
        scoreLabel: '19 / 20',
        instructions: const ['تم غلق هذا الكويز.'],
      ),
      QuizItem(
        id: 'quiz-4',
        subjectId: 'subject-4',
        subjectName: 'الذكاء الاصطناعي',
        title: 'كويز Search Algorithms',
        typeLabel: 'كويز أونلاين',
        startAtLabel: formatArabicSchedule(aiQuizStart, reference: now),
        startsAt: aiQuizStart,
        closesAt: aiQuizStart.add(const Duration(minutes: 35)),
        durationLabel: '35 دقيقة',
        durationMinutes: 35,
        isOnline: true,
        description: 'أسئلة اختيارية على BFS وDFS وA*.',
        locationLabel: 'على تطبيق طلاب',
        questionCount: 8,
        instructions: const [
          'راجع ورقة السكشن قبل بدء الكويز.',
          'محاولة واحدة فقط خلال وقت الفتح.',
        ],
      ),
      QuizItem(
        id: 'quiz-5',
        subjectId: 'subject-5',
        subjectName: 'أمن المعلومات',
        title: 'كويز Cryptography Basics',
        typeLabel: 'كويز منتهي',
        startAtLabel: formatArabicSchedule(securityQuizStart, reference: now),
        startsAt: securityQuizStart,
        closesAt: securityQuizStart.add(const Duration(minutes: 25)),
        durationLabel: '25 دقيقة',
        durationMinutes: 25,
        isOnline: true,
        description: 'تم إنهاء كويز أساسيات التشفير.',
        attemptsUsed: 1,
        maxAttempts: 1,
        isSubmitted: true,
        submissionStateLabel: 'تم التسليم',
        scoreLabel: '15 / 20',
        questionCount: 10,
        instructions: const ['تم غلق هذا الكويز.'],
      ),
    ];
  }

  List<SubjectFileItem> _buildSubjectFiles(DateTime now) {
    return [
      SubjectFileItem(
        id: 'file-1',
        subjectId: 'subject-1',
        title: 'شرائح المحاضرة الخامسة',
        fileName: 'mobile-architecture-week5.pdf',
        typeLabel: 'محاضرة',
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 1)),
        ),
      ),
      SubjectFileItem(
        id: 'file-2',
        subjectId: 'subject-2',
        title: 'متطلبات الشيت الثاني',
        fileName: 'service-mesh-assignment.docx',
        typeLabel: 'شيت',
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(days: 1)),
        ),
      ),
      SubjectFileItem(
        id: 'file-3',
        subjectId: 'subject-3',
        title: 'Checklist التقييم',
        fileName: 'ux-evaluation-checklist.pdf',
        typeLabel: 'ملف إضافي',
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(days: 2)),
        ),
      ),
      SubjectFileItem(
        id: 'file-4',
        subjectId: 'subject-4',
        title: 'تدريب خوارزميات البحث',
        fileName: 'ai-search-practice.pdf',
        typeLabel: 'سكشن',
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 3)),
        ),
      ),
      SubjectFileItem(
        id: 'file-5',
        subjectId: 'subject-5',
        title: 'دليل معمل التشفير',
        fileName: 'crypto-lab-guide.pdf',
        typeLabel: 'معمل',
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 5)),
        ),
      ),
    ];
  }

  List<CourseActivityItem> _buildCourseActivities(DateTime now) {
    return [
      CourseActivityItem(
        id: 'activity-1',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'تم رفع محاضرة جديدة',
        description:
            'التسجيل والشرائح الخاصة بمحاضرة معمارية الحالة متاحة الآن.',
        type: CourseActivityType.lecture,
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(minutes: 35)),
        ),
        createdAt: now.subtract(const Duration(minutes: 35)),
      ),
      CourseActivityItem(
        id: 'activity-2',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        title: 'تم فتح كويز جديد',
        description: 'كويز Async Flows متاح حاليًا ويغلق خلال أقل من ساعة.',
        type: CourseActivityType.quiz,
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(minutes: 10)),
        ),
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      CourseActivityItem(
        id: 'activity-3',
        subjectId: 'subject-2',
        subjectName: 'الحوسبة السحابية',
        title: 'تسليم شيت قريب',
        description: 'شيت Service Mesh يحتاج رفع قبل نهاية اليوم.',
        type: CourseActivityType.assignment,
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 2)),
        ),
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      CourseActivityItem(
        id: 'activity-4',
        subjectId: 'subject-3',
        subjectName: 'التفاعل بين الإنسان والحاسوب',
        title: 'آخر منشور في الجروب',
        description: 'تم تعديل توزيع المجموعات داخل سكشن قابلية الوصول.',
        type: CourseActivityType.groupPost,
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(days: 1)),
        ),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CourseActivityItem(
        id: 'activity-5',
        subjectId: 'subject-4',
        subjectName: 'الذكاء الاصطناعي',
        title: 'تم نشر تدريب AI جديد',
        description: 'تدريب خوارزميات البحث متاح الآن مع ملف PDF للمراجعة.',
        type: CourseActivityType.assignment,
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(minutes: 45)),
        ),
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      CourseActivityItem(
        id: 'activity-6',
        subjectId: 'subject-5',
        subjectName: 'أمن المعلومات',
        title: 'إعلان معمل التشفير',
        description: 'تم رفع تعليمات الحضور والتسليم لمعمل التشفير القادم.',
        type: CourseActivityType.announcement,
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 4)),
        ),
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  StudyInsightsData _buildStudyInsights(List<TaskItem> tasks) {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;

    return StudyInsightsData(
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      viewedLectures: 12,
      engagementScore: 0.82,
      engagementLabel: 'تفاعل قوي هذا الأسبوع',
    );
  }

  List<AppNotificationItem> _buildNotifications(DateTime now) {
    return [
      AppNotificationItem(
        id: 'notification-1',
        title: 'لديك كويز مفتوح الآن',
        body: 'كويز Async Flows متاح لمدة 50 دقيقة من الآن.',
        createdAt: now.subtract(const Duration(minutes: 10)),
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(minutes: 10)),
        ),
        category: 'كويزات',
        isRead: false,
        routeName: RouteNames.quizEntry,
        pathParameters: {'subjectId': 'subject-1', 'quizId': 'quiz-1'},
        isImportant: true,
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        urgency: NotificationUrgency.urgent,
      ),
      AppNotificationItem(
        id: 'notification-2',
        title: 'محاضرة تبدأ بعد قليل',
        body: 'محاضرة معمارية إدارة الحالة تبدأ خلال ساعة و15 دقيقة.',
        createdAt: now.subtract(const Duration(hours: 1)),
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 1)),
        ),
        category: 'أكاديمي',
        isRead: false,
        routeName: RouteNames.subjectDetails,
        pathParameters: {'subjectId': 'subject-1'},
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        urgency: NotificationUrgency.important,
      ),
      AppNotificationItem(
        id: 'notification-3',
        title: 'تسليم يحتاج متابعة',
        body: 'شيت Service Mesh لم يتم رفعه بعد ويغلق اليوم.',
        createdAt: now.subtract(const Duration(days: 1)),
        createdAtLabel: 'أمس',
        category: 'شيتات',
        isRead: true,
        routeName: RouteNames.assignmentUpload,
        pathParameters: {'subjectId': 'subject-2', 'taskId': 'task-1'},
        isImportant: true,
        subjectName: 'الحوسبة السحابية',
        urgency: NotificationUrgency.urgent,
      ),
      AppNotificationItem(
        id: 'notification-4',
        title: 'تم تحديث النتائج',
        body: 'درجات مادة التفاعل بين الإنسان والحاسوب أصبحت متاحة الآن.',
        createdAt: now.subtract(const Duration(days: 2)),
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(days: 2)),
        ),
        category: 'درجات',
        isRead: true,
        routeName: RouteNames.results,
        subjectName: 'التفاعل بين الإنسان والحاسوب',
        urgency: NotificationUrgency.newItem,
      ),
      AppNotificationItem(
        id: 'notification-5',
        title: 'منشور جديد في الجروب',
        body: 'تم نشر تعديل على مجموعات السكشن داخل مادة HCI.',
        createdAt: now.subtract(const Duration(hours: 6)),
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 6)),
        ),
        category: 'الجروب',
        isRead: false,
        routeName: RouteNames.subjectDetails,
        pathParameters: {'subjectId': 'subject-3'},
        subjectName: 'التفاعل بين الإنسان والحاسوب',
        urgency: NotificationUrgency.important,
      ),
      AppNotificationItem(
        id: 'notification-6',
        title: 'College Announcement',
        body: 'تم فتح باب تسجيل الرغبات للمواد الاختيارية حتى الخميس القادم.',
        createdAt: now.subtract(const Duration(minutes: 25)),
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(minutes: 25)),
        ),
        category: 'إعلان الكلية',
        isRead: false,
        routeName: RouteNames.notifications,
        isImportant: true,
        urgency: NotificationUrgency.important,
      ),
      AppNotificationItem(
        id: 'notification-7',
        title: 'Subject Announcement',
        body: 'تم نشر تدريب خوارزميات البحث داخل مادة الذكاء الاصطناعي.',
        createdAt: now.subtract(const Duration(minutes: 45)),
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(minutes: 45)),
        ),
        category: 'إعلان مادة',
        isRead: false,
        routeName: RouteNames.subjectDetails,
        pathParameters: {'subjectId': 'subject-4'},
        subjectName: 'الذكاء الاصطناعي',
        isImportant: true,
        urgency: NotificationUrgency.important,
      ),
      AppNotificationItem(
        id: 'notification-8',
        title: 'Personal Notification',
        body: 'لديك تقرير RSA يحتاج رفع قبل نهاية اليوم.',
        createdAt: now.subtract(const Duration(hours: 2)),
        createdAtLabel: formatRelativeArabic(
          now.subtract(const Duration(hours: 2)),
        ),
        category: 'شخصي',
        isRead: false,
        routeName: RouteNames.assignmentUpload,
        pathParameters: {'subjectId': 'subject-5', 'taskId': 'task-6'},
        subjectName: 'أمن المعلومات',
        isImportant: true,
        urgency: NotificationUrgency.urgent,
      ),
    ];
  }
}
