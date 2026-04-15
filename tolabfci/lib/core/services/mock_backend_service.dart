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
    email: 'mariam.hassan@tolab.edu',
    avatarUrl: '',
    studentNumber: '20241182',
    nationalId: '29801011234567',
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
    email: 'mariam.hassan@tolab.edu',
    nationalId: '29801011234567',
  );

  final AuthSessionData _doctorSession = const AuthSessionData(
    token: 'mock-doctor-access-token',
    role: AppUserRole.doctor,
    email: 'omar.nabil@tolab.edu',
    nationalId: '28601011234567',
  );

  final AuthSessionData _assistantSession = const AuthSessionData(
    token: 'mock-assistant-access-token',
    role: AppUserRole.assistant,
    email: 'nora.sameh@tolab.edu',
    nationalId: '29701011234567',
  );

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
      authorName: 'منة طارق',
      authorRole: 'طالبة',
      content: 'رفعت ملاحظات سريعة عن autoscaling والـ scheduling لمن يحتاجها.',
      createdAtLabel: 'أمس',
      reactions: 11,
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
    ),
    ChatMessage(
      id: 'chat-2',
      subjectId: 'subject-1',
      authorName: 'مريم حسن',
      content: 'نعم، سأشارك ملاحظاتي بعد المحاضرة مباشرة.',
      sentAtLabel: '10:20 ص',
      isMine: true,
    ),
    ChatMessage(
      id: 'chat-3',
      subjectId: 'subject-2',
      authorName: 'كريم',
      content: 'تذكير: كويز الأمن غدًا داخل المعمل وليس أونلاين.',
      sentAtLabel: '8:42 ص',
      isMine: false,
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
  ];

  Future<AuthSessionData> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail == _studentSession.email && password == 'student123') {
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
    required AppUserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final expectedNationalId = switch (role) {
      AppUserRole.student => _studentSession.nationalId,
      AppUserRole.doctor => _doctorSession.nationalId,
      AppUserRole.assistant => _assistantSession.nationalId,
    };

    if (nationalId.trim() != expectedNationalId) {
      throw const AppException(
        'تعذر التحقق من الرقم القومي. راجع الرقم وحاول مرة أخرى.',
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
    ];
  }

  List<SectionItem> _buildSections(DateTime now) {
    final firstSectionStart = now.add(const Duration(hours: 3, minutes: 20));
    final secondSectionStart = now.add(const Duration(days: 1, hours: 1));
    final thirdSectionStart = now.add(const Duration(days: 2, hours: 5));

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
    ];
  }

  List<TaskItem> _buildTasks(DateTime now) {
    final urgentDeadline = now.add(const Duration(hours: 6));
    final tomorrowDeadline = now.add(const Duration(days: 1, hours: 5));
    final laterDeadline = now.add(const Duration(days: 3, hours: 2));
    final gradedDeadline = now.subtract(const Duration(days: 1, hours: 2));

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
    ];
  }

  List<QuizItem> _buildQuizzes(DateTime now) {
    final openQuizStart = now.subtract(const Duration(minutes: 25));
    final openQuizClose = now.add(const Duration(minutes: 50));
    final upcomingQuizStart = now.add(const Duration(days: 1, hours: 4));
    final closedQuizStart = now.subtract(const Duration(days: 3, hours: 2));

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
      ),
    ];
  }
}
