import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/services/root_scaffold_messenger.dart';

class TolabStudentPrototypeApp extends StatefulWidget {
  const TolabStudentPrototypeApp({super.key});

  @override
  State<TolabStudentPrototypeApp> createState() =>
      _TolabStudentPrototypeAppState();
}

class _TolabStudentPrototypeAppState extends State<TolabStudentPrototypeApp> {
  bool _isArabic = true;
  AuthFlowStage _authStage = AuthFlowStage.splash;
  RootTab _rootTab = RootTab.home;
  bool _isBusy = false;
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  NotificationFilter _notificationFilter = NotificationFilter.all;
  CommunityFilter _communityFilter = CommunityFilter.newest;
  final List<AppRouteData> _stack = [];
  late final MockStudentData _data = MockStudentData();

  String t(String ar, String en) => _isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tolab',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      locale: Locale(_isArabic ? 'ar' : 'en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _buildCurrentStage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: brightness,
      primary: const Color(0xFF2563EB),
      secondary: const Color(0xFF0F766E),
      tertiary: const Color(0xFFB45309),
      surface: isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0B1020)
          : const Color(0xFFF6F8FB),
      fontFamily: 'Arial',
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? const Color(0xFF111827) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? const Color(0xFF273449) : const Color(0xFFE4E8F0),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        indicatorColor: const Color(0xFFE0ECFF),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF273449) : const Color(0xFFD8DEE9),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStage() {
    return switch (_authStage) {
      AuthFlowStage.splash => SplashPrototypePage(
        isArabic: _isArabic,
        onToggleLanguage: _toggleLanguage,
        onContinue: () => setState(() => _authStage = AuthFlowStage.login),
      ),
      AuthFlowStage.login => MicrosoftLoginPrototypePage(
        isArabic: _isArabic,
        isBusy: _isBusy,
        onToggleLanguage: _toggleLanguage,
        onMicrosoftLogin: _mockMicrosoftLogin,
      ),
      AuthFlowStage.verifyNationalId => NationalIdVerificationPrototypePage(
        isArabic: _isArabic,
        isBusy: _isBusy,
        profile: _data.profile,
        onBack: () => setState(() => _authStage = AuthFlowStage.login),
        onVerify: _verifyNationalId,
      ),
      AuthFlowStage.app => _buildStudentShell(),
    };
  }

  void _toggleLanguage() {
    setState(() => _isArabic = !_isArabic);
  }

  Future<void> _mockMicrosoftLogin() async {
    setState(() => _isBusy = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    setState(() {
      _isBusy = false;
      _authStage = AuthFlowStage.verifyNationalId;
    });
    _showToast(t('تم تسجيل الدخول بحساب Microsoft', 'Microsoft sign-in done'));
  }

  Future<void> _verifyNationalId(String nationalId) async {
    final clean = nationalId.trim();
    if (clean.length != 14 || int.tryParse(clean) == null) {
      _showToast(
        t(
          'اكتب رقم قومي صحيح مكون من 14 رقم',
          'Enter a valid 14-digit National ID',
        ),
      );
      return;
    }
    if (clean == '99999999999999') {
      _showToast(
        t(
          'هذا الحساب موقوف ولا يمكنه دخول التطبيق',
          'This student is disabled and cannot access the app',
        ),
      );
      return;
    }
    setState(() => _isBusy = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    if (clean != _data.profile.nationalId) {
      setState(() => _isBusy = false);
      _showToast(
        t(
          'لم يتم العثور على طالب مطابق لهذا الرقم',
          'No student record matches this National ID',
        ),
      );
      return;
    }
    setState(() {
      _isBusy = false;
      _authStage = AuthFlowStage.app;
      _rootTab = RootTab.home;
      _stack.clear();
    });
    _showToast(
      t(
        'تم ربط حساب Microsoft ببيانات الطالب',
        'Microsoft account linked to student record',
      ),
    );
  }

  Widget _buildStudentShell() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 920;
        final body = _stack.isEmpty
            ? _buildRootPage()
            : _buildRoutePage(_stack.last, isDesktop: isDesktop);

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopSidebar(
                  isArabic: _isArabic,
                  selectedTab: _rootTab,
                  unreadCount: _unreadNotificationsCount,
                  onSelect: _selectRootTab,
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _rootTab.index,
            onDestinationSelected: (index) =>
                _selectRootTab(RootTab.values[index]),
            destinations: _rootDestinations(isDesktop: false),
          ),
        );
      },
    );
  }

  List<NavigationDestination> _rootDestinations({required bool isDesktop}) {
    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: t('الرئيسية', 'Home'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book_rounded),
        label: t('المواد', 'Subjects'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month_rounded),
        label: t('الجدول', 'Schedule'),
      ),
      NavigationDestination(
        icon: _BadgeIcon(
          icon: Icons.notifications_none_rounded,
          count: _unreadNotificationsCount,
        ),
        selectedIcon: _BadgeIcon(
          icon: Icons.notifications_rounded,
          count: _unreadNotificationsCount,
        ),
        label: t('الإشعارات', 'Notifications'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.grid_view_rounded),
        selectedIcon: const Icon(Icons.dashboard_customize_rounded),
        label: t('المزيد', 'More'),
      ),
    ];
  }

  int get _unreadNotificationsCount {
    if (!_notificationsEnabled) {
      return 0;
    }
    return _data.notifications.where((item) => !item.isRead).length;
  }

  void _selectRootTab(RootTab tab) {
    setState(() {
      _rootTab = tab;
      _stack.clear();
    });
  }

  void _open(
    RouteKind kind, {
    String? subjectId,
    String? itemId,
    Map<String, Object?> extras = const {},
  }) {
    setState(() {
      _stack.add(
        AppRouteData(
          kind: kind,
          subjectId: subjectId,
          itemId: itemId,
          extras: extras,
        ),
      );
    });
  }

  void _replaceTop(
    RouteKind kind, {
    String? subjectId,
    String? itemId,
    Map<String, Object?> extras = const {},
  }) {
    setState(() {
      if (_stack.isNotEmpty) {
        _stack.removeLast();
      }
      _stack.add(
        AppRouteData(
          kind: kind,
          subjectId: subjectId,
          itemId: itemId,
          extras: extras,
        ),
      );
    });
  }

  void _goBack() {
    if (_stack.isNotEmpty) {
      setState(_stack.removeLast);
    }
  }

  Widget _buildRootPage() {
    return switch (_rootTab) {
      RootTab.home => HomeDashboardPrototypePage(
        isArabic: _isArabic,
        data: _data,
        onOpenSubject: (subjectId) =>
            _open(RouteKind.subjectDetails, subjectId: subjectId),
        onOpenSchedule: () => _selectRootTab(RootTab.schedule),
        onOpenNotifications: () => _selectRootTab(RootTab.notifications),
        onOpenQuiz: (subjectId, quizId) =>
            _open(RouteKind.quizDetails, subjectId: subjectId, itemId: quizId),
      ),
      RootTab.subjects => SubjectsPrototypePage(
        isArabic: _isArabic,
        subjects: _data.subjects,
        onOpenSubject: (subjectId) =>
            _open(RouteKind.subjectDetails, subjectId: subjectId),
      ),
      RootTab.schedule => SchedulePrototypePage(
        isArabic: _isArabic,
        schedule: _data.schedule,
        subjects: _data.subjects,
        onOpenSubject: (subjectId) =>
            _open(RouteKind.subjectDetails, subjectId: subjectId),
        onOpenLecture: (subjectId, lectureId) => _open(
          RouteKind.lectureDetails,
          subjectId: subjectId,
          itemId: lectureId,
        ),
      ),
      RootTab.notifications => NotificationsPrototypePage(
        isArabic: _isArabic,
        notifications: _visibleNotifications,
        unreadCount: _unreadNotificationsCount,
        selectedFilter: _notificationFilter,
        notificationsEnabled: _notificationsEnabled,
        onFilterChanged: (filter) =>
            setState(() => _notificationFilter = filter),
        onOpenNotification: _openNotification,
      ),
      RootTab.more => MorePrototypePage(
        isArabic: _isArabic,
        profile: _data.profile,
        notificationsEnabled: _notificationsEnabled,
        onOpenProfile: () => _open(RouteKind.profile),
        onOpenResults: () => _open(RouteKind.results),
        onOpenLanguage: () => _open(RouteKind.languageSettings),
        onOpenNotificationSettings: () => _open(RouteKind.notificationSettings),
        onLogout: () => _open(RouteKind.logout),
      ),
    };
  }

  List<NotificationItem> get _visibleNotifications {
    if (!_notificationsEnabled) {
      return const [];
    }
    return _data.notifications.where((item) {
      return switch (_notificationFilter) {
        NotificationFilter.all => true,
        NotificationFilter.unread => !item.isRead,
        NotificationFilter.important => item.isImportant,
      };
    }).toList();
  }

  void _openNotification(NotificationItem item) {
    setState(() => item.isRead = true);
    _open(RouteKind.notificationDetails, itemId: item.id);
  }

  Widget _buildRoutePage(AppRouteData route, {required bool isDesktop}) {
    final subject = route.subjectId == null
        ? null
        : _data.subjectById(route.subjectId!);
    return switch (route.kind) {
      RouteKind.subjectDetails => SubjectDetailsPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        lectures: _data.lecturesFor(subject.id),
        sections: _data.sectionsFor(subject.id),
        quizzes: _data.quizzesFor(subject.id),
        tasks: _data.tasksFor(subject.id),
        summaries: _data.summariesFor(subject.id),
        posts: _data.postsFor(subject.id),
        messages: _data.messagesFor(subject.id),
        onBack: _goBack,
        onOpenSection: (kind) => _open(kind, subjectId: subject.id),
        onOpenQuiz: (quizId) =>
            _open(RouteKind.quizDetails, subjectId: subject.id, itemId: quizId),
      ),
      RouteKind.lectures => LecturesPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        lectures: _data.lecturesFor(subject.id),
        onBack: _goBack,
        onOpenLecture: (lectureId) => _open(
          RouteKind.lectureDetails,
          subjectId: subject.id,
          itemId: lectureId,
        ),
        onOpenPdf: (lectureId) => _open(
          RouteKind.pdfPreview,
          subjectId: subject.id,
          itemId: lectureId,
        ),
        onOpenVideo: (lectureId) => _open(
          RouteKind.videoPlayer,
          subjectId: subject.id,
          itemId: lectureId,
        ),
      ),
      RouteKind.lectureDetails => LectureDetailsPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        lecture: _data.lectureById(route.itemId!),
        onBack: _goBack,
        onOpenPdf: () => _open(
          RouteKind.pdfPreview,
          subjectId: subject.id,
          itemId: route.itemId,
        ),
        onOpenVideo: () => _open(
          RouteKind.videoPlayer,
          subjectId: subject.id,
          itemId: route.itemId,
        ),
      ),
      RouteKind.pdfPreview => PdfPreviewPrototypePage(
        isArabic: _isArabic,
        lecture: _data.lectureById(route.itemId!),
        onBack: _goBack,
      ),
      RouteKind.videoPlayer => VideoPlayerPrototypePage(
        isArabic: _isArabic,
        lecture: _data.lectureById(route.itemId!),
        onBack: _goBack,
      ),
      RouteKind.sections => SectionsPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        sections: _data.sectionsFor(subject.id),
        onBack: _goBack,
        onAction: _showToast,
      ),
      RouteKind.quizzes => QuizzesPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        quizzes: _data.quizzesFor(subject.id),
        onBack: _goBack,
        onOpenQuiz: (quizId) =>
            _open(RouteKind.quizDetails, subjectId: subject.id, itemId: quizId),
        onEnterQuiz: (quizId) => _enterQuiz(subject.id, quizId),
      ),
      RouteKind.quizDetails => QuizDetailsPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        quiz: _data.quizById(route.itemId!),
        onBack: _goBack,
        onEnterQuiz: () => _enterQuiz(subject.id, route.itemId!),
      ),
      RouteKind.quizTaking => QuizTakingPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        quiz: _data.quizById(route.itemId!),
        onSubmit: (score) => _submitQuiz(subject.id, route.itemId!, score),
        onExit: _goBack,
      ),
      RouteKind.quizResult => QuizResultPrototypePage(
        isArabic: _isArabic,
        quiz: _data.quizById(route.itemId!),
        onBackToSubject: () {
          setState(() {
            _stack.clear();
            _stack.add(
              AppRouteData(
                kind: RouteKind.subjectDetails,
                subjectId: route.subjectId,
              ),
            );
          });
        },
        onBack: _goBack,
      ),
      RouteKind.tasks => TasksPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        tasks: _data.tasksFor(subject.id),
        onBack: _goBack,
        onUpload: (task) => _mockUploadTask(task),
      ),
      RouteKind.summaries => SummariesPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        summaries: _data.summariesFor(subject.id),
        onBack: _goBack,
        onAddSummary: () => _open(RouteKind.addSummary, subjectId: subject.id),
        onOpenSummary: (summaryId) => _open(
          RouteKind.summaryDetails,
          subjectId: subject.id,
          itemId: summaryId,
        ),
      ),
      RouteKind.summaryDetails => SummaryDetailsPrototypePage(
        isArabic: _isArabic,
        summary: _data.summaryById(route.itemId!),
        onBack: _goBack,
        onPreview: (message) => _showToast(message),
      ),
      RouteKind.addSummary => AddSummaryPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        onBack: _goBack,
        onSubmit: (title, videoUrl, attachmentName) {
          setState(() {
            _data.summaries.insert(
              0,
              SummaryItem(
                id: 'summary-${_data.summaries.length + 1}',
                subjectId: subject.id,
                title: LText(title, title),
                author: _data.profile.name,
                createdLabel: LText('الآن', 'Now'),
                attachmentName: attachmentName,
                videoUrl: videoUrl,
                likes: 0,
              ),
            );
          });
          _showToast(t('تم نشر الملخص', 'Summary published'));
          _goBack();
        },
      ),
      RouteKind.community => CommunityPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        posts: _filteredPosts(subject.id),
        selectedFilter: _communityFilter,
        onBack: _goBack,
        onFilterChanged: (filter) => setState(() => _communityFilter = filter),
        onReact: (post) => setState(() => post.reactions++),
        onOpenPost: (postId) =>
            _open(RouteKind.postDetails, subjectId: subject.id, itemId: postId),
      ),
      RouteKind.postDetails => PostDetailsPrototypePage(
        isArabic: _isArabic,
        post: _data.postById(route.itemId!),
        onBack: _goBack,
        onReact: (post) => setState(() => post.reactions++),
        onAddComment: (post, comment) {
          setState(() {
            post.comments.add(
              CommunityComment(
                id: 'comment-${post.comments.length + 1}',
                author: _data.profile.name,
                body: LText(comment, comment),
                createdLabel: LText('الآن', 'Now'),
              ),
            );
          });
          _showToast(t('تمت إضافة التعليق', 'Comment added'));
        },
      ),
      RouteKind.chat => GroupChatPrototypePage(
        isArabic: _isArabic,
        subject: subject!,
        isRegistered: _data.isRegistered(subject.id),
        messages: _data.messagesFor(subject.id),
        profile: _data.profile,
        onBack: _goBack,
        onSend: (content) {
          setState(() {
            _data.chatMessages.add(
              ChatMessage(
                id: 'message-${_data.chatMessages.length + 1}',
                subjectId: subject.id,
                author: _data.profile.name,
                content: LText(content, content),
                timeLabel: LText('الآن', 'Now'),
                isMine: true,
              ),
            );
          });
        },
        onDelete: (message) {
          setState(() => _data.chatMessages.remove(message));
          _showToast(t('تم حذف رسالتك', 'Your message was deleted'));
        },
        onReport: () => _showToast(
          t('تم إرسال البلاغ للمشرف', 'Report sent to moderation team'),
        ),
      ),
      RouteKind.notificationDetails => NotificationDetailsPrototypePage(
        isArabic: _isArabic,
        notification: _data.notificationById(route.itemId!),
        onBack: _goBack,
        onOpenTarget: _openNotificationTarget,
      ),
      RouteKind.profile => ProfilePrototypePage(
        isArabic: _isArabic,
        profile: _data.profile,
        onBack: _goBack,
      ),
      RouteKind.results => ResultsPrototypePage(
        isArabic: _isArabic,
        profile: _data.profile,
        results: _data.results,
        onBack: _goBack,
      ),
      RouteKind.languageSettings => LanguageSettingsPrototypePage(
        isArabic: _isArabic,
        onBack: _goBack,
        onChanged: (value) => setState(() => _isArabic = value),
      ),
      RouteKind.notificationSettings => NotificationSettingsPrototypePage(
        isArabic: _isArabic,
        enabled: _notificationsEnabled,
        pushEnabled: _pushNotifications,
        emailEnabled: _emailNotifications,
        onBack: _goBack,
        onChanged: ({bool? enabled, bool? push, bool? email}) {
          setState(() {
            if (enabled != null) {
              _notificationsEnabled = enabled;
            }
            if (push != null) {
              _pushNotifications = push;
            }
            if (email != null) {
              _emailNotifications = email;
            }
          });
        },
      ),
      RouteKind.logout => LogoutFlowPrototypePage(
        isArabic: _isArabic,
        profile: _data.profile,
        onBack: _goBack,
        onConfirm: _logout,
      ),
    };
  }

  List<CommunityPost> _filteredPosts(String subjectId) {
    final posts = _data.postsFor(subjectId);
    if (_communityFilter == CommunityFilter.oldest) {
      return posts.reversed.toList();
    }
    return posts;
  }

  void _enterQuiz(String subjectId, String quizId) {
    final quiz = _data.quizById(quizId);
    if (!quiz.canEnter) {
      _showToast(
        t(
          'زر الدخول يتفعل فقط في موعد الكويز',
          'Enter becomes active only during the quiz window',
        ),
      );
      return;
    }
    if (!quiz.isOnline) {
      _showToast(t('هذا الكويز حضوري داخل القاعة', 'This quiz is offline'));
      return;
    }
    _open(RouteKind.quizTaking, subjectId: subjectId, itemId: quizId);
  }

  void _submitQuiz(String subjectId, String quizId, int score) {
    final quiz = _data.quizById(quizId);
    setState(() {
      quiz.status = QuizStatus.completed;
      quiz.score = score;
      quiz.submitted = true;
      _data.notifications.insert(
        0,
        NotificationItem(
          id: 'notification-${_data.notifications.length + 1}',
          title: LText('تم تسليم الكويز', 'Quiz submitted'),
          body: LText(
            'تم تسجيل نتيجتك في ${quiz.title.ar}: $score / ${quiz.questions.length}',
            'Your result for ${quiz.title.en} is $score / ${quiz.questions.length}',
          ),
          createdLabel: LText('الآن', 'Now'),
          type: NotificationType.personal,
          isImportant: false,
          isRead: false,
          target: NotificationTarget.quiz,
          subjectId: subjectId,
          targetId: quizId,
        ),
      );
    });
    _replaceTop(RouteKind.quizResult, subjectId: subjectId, itemId: quizId);
  }

  void _mockUploadTask(TaskItem task) {
    setState(() {
      task.status = TaskStatus.submitted;
      task.uploadedFile = 'tolab-submission.pdf';
      _data.notifications.insert(
        0,
        NotificationItem(
          id: 'notification-${_data.notifications.length + 1}',
          title: LText('تم رفع المهمة', 'Task uploaded'),
          body: LText(
            'تم استلام ملف ${task.uploadedFile} بنجاح.',
            '${task.uploadedFile} was uploaded successfully.',
          ),
          createdLabel: LText('الآن', 'Now'),
          type: NotificationType.personal,
          isImportant: false,
          isRead: false,
          target: NotificationTarget.task,
          subjectId: task.subjectId,
          targetId: task.id,
        ),
      );
    });
    _showToast(t('تم رفع ملف تجريبي بنجاح', 'Mock file uploaded'));
  }

  void _openNotificationTarget(NotificationItem item) {
    if (item.target == NotificationTarget.none) {
      _showToast(
        t(
          'هذا إعلان رسمي بدون رابط إضافي',
          'This official announcement has no extra link',
        ),
      );
      return;
    }
    setState(_stack.clear);
    switch (item.target) {
      case NotificationTarget.subject:
        _rootTab = RootTab.subjects;
        _open(RouteKind.subjectDetails, subjectId: item.subjectId);
      case NotificationTarget.quiz:
        _rootTab = RootTab.subjects;
        _open(
          RouteKind.quizDetails,
          subjectId: item.subjectId,
          itemId: item.targetId,
        );
      case NotificationTarget.task:
        _rootTab = RootTab.subjects;
        _open(RouteKind.tasks, subjectId: item.subjectId);
      case NotificationTarget.results:
        _rootTab = RootTab.more;
        _open(RouteKind.results);
      case NotificationTarget.schedule:
        _selectRootTab(RootTab.schedule);
      case NotificationTarget.none:
        break;
    }
  }

  void _logout() {
    setState(() {
      _authStage = AuthFlowStage.login;
      _rootTab = RootTab.home;
      _stack.clear();
    });
    _showToast(t('تم تسجيل الخروج', 'Signed out'));
  }

  void _showToast(String message) {
    if (!mounted) {
      return;
    }
    rootScaffoldMessengerKey.currentState?.clearSnackBars();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1700),
      ),
    );
  }
}

enum AuthFlowStage { splash, login, verifyNationalId, app }

enum RootTab { home, subjects, schedule, notifications, more }

enum RouteKind {
  subjectDetails,
  lectures,
  lectureDetails,
  pdfPreview,
  videoPlayer,
  sections,
  quizzes,
  quizDetails,
  quizTaking,
  quizResult,
  tasks,
  summaries,
  summaryDetails,
  addSummary,
  community,
  postDetails,
  chat,
  notificationDetails,
  profile,
  results,
  languageSettings,
  notificationSettings,
  logout,
}

enum QuizStatus { upcoming, available, completed, expired }

enum TaskStatus { pending, submitted, graded, late }

enum NotificationType { college, subject, personal }

enum NotificationTarget { none, subject, quiz, task, results, schedule }

enum NotificationFilter { all, unread, important }

enum CommunityFilter { newest, oldest, all }

class AppRouteData {
  const AppRouteData({
    required this.kind,
    this.subjectId,
    this.itemId,
    this.extras = const {},
  });

  final RouteKind kind;
  final String? subjectId;
  final String? itemId;
  final Map<String, Object?> extras;
}

class LText {
  const LText(this.ar, this.en);

  final String ar;
  final String en;

  String of(bool isArabic) => isArabic ? ar : en;
}

class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.email,
    required this.code,
    required this.nationalId,
    required this.department,
    required this.level,
    required this.enrollmentStatus,
    required this.admissionYear,
    required this.nationality,
    required this.birthDate,
    required this.previousQualification,
    required this.faculty,
  });

  final LText name;
  final String email;
  final String code;
  final String nationalId;
  final LText department;
  final LText level;
  final LText enrollmentStatus;
  final String admissionYear;
  final LText nationality;
  final String birthDate;
  final LText previousQualification;
  final LText faculty;

  String get maskedNationalId {
    return '${nationalId.substring(0, 3)}********${nationalId.substring(11)}';
  }
}

class SubjectItem {
  const SubjectItem({
    required this.id,
    required this.name,
    required this.code,
    required this.doctor,
    required this.assistant,
    required this.description,
    required this.room,
    required this.color,
    required this.progress,
    required this.creditHours,
  });

  final String id;
  final LText name;
  final String code;
  final LText doctor;
  final LText assistant;
  final LText description;
  final String room;
  final Color color;
  final double progress;
  final int creditHours;
}

class LectureItem {
  const LectureItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.duration,
    required this.videoTitle,
    required this.pdfName,
  });

  final String id;
  final String subjectId;
  final LText title;
  final LText description;
  final LText dateLabel;
  final LText duration;
  final LText videoTitle;
  final String pdfName;
}

class SectionItem {
  const SectionItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.assistant,
    required this.location,
    required this.dateLabel,
    required this.material,
  });

  final String id;
  final String subjectId;
  final LText title;
  final LText assistant;
  final LText location;
  final LText dateLabel;
  final String material;
}

class QuizQuestion {
  const QuizQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  final LText text;
  final List<LText> options;
  final int correctIndex;
}

class QuizItem {
  QuizItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.doctor,
    required this.startLabel,
    required this.durationMinutes,
    required this.isOnline,
    required this.status,
    required this.questions,
    required this.instructions,
    this.score,
    this.submitted = false,
  });

  final String id;
  final String subjectId;
  final LText title;
  final LText doctor;
  final LText startLabel;
  final int durationMinutes;
  final bool isOnline;
  QuizStatus status;
  final List<QuizQuestion> questions;
  final List<LText> instructions;
  int? score;
  bool submitted;

  bool get canEnter => status == QuizStatus.available && !submitted;
}

class TaskItem {
  TaskItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.dueLabel,
    required this.status,
    this.uploadedFile,
    this.grade,
  });

  final String id;
  final String subjectId;
  final LText title;
  final LText description;
  final LText dueLabel;
  TaskStatus status;
  String? uploadedFile;
  String? grade;
}

class SummaryItem {
  SummaryItem({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.author,
    required this.createdLabel,
    required this.likes,
    this.videoUrl,
    this.attachmentName,
  });

  final String id;
  final String subjectId;
  final LText title;
  final LText author;
  final LText createdLabel;
  final String? videoUrl;
  final String? attachmentName;
  int likes;
}

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdLabel,
    required this.type,
    required this.isImportant,
    required this.isRead,
    required this.target,
    this.subjectId,
    this.targetId,
  });

  final String id;
  final LText title;
  final LText body;
  final LText createdLabel;
  final NotificationType type;
  final bool isImportant;
  bool isRead;
  final NotificationTarget target;
  final String? subjectId;
  final String? targetId;
}

class ResultItem {
  const ResultItem({
    required this.subjectId,
    required this.subject,
    required this.total,
    required this.grade,
    required this.status,
    required this.notes,
  });

  final String subjectId;
  final LText subject;
  final int total;
  final String grade;
  final LText status;
  final LText notes;
}

class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.subjectId,
    required this.lectureId,
    required this.day,
    required this.time,
    required this.type,
    required this.location,
  });

  final String id;
  final String subjectId;
  final String lectureId;
  final LText day;
  final String time;
  final LText type;
  final LText location;
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.subjectId,
    required this.author,
    required this.content,
    required this.timeLabel,
    required this.isMine,
  });

  final String id;
  final String subjectId;
  final LText author;
  final LText content;
  final LText timeLabel;
  final bool isMine;
}

class CommunityComment {
  CommunityComment({
    required this.id,
    required this.author,
    required this.body,
    required this.createdLabel,
  });

  final String id;
  final LText author;
  final LText body;
  final LText createdLabel;
}

class CommunityPost {
  CommunityPost({
    required this.id,
    required this.subjectId,
    required this.author,
    required this.role,
    required this.body,
    required this.createdLabel,
    required this.reactions,
    required this.comments,
    this.attachmentName,
    this.isPinned = false,
  });

  final String id;
  final String subjectId;
  final LText author;
  final LText role;
  final LText body;
  final LText createdLabel;
  int reactions;
  final List<CommunityComment> comments;
  final String? attachmentName;
  final bool isPinned;
}

class MockStudentData {
  final profile = const StudentProfile(
    name: LText('مريم حسن عبد الله', 'Mariam Hassan Abdallah'),
    email: 'mariam.hassan@tolab.edu.eg',
    code: '20241182',
    nationalId: '12345678901234',
    department: LText('علوم الحاسب', 'Computer Science'),
    level: LText('الفرقة الرابعة', 'Level 4'),
    enrollmentStatus: LText('مقيدة ومنتظمة', 'Active student'),
    admissionYear: '2022',
    nationality: LText('مصرية', 'Egyptian'),
    birthDate: '2004-09-18',
    previousQualification: LText(
      'الثانوية العامة - علمي رياضة',
      'General Secondary Certificate - Math',
    ),
    faculty: LText('كلية الحاسبات والمعلومات', 'Faculty of Computers and AI'),
  );

  late final List<SubjectItem> subjects = [
    const SubjectItem(
      id: 'mobile',
      name: LText('تطوير تطبيقات الهاتف المتقدمة', 'Advanced Mobile Apps'),
      code: 'CS401',
      doctor: LText('د. عمر نبيل', 'Dr. Omar Nabil'),
      assistant: LText('م. نورا سامح', 'TA Nora Sameh'),
      description: LText(
        'معمارية التطبيقات، الأداء، وتجارب المستخدم على الموبايل.',
        'App architecture, performance, and mobile user experience.',
      ),
      room: 'B204',
      color: Color(0xFF2563EB),
      progress: 0.76,
      creditHours: 3,
    ),
    const SubjectItem(
      id: 'cloud',
      name: LText('الحوسبة السحابية', 'Cloud Computing'),
      code: 'CS409',
      doctor: LText('د. هبة مصطفى', 'Dr. Heba Mostafa'),
      assistant: LText('م. كريم راضي', 'TA Kareem Rady'),
      description: LText(
        'النشر السحابي، الحاويات، الأمن، ومراقبة الخدمات.',
        'Cloud deployment, containers, security, and observability.',
      ),
      room: 'Lab 2',
      color: Color(0xFF0F766E),
      progress: 0.58,
      creditHours: 3,
    ),
    const SubjectItem(
      id: 'hci',
      name: LText('التفاعل بين الإنسان والحاسوب', 'Human Computer Interaction'),
      code: 'IS330',
      doctor: LText('د. نورهان فوزي', 'Dr. Nourhan Fawzy'),
      assistant: LText('م. منة طارق', 'TA Menna Tarek'),
      description: LText(
        'تصميم الواجهات، سهولة الاستخدام، والاختبارات البحثية.',
        'Interface design, usability, and research evaluation.',
      ),
      room: 'B201',
      color: Color(0xFF7C3AED),
      progress: 0.84,
      creditHours: 2,
    ),
    const SubjectItem(
      id: 'ai',
      name: LText('الذكاء الاصطناعي', 'Artificial Intelligence'),
      code: 'CS350',
      doctor: LText('د. ياسر عادل', 'Dr. Yasser Adel'),
      assistant: LText('م. سارة كمال', 'TA Sara Kamal'),
      description: LText(
        'البحث، الاستدلال، التعلم الآلي، وتطبيقات النماذج الذكية.',
        'Search, reasoning, machine learning, and intelligent models.',
      ),
      room: 'A105',
      color: Color(0xFFB45309),
      progress: 0.43,
      creditHours: 3,
    ),
    const SubjectItem(
      id: 'security',
      name: LText('أمن المعلومات', 'Information Security'),
      code: 'CS420',
      doctor: LText('د. أحمد فاروق', 'Dr. Ahmed Farouk'),
      assistant: LText('م. ليلى هشام', 'TA Laila Hesham'),
      description: LText(
        'التشفير، أمن الشبكات، إدارة الهوية، ومراجعة المخاطر.',
        'Cryptography, network security, identity, and risk review.',
      ),
      room: 'C301',
      color: Color(0xFFDC2626),
      progress: 0.67,
      creditHours: 3,
    ),
  ];

  late final List<LectureItem> lectures = [
    for (final subject in subjects) ...[
      LectureItem(
        id: '${subject.id}-lecture-1',
        subjectId: subject.id,
        title: LText(
          'المحاضرة 1 - مقدمة ${subject.name.ar}',
          'Lecture 1 - ${subject.name.en} Overview',
        ),
        description: LText(
          'تسجيل تمهيدي مع شرائح PDF ونقاط مراجعة قبل السكشن.',
          'Intro recording with PDF slides and section review notes.',
        ),
        dateLabel: const LText('الأحد 10:00 ص', 'Sunday 10:00 AM'),
        duration: const LText('75 دقيقة', '75 min'),
        videoTitle: const LText('فيديو الشرح الكامل', 'Full lecture video'),
        pdfName: '${subject.code.toLowerCase()}-week-1.pdf',
      ),
      LectureItem(
        id: '${subject.id}-lecture-2',
        subjectId: subject.id,
        title: LText('المحاضرة 2 - دراسة حالة', 'Lecture 2 - Case Study'),
        description: LText(
          'شرح عملي مع أسئلة قصيرة قابلة للمراجعة.',
          'Hands-on walkthrough with short review questions.',
        ),
        dateLabel: const LText('الثلاثاء 12:00 م', 'Tuesday 12:00 PM'),
        duration: const LText('90 دقيقة', '90 min'),
        videoTitle: const LText('فيديو الحالة العملية', 'Case study video'),
        pdfName: '${subject.code.toLowerCase()}-case-study.pdf',
      ),
      LectureItem(
        id: '${subject.id}-lecture-3',
        subjectId: subject.id,
        title: const LText(
          'المحاضرة 3 - تطبيق معملي',
          'Lecture 3 - Lab Application',
        ),
        description: const LText(
          'شرح متدرج مع ملف PDF يحتوي على checklist للتطبيق.',
          'Step-by-step explanation with a PDF checklist.',
        ),
        dateLabel: const LText('الخميس 9:00 ص', 'Thursday 9:00 AM'),
        duration: const LText('60 دقيقة', '60 min'),
        videoTitle: const LText('فيديو التطبيق', 'Application video'),
        pdfName: '${subject.code.toLowerCase()}-lab-checklist.pdf',
      ),
    ],
  ];

  late final List<SectionItem> sections = [
    for (final subject in subjects) ...[
      SectionItem(
        id: '${subject.id}-section-1',
        subjectId: subject.id,
        title: const LText('سكشن مراجعة وتطبيق', 'Review and Practice Section'),
        assistant: subject.assistant,
        location: LText(subject.room, subject.room),
        dateLabel: const LText('الإثنين 11:00 ص', 'Monday 11:00 AM'),
        material: '${subject.code.toLowerCase()}-section-worksheet.pdf',
      ),
      SectionItem(
        id: '${subject.id}-section-2',
        subjectId: subject.id,
        title: const LText('سكشن حل مسائل', 'Problem Solving Section'),
        assistant: subject.assistant,
        location: const LText('معمل 3', 'Lab 3'),
        dateLabel: const LText('الأربعاء 1:00 م', 'Wednesday 1:00 PM'),
        material: '${subject.code.toLowerCase()}-practice.pdf',
      ),
    ],
  ];

  late final List<QuizItem> quizzes = [
    QuizItem(
      id: 'quiz-mobile-1',
      subjectId: 'mobile',
      title: const LText('كويز Async Flows', 'Async Flows Quiz'),
      doctor: const LText('د. عمر نبيل', 'Dr. Omar Nabil'),
      startLabel: const LText('اليوم 8:00 م', 'Today 8:00 PM'),
      durationMinutes: 20,
      isOnline: true,
      status: QuizStatus.available,
      questions: _sampleQuestions('mobile'),
      instructions: _onlineInstructions,
    ),
    QuizItem(
      id: 'quiz-cloud-1',
      subjectId: 'cloud',
      title: const LText('كويز Cloud Security', 'Cloud Security Quiz'),
      doctor: const LText('د. هبة مصطفى', 'Dr. Heba Mostafa'),
      startLabel: const LText('غدا 10:00 ص', 'Tomorrow 10:00 AM'),
      durationMinutes: 45,
      isOnline: false,
      status: QuizStatus.upcoming,
      questions: _sampleQuestions('cloud'),
      instructions: _offlineInstructions,
    ),
    QuizItem(
      id: 'quiz-hci-1',
      subjectId: 'hci',
      title: const LText('كويز Usability Metrics', 'Usability Metrics Quiz'),
      doctor: const LText('د. نورهان فوزي', 'Dr. Nourhan Fawzy'),
      startLabel: const LText('أمس 2:00 م', 'Yesterday 2:00 PM'),
      durationMinutes: 30,
      isOnline: true,
      status: QuizStatus.completed,
      questions: _sampleQuestions('hci'),
      instructions: _onlineInstructions,
      score: 4,
      submitted: true,
    ),
    QuizItem(
      id: 'quiz-ai-1',
      subjectId: 'ai',
      title: const LText('كويز Search Algorithms', 'Search Algorithms Quiz'),
      doctor: const LText('د. ياسر عادل', 'Dr. Yasser Adel'),
      startLabel: const LText('الأحد القادم 11:00 ص', 'Next Sunday 11:00 AM'),
      durationMinutes: 25,
      isOnline: true,
      status: QuizStatus.upcoming,
      questions: _sampleQuestions('ai'),
      instructions: _onlineInstructions,
    ),
    QuizItem(
      id: 'quiz-security-1',
      subjectId: 'security',
      title: const LText(
        'كويز Cryptography Basics',
        'Cryptography Basics Quiz',
      ),
      doctor: const LText('د. أحمد فاروق', 'Dr. Ahmed Farouk'),
      startLabel: const LText('منذ 3 أيام', '3 days ago'),
      durationMinutes: 20,
      isOnline: true,
      status: QuizStatus.expired,
      questions: _sampleQuestions('security'),
      instructions: _onlineInstructions,
    ),
  ];

  late final List<TaskItem> tasks = [
    for (final subject in subjects)
      TaskItem(
        id: '${subject.id}-task-1',
        subjectId: subject.id,
        title: LText(
          'مهمة ${subject.code} الأسبوعية',
          '${subject.code} Weekly Task',
        ),
        description: const LText(
          'ارفع ملف PDF يحتوي الحل والخطوات أو ملاحظات التجربة.',
          'Upload one PDF with the solution, steps, or experiment notes.',
        ),
        dueLabel: const LText(
          'آخر موعد: الخميس 11:59 م',
          'Due: Thursday 11:59 PM',
        ),
        status: subject.id == 'hci' ? TaskStatus.graded : TaskStatus.pending,
        uploadedFile: subject.id == 'hci' ? 'hci-evaluation.pdf' : null,
        grade: subject.id == 'hci' ? '9 / 10' : null,
      ),
  ];

  late final List<SummaryItem> summaries = [
    SummaryItem(
      id: 'summary-1',
      subjectId: 'mobile',
      title: const LText(
        'ملخص Riverpod و State Flow',
        'Riverpod and State Flow Summary',
      ),
      author: profile.name,
      createdLabel: const LText('اليوم', 'Today'),
      videoUrl: 'https://tolab.mock/videos/riverpod',
      attachmentName: 'riverpod-notes.pdf',
      likes: 18,
    ),
    SummaryItem(
      id: 'summary-2',
      subjectId: 'cloud',
      title: const LText(
        'مصطلحات Kubernetes المهمة',
        'Essential Kubernetes Terms',
      ),
      author: const LText('علي سمير', 'Ali Samir'),
      createdLabel: const LText('أمس', 'Yesterday'),
      attachmentName: 'k8s-glossary.pdf',
      likes: 11,
    ),
    SummaryItem(
      id: 'summary-3',
      subjectId: 'security',
      title: const LText('خريطة مراجعة التشفير', 'Cryptography Revision Map'),
      author: const LText('ندى خالد', 'Nada Khaled'),
      createdLabel: const LText('منذ يومين', '2 days ago'),
      attachmentName: 'crypto-map.pdf',
      likes: 24,
    ),
  ];

  late final List<NotificationItem> notifications = [
    NotificationItem(
      id: 'notification-1',
      title: const LText(
        'إعلان هام من الكلية',
        'Important college announcement',
      ),
      body: const LText(
        'تم فتح باب تسجيل الرغبات للمواد الاختيارية حتى الخميس القادم.',
        'Elective course registration is open until next Thursday.',
      ),
      createdLabel: const LText('منذ 15 دقيقة', '15 min ago'),
      type: NotificationType.college,
      isImportant: true,
      isRead: false,
      target: NotificationTarget.none,
    ),
    NotificationItem(
      id: 'notification-2',
      title: const LText('كويز متاح الآن', 'Quiz available now'),
      body: const LText(
        'كويز Async Flows متاح لطلاب مادة تطوير تطبيقات الهاتف.',
        'Async Flows Quiz is available for Advanced Mobile Apps students.',
      ),
      createdLabel: const LText('منذ 30 دقيقة', '30 min ago'),
      type: NotificationType.subject,
      isImportant: true,
      isRead: false,
      target: NotificationTarget.quiz,
      subjectId: 'mobile',
      targetId: 'quiz-mobile-1',
    ),
    NotificationItem(
      id: 'notification-3',
      title: const LText('تذكير بالجدول', 'Schedule reminder'),
      body: const LText(
        'لديك محاضرة Cloud Computing غدا في معمل 2.',
        'You have Cloud Computing tomorrow in Lab 2.',
      ),
      createdLabel: const LText('اليوم', 'Today'),
      type: NotificationType.personal,
      isImportant: false,
      isRead: false,
      target: NotificationTarget.schedule,
      subjectId: 'cloud',
    ),
    NotificationItem(
      id: 'notification-4',
      title: const LText('تم تحديث النتائج', 'Results updated'),
      body: const LText(
        'نتائج Human Computer Interaction متاحة الآن.',
        'Human Computer Interaction results are now available.',
      ),
      createdLabel: const LText('أمس', 'Yesterday'),
      type: NotificationType.personal,
      isImportant: false,
      isRead: true,
      target: NotificationTarget.results,
    ),
    NotificationItem(
      id: 'notification-5',
      title: const LText(
        'تنبيه مهمة أمن المعلومات',
        'Information Security task alert',
      ),
      body: const LText(
        'تسليم مهمة Cryptography Basics يغلق الخميس.',
        'Cryptography Basics task closes on Thursday.',
      ),
      createdLabel: const LText('منذ يومين', '2 days ago'),
      type: NotificationType.subject,
      isImportant: true,
      isRead: true,
      target: NotificationTarget.task,
      subjectId: 'security',
      targetId: 'security-task-1',
    ),
  ];

  late final List<ResultItem> results = [
    const ResultItem(
      subjectId: 'mobile',
      subject: LText('تطوير تطبيقات الهاتف المتقدمة', 'Advanced Mobile Apps'),
      total: 91,
      grade: 'A',
      status: LText('ناجح', 'Passed'),
      notes: LText(
        'أداء قوي في المشروع العملي.',
        'Strong performance in the practical project.',
      ),
    ),
    const ResultItem(
      subjectId: 'cloud',
      subject: LText('الحوسبة السحابية', 'Cloud Computing'),
      total: 78,
      grade: 'B',
      status: LText('ناجح', 'Passed'),
      notes: LText(
        'ينصح بمراجعة الأمن السحابي.',
        'Review cloud security topics.',
      ),
    ),
    const ResultItem(
      subjectId: 'hci',
      subject: LText(
        'التفاعل بين الإنسان والحاسوب',
        'Human Computer Interaction',
      ),
      total: 94,
      grade: 'A+',
      status: LText('ناجح بتفوق', 'Excellent pass'),
      notes: LText(
        'تحليل ممتاز لتجربة المستخدم.',
        'Excellent UX evaluation work.',
      ),
    ),
  ];

  late final List<ScheduleItem> schedule = [
    const ScheduleItem(
      id: 'schedule-1',
      subjectId: 'mobile',
      lectureId: 'mobile-lecture-1',
      day: LText('الأحد', 'Sunday'),
      time: '10:00 - 11:30',
      type: LText('محاضرة', 'Lecture'),
      location: LText('B204', 'B204'),
    ),
    const ScheduleItem(
      id: 'schedule-2',
      subjectId: 'cloud',
      lectureId: 'cloud-lecture-1',
      day: LText('الإثنين', 'Monday'),
      time: '09:00 - 10:30',
      type: LText('معمل', 'Lab'),
      location: LText('Lab 2', 'Lab 2'),
    ),
    const ScheduleItem(
      id: 'schedule-3',
      subjectId: 'hci',
      lectureId: 'hci-lecture-1',
      day: LText('الثلاثاء', 'Tuesday'),
      time: '12:00 - 13:30',
      type: LText('محاضرة', 'Lecture'),
      location: LText('B201', 'B201'),
    ),
    const ScheduleItem(
      id: 'schedule-4',
      subjectId: 'ai',
      lectureId: 'ai-lecture-1',
      day: LText('الأربعاء', 'Wednesday'),
      time: '11:00 - 12:30',
      type: LText('محاضرة', 'Lecture'),
      location: LText('A105', 'A105'),
    ),
    const ScheduleItem(
      id: 'schedule-5',
      subjectId: 'security',
      lectureId: 'security-lecture-1',
      day: LText('الخميس', 'Thursday'),
      time: '13:00 - 14:30',
      type: LText('سكشن', 'Section'),
      location: LText('C301', 'C301'),
    ),
  ];

  late final List<ChatMessage> chatMessages = [
    ChatMessage(
      id: 'chat-1',
      subjectId: 'mobile',
      author: const LText('نور', 'Nour'),
      content: const LText(
        'هل حد بدأ في Assignment المعمارية؟',
        'Has anyone started the architecture assignment?',
      ),
      timeLabel: const LText('10:18 ص', '10:18 AM'),
      isMine: false,
    ),
    ChatMessage(
      id: 'chat-2',
      subjectId: 'mobile',
      author: profile.name,
      content: const LText(
        'أيوه، هرفع ملخص صغير بعد المحاضرة.',
        'Yes, I will share a short summary after the lecture.',
      ),
      timeLabel: const LText('10:20 ص', '10:20 AM'),
      isMine: true,
    ),
    ChatMessage(
      id: 'chat-3',
      subjectId: 'cloud',
      author: const LText('كريم', 'Kareem'),
      content: const LText(
        'كويز الأمن حضوري وليس أونلاين.',
        'The security quiz is offline, not online.',
      ),
      timeLabel: const LText('8:42 ص', '8:42 AM'),
      isMine: false,
    ),
    ChatMessage(
      id: 'chat-4',
      subjectId: 'security',
      author: const LText('ليلى', 'Laila'),
      content: const LText(
        'متنسوش جدول التشفير في ملف PDF.',
        'Do not forget the cryptography table in the PDF.',
      ),
      timeLabel: const LText('12:04 م', '12:04 PM'),
      isMine: false,
    ),
  ];

  late final List<CommunityPost> posts = [
    CommunityPost(
      id: 'post-1',
      subjectId: 'mobile',
      author: const LText('د. عمر نبيل', 'Dr. Omar Nabil'),
      role: const LText('دكتور المادة', 'Course instructor'),
      body: const LText(
        'راجعوا تسجيل Clean Architecture قبل محاضرة الأحد، سيتم حل Case Study مباشرة.',
        'Review the Clean Architecture recording before Sunday. We will solve a live case study.',
      ),
      createdLabel: const LText('منذ ساعتين', '2 hours ago'),
      reactions: 18,
      attachmentName: 'clean-architecture-case.pdf',
      isPinned: true,
      comments: [
        CommunityComment(
          id: 'comment-1',
          author: profile.name,
          body: const LText(
            'هل الجزء العملي داخل الكويز؟',
            'Is the practical part included in the quiz?',
          ),
          createdLabel: const LText('منذ ساعة', '1 hour ago'),
        ),
      ],
    ),
    CommunityPost(
      id: 'post-2',
      subjectId: 'cloud',
      author: const LText('م. كريم راضي', 'TA Kareem Rady'),
      role: const LText('معيد', 'Teaching assistant'),
      body: const LText(
        'تم رفع ملاحظات autoscaling و scheduling داخل ملفات المادة.',
        'Autoscaling and scheduling notes were added to course files.',
      ),
      createdLabel: const LText('أمس', 'Yesterday'),
      reactions: 11,
      comments: [],
    ),
    CommunityPost(
      id: 'post-3',
      subjectId: 'hci',
      author: const LText('د. نورهان فوزي', 'Dr. Nourhan Fawzy'),
      role: const LText('دكتور المادة', 'Course instructor'),
      body: const LText(
        'Rubric المشروع الصغير متاح الآن، الأولوية لاختبار الوصول على الموبايل.',
        'The mini-project rubric is now available. Prioritize mobile accessibility testing.',
      ),
      createdLabel: const LText('منذ 5 ساعات', '5 hours ago'),
      reactions: 26,
      attachmentName: 'hci-mini-project-rubric.pdf',
      isPinned: true,
      comments: [],
    ),
  ];

  static const _onlineInstructions = [
    LText(
      'تأكد من ثبات الاتصال قبل البدء.',
      'Make sure your connection is stable before starting.',
    ),
    LText(
      'زر التسليم يظهر قبل نهاية العداد.',
      'Submit before the timer reaches zero.',
    ),
    LText(
      'لا تغلق الشاشة أثناء حل الكويز.',
      'Do not close the screen during the attempt.',
    ),
  ];

  static const _offlineInstructions = [
    LText(
      'أحضر البطاقة الجامعية قبل بداية الكويز.',
      'Bring your student ID before the quiz starts.',
    ),
    LText(
      'الحضور قبل الموعد بربع ساعة.',
      'Arrive 15 minutes before the start time.',
    ),
  ];

  static List<QuizQuestion> _sampleQuestions(String subjectId) {
    return [
      const QuizQuestion(
        text: LText(
          'ما الهدف من فصل طبقة العرض عن منطق الأعمال؟',
          'Why separate UI from business logic?',
        ),
        options: [
          LText('سهولة الاختبار والصيانة', 'Easier testing and maintenance'),
          LText('زيادة حجم التطبيق فقط', 'Only increasing app size'),
          LText('إلغاء الحاجة للبيانات', 'Removing data needs'),
          LText('تعطيل التحديثات', 'Blocking updates'),
        ],
        correctIndex: 0,
      ),
      QuizQuestion(
        text: LText(
          'أي اختيار يناسب ${subjectId.toUpperCase()} أكثر؟',
          'Which option best fits ${subjectId.toUpperCase()}?',
        ),
        options: const [
          LText(
            'تجزئة المشكلة إلى خطوات واضحة',
            'Break the problem into clear steps',
          ),
          LText('تجاهل القيود', 'Ignore constraints'),
          LText('تكرار الكود بدون سبب', 'Duplicate code without reason'),
          LText('إخفاء الأخطاء', 'Hide errors'),
        ],
        correctIndex: 0,
      ),
      const QuizQuestion(
        text: LText(
          'ما أفضل تصرف عند ظهور خطأ للمستخدم؟',
          'What is best when showing an error to the user?',
        ),
        options: [
          LText('رسالة واضحة وإجراء مقترح', 'Clear message and next action'),
          LText('إغلاق التطبيق', 'Close the app'),
          LText('ترك الشاشة فارغة', 'Leave a blank screen'),
          LText('إظهار Stack Trace فقط', 'Show only a stack trace'),
        ],
        correctIndex: 0,
      ),
      const QuizQuestion(
        text: LText(
          'ما معنى تجربة أكاديمية جيدة؟',
          'What makes a good academic experience?',
        ),
        options: [
          LText(
            'وضوح المواعيد والمواد والتقييمات',
            'Clear schedules, subjects, and assessments',
          ),
          LText('إخفاء الإعلانات المهمة', 'Hide important announcements'),
          LText('منع الوصول للملفات', 'Block files'),
          LText('كثرة الخطوات غير الضرورية', 'Too many unnecessary steps'),
        ],
        correctIndex: 0,
      ),
    ];
  }

  bool isRegistered(String subjectId) {
    return subjects.any((subject) => subject.id == subjectId);
  }

  SubjectItem subjectById(String id) =>
      subjects.firstWhere((subject) => subject.id == id);

  LectureItem lectureById(String id) =>
      lectures.firstWhere((lecture) => lecture.id == id);

  QuizItem quizById(String id) => quizzes.firstWhere((quiz) => quiz.id == id);

  SummaryItem summaryById(String id) =>
      summaries.firstWhere((summary) => summary.id == id);

  CommunityPost postById(String id) =>
      posts.firstWhere((post) => post.id == id);

  NotificationItem notificationById(String id) =>
      notifications.firstWhere((notification) => notification.id == id);

  List<LectureItem> lecturesFor(String subjectId) =>
      lectures.where((lecture) => lecture.subjectId == subjectId).toList();

  List<SectionItem> sectionsFor(String subjectId) =>
      sections.where((section) => section.subjectId == subjectId).toList();

  List<QuizItem> quizzesFor(String subjectId) =>
      quizzes.where((quiz) => quiz.subjectId == subjectId).toList();

  List<TaskItem> tasksFor(String subjectId) =>
      tasks.where((task) => task.subjectId == subjectId).toList();

  List<SummaryItem> summariesFor(String subjectId) =>
      summaries.where((summary) => summary.subjectId == subjectId).toList();

  List<CommunityPost> postsFor(String subjectId) =>
      posts.where((post) => post.subjectId == subjectId).toList();

  List<ChatMessage> messagesFor(String subjectId) =>
      chatMessages.where((message) => message.subjectId == subjectId).toList();
}

class SplashPrototypePage extends StatelessWidget {
  const SplashPrototypePage({
    super.key,
    required this.isArabic,
    required this.onContinue,
    required this.onToggleLanguage,
  });

  final bool isArabic;
  final VoidCallback onContinue;
  final VoidCallback onToggleLanguage;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFF6F8FB)),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0, constraints.maxHeight - 48),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: isArabic
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: IconButton.filledTonal(
                              tooltip: t('تغيير اللغة', 'Change language'),
                              onPressed: onToggleLanguage,
                              icon: const Icon(Icons.language_rounded),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2563EB,
                                    ).withValues(alpha: 0.22),
                                    blurRadius: 28,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tolab',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF10233F),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t(
                              'منصة أكاديمية للطالب الجامعي',
                              'Academic student platform',
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: const Color(0xFF516070)),
                          ),
                          const SizedBox(height: 36),
                          _StateNoticeCard(
                            icon: Icons.verified_user_rounded,
                            title: t(
                              'دخول آمن بحساب Microsoft',
                              'Secure Microsoft access',
                            ),
                            body: t(
                              'لا يوجد تسجيل عادي أو إعادة تعيين كلمة مرور داخل التطبيق.',
                              'No local signup or in-app password reset.',
                            ),
                          ),
                          const SizedBox(height: 18),
                          _StateNoticeCard(
                            icon: Icons.badge_rounded,
                            title: t(
                              'ربط مرة واحدة بالرقم القومي',
                              'One-time National ID linking',
                            ),
                            body: t(
                              'بعد أول دخول فقط يتم ربط حساب Microsoft ببيانات الطالب الرسمية.',
                              'After the first sign-in only, Microsoft is linked to the official student record.',
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton.icon(
                            onPressed: onContinue,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(t('ابدأ التجربة', 'Start prototype')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MicrosoftLoginPrototypePage extends StatelessWidget {
  const MicrosoftLoginPrototypePage({
    super.key,
    required this.isArabic,
    required this.isBusy,
    required this.onMicrosoftLogin,
    required this.onToggleLanguage,
  });

  final bool isArabic;
  final bool isBusy;
  final VoidCallback onMicrosoftLogin;
  final VoidCallback onToggleLanguage;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 56 : 20,
                vertical: 28,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0, constraints.maxHeight - 56),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isDesktop
                        ? Row(
                            children: [
                              Expanded(
                                child: _LoginHeroPanel(isArabic: isArabic),
                              ),
                              const SizedBox(width: 36),
                              SizedBox(
                                width: 440,
                                child: _MicrosoftLoginCard(
                                  isArabic: isArabic,
                                  isBusy: isBusy,
                                  onMicrosoftLogin: onMicrosoftLogin,
                                  onToggleLanguage: onToggleLanguage,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LoginHeroPanel(
                                isArabic: isArabic,
                                compact: true,
                              ),
                              const SizedBox(height: 20),
                              _MicrosoftLoginCard(
                                isArabic: isArabic,
                                isBusy: isBusy,
                                onMicrosoftLogin: onMicrosoftLogin,
                                onToggleLanguage: onToggleLanguage,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginHeroPanel extends StatelessWidget {
  const _LoginHeroPanel({required this.isArabic, this.compact = false});

  final bool isArabic;
  final bool compact;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tolab',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(t('بوابة الطالب', 'Student portal')),
                  ],
                ),
              ],
            ),
            SizedBox(height: compact ? 20 : 48),
            Text(
              t(
                'كل ما يحتاجه الطالب في منصة واحدة',
                'Everything a student needs in one platform',
              ),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            Text(
              t(
                'موادك، محاضراتك، جدولك، الإعلانات الرسمية، مجتمع كل مادة، وشات المجموعة في تجربة Responsive واحدة.',
                'Subjects, lectures, schedule, official announcements, subject communities, and group chats in one responsive experience.',
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF516070),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SoftMetric(label: t('مواد مسجلة', 'Registered'), value: '5'),
                _SoftMetric(
                  label: t('إعلانات غير مقروءة', 'Unread'),
                  value: '3',
                ),
                _SoftMetric(
                  label: t('كويز متاح', 'Available quiz'),
                  value: '1',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MicrosoftLoginCard extends StatelessWidget {
  const _MicrosoftLoginCard({
    required this.isArabic,
    required this.isBusy,
    required this.onMicrosoftLogin,
    required this.onToggleLanguage,
  });

  final bool isArabic;
  final bool isBusy;
  final VoidCallback onMicrosoftLogin;
  final VoidCallback onToggleLanguage;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: isArabic
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: IconButton.filledTonal(
                tooltip: t('تغيير اللغة', 'Change language'),
                onPressed: onToggleLanguage,
                icon: const Icon(Icons.language_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t('تسجيل الدخول', 'Sign in'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'الدخول متاح بحساب Microsoft الجامعي فقط. كلمة المرور لا يتم تخزينها داخل Tolab.',
                'Use your university Microsoft account only. Tolab never stores the Microsoft password.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667085),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onMicrosoftLogin,
              icon: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.window_rounded),
              label: Text(
                isBusy
                    ? t(
                        'جاري الاتصال بمايكروسوفت...',
                        'Connecting to Microsoft...',
                      )
                    : t('المتابعة بحساب Microsoft', 'Continue with Microsoft'),
              ),
            ),
            const SizedBox(height: 16),
            _InlineRule(
              icon: Icons.no_accounts_rounded,
              text: t('لا يوجد تسجيل عادي', 'No local signup'),
            ),
            _InlineRule(
              icon: Icons.lock_reset_rounded,
              text: t(
                'لا يوجد Reset Password داخل التطبيق',
                'No in-app password reset',
              ),
            ),
            _InlineRule(
              icon: Icons.password_rounded,
              text: t(
                'كلمة المرور تابعة لمايكروسوفت فقط',
                'Password stays with Microsoft only',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NationalIdVerificationPrototypePage extends StatefulWidget {
  const NationalIdVerificationPrototypePage({
    super.key,
    required this.isArabic,
    required this.isBusy,
    required this.profile,
    required this.onVerify,
    required this.onBack,
  });

  final bool isArabic;
  final bool isBusy;
  final StudentProfile profile;
  final ValueChanged<String> onVerify;
  final VoidCallback onBack;

  @override
  State<NationalIdVerificationPrototypePage> createState() =>
      _NationalIdVerificationPrototypePageState();
}

class _NationalIdVerificationPrototypePageState
    extends State<NationalIdVerificationPrototypePage> {
  final _controller = TextEditingController(text: '12345678901234');

  String t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: t('رجوع', 'Back'),
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t(
                                'التحقق بالرقم القومي',
                                'National ID verification',
                              ),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t(
                          'هذه الخطوة تظهر مرة واحدة فقط بعد أول تسجيل دخول لربط حساب Microsoft ببيانات الطالب الرسمية.',
                          'This appears once after the first Microsoft sign-in to link your official student record.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF667085),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        maxLength: 14,
                        decoration: InputDecoration(
                          labelText: t('الرقم القومي', 'National ID'),
                          prefixIcon: const Icon(Icons.badge_outlined),
                          helperText: t(
                            'للتجربة استخدم 12345678901234',
                            'For the mock use 12345678901234',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _StateNoticeCard(
                        icon: Icons.privacy_tip_rounded,
                        title: t('قاعدة العمل', 'Business rule'),
                        body: t(
                          'لا يدخل الطالب البيانات أو المواد قبل نجاح هذا التحقق.',
                          'The student cannot access data or subjects before verification succeeds.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: widget.isBusy
                            ? null
                            : () => widget.onVerify(_controller.text),
                        icon: widget.isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.verified_rounded),
                        label: Text(
                          widget.isBusy
                              ? t('جاري التحقق...', 'Verifying...')
                              : t('ربط الحساب', 'Link account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.isArabic,
    required this.selectedTab,
    required this.unreadCount,
    required this.onSelect,
  });

  final bool isArabic;
  final RootTab selectedTab;
  final int unreadCount;
  final ValueChanged<RootTab> onSelect;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final labels = [
      t('الرئيسية', 'Home'),
      t('المواد', 'Subjects'),
      t('الجدول', 'Schedule'),
      t('الإشعارات', 'Notifications'),
      t('المزيد', 'More'),
    ];
    final icons = [
      Icons.home_rounded,
      Icons.menu_book_rounded,
      Icons.calendar_month_rounded,
      Icons.notifications_rounded,
      Icons.dashboard_customize_rounded,
    ];

    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE4E8F0))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tolab',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        t('Student App', 'Student App'),
                        style: const TextStyle(color: Color(0xFF667085)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              for (final tab in RootTab.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SidebarDestination(
                    label: labels[tab.index],
                    icon: icons[tab.index],
                    selected: selectedTab == tab,
                    badgeCount: tab == RootTab.notifications ? unreadCount : 0,
                    onTap: () => onSelect(tab),
                  ),
                ),
              const Spacer(),
              _StateNoticeCard(
                icon: Icons.security_rounded,
                title: t('Microsoft Login', 'Microsoft Login'),
                body: t(
                  'لا يتم تخزين كلمة المرور نهائيا.',
                  'Password is never stored.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEAF2FF) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              _BadgeIcon(
                icon: icon,
                count: badgeCount,
                color: selected ? const Color(0xFF2563EB) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? const Color(0xFF1D4ED8) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrototypePageFrame extends StatelessWidget {
  const PrototypePageFrame({
    super.key,
    required this.isArabic,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.onBack,
    this.scrollable = true,
    this.maxWidth = 1180,
  });

  final bool isArabic;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final Widget child;
  final bool scrollable;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Row(
                children: [
                  if (onBack != null) ...[
                    IconButton.filledTonal(
                      tooltip: isArabic ? 'رجوع' : 'Back',
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF667085)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Wrap(spacing: 8, children: actions),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: child,
                      ),
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: child,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.icon, required this.count, this.color});

  final IconData icon;
  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon, color: color);
    if (count <= 0) {
      return child;
    }
    return Badge(label: Text(count > 9 ? '9+' : '$count'), child: child);
  }
}

class _StateNoticeCard extends StatelessWidget {
  const _StateNoticeCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF475467),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineRule extends StatelessWidget {
  const _InlineRule({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0F766E)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _SoftMetric extends StatelessWidget {
  const _SoftMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF667085))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isArabic,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
  });

  final bool isArabic;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, size: 42, color: Color(0xFF94A3B8)),
            const SizedBox(height: 10),
            Text(
              isArabic ? titleAr : titleEn,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              isArabic ? bodyAr : bodyEn,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasis = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: emphasis ? const Color(0xFFEAF2FF) : null,
      side: BorderSide(
        color: emphasis ? const Color(0xFFBFDBFE) : const Color(0xFFE4E8F0),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AdaptiveWrap extends StatelessWidget {
  const _AdaptiveWrap({
    required this.children,
    this.minTileWidth = 260,
    this.spacing = 14,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = math.max(1, width ~/ minTileWidth);
        final itemWidth =
            (width - ((columns - 1) * spacing)) / columns.clamp(1, 4);
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class HomeDashboardPrototypePage extends StatelessWidget {
  const HomeDashboardPrototypePage({
    super.key,
    required this.isArabic,
    required this.data,
    required this.onOpenSubject,
    required this.onOpenSchedule,
    required this.onOpenNotifications,
    required this.onOpenQuiz,
  });

  final bool isArabic;
  final MockStudentData data;
  final ValueChanged<String> onOpenSubject;
  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenNotifications;
  final void Function(String subjectId, String quizId) onOpenQuiz;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final availableQuiz = data.quizzes.firstWhere(
      (quiz) => quiz.status == QuizStatus.available,
      orElse: () => data.quizzes.first,
    );
    final importantNotifications = data.notifications
        .where((item) => item.isImportant)
        .take(3)
        .toList();

    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('الرئيسية', 'Home'),
      subtitle: t(
        'صباح الخير يا ${data.profile.name.ar}',
        'Good morning, ${data.profile.name.en}',
      ),
      actions: [
        IconButton.filledTonal(
          tooltip: t('الإشعارات', 'Notifications'),
          onPressed: onOpenNotifications,
          icon: const Icon(Icons.notifications_rounded),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StudentHeroCard(isArabic: isArabic, profile: data.profile),
          const SizedBox(height: 16),
          _AdaptiveWrap(
            minTileWidth: 220,
            children: [
              _DashboardShortcut(
                icon: Icons.calendar_today_rounded,
                title: t('محاضرات اليوم', 'Today lectures'),
                value: '2',
                color: const Color(0xFF2563EB),
                onTap: onOpenSchedule,
              ),
              _DashboardShortcut(
                icon: Icons.quiz_rounded,
                title: t('كويزات قادمة', 'Upcoming quizzes'),
                value:
                    '${data.quizzes.where((q) => q.status != QuizStatus.completed).length}',
                color: const Color(0xFF0F766E),
                onTap: () =>
                    onOpenQuiz(availableQuiz.subjectId, availableQuiz.id),
              ),
              _DashboardShortcut(
                icon: Icons.campaign_rounded,
                title: t('إعلانات مهمة', 'Important'),
                value: '${importantNotifications.length}',
                color: const Color(0xFFB45309),
                onTap: onOpenNotifications,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionTitle(
            title: t('اختصارات المواد', 'Subject shortcuts'),
            action: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.swipe_rounded),
              label: Text(t('اسحب أو اضغط', 'Tap any card')),
            ),
          ),
          const SizedBox(height: 10),
          _AdaptiveWrap(
            children: [
              for (final subject in data.subjects)
                _SubjectCard(
                  isArabic: isArabic,
                  subject: subject,
                  onTap: () => onOpenSubject(subject.id),
                ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: t('كويز متاح الآن', 'Available quiz')),
          const SizedBox(height: 10),
          _QuizCard(
            isArabic: isArabic,
            quiz: availableQuiz,
            subject: data.subjectById(availableQuiz.subjectId),
            onOpen: () => onOpenQuiz(availableQuiz.subjectId, availableQuiz.id),
            onEnter: () =>
                onOpenQuiz(availableQuiz.subjectId, availableQuiz.id),
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: t('إعلانات مهمة', 'Important announcements')),
          const SizedBox(height: 10),
          for (final item in importantNotifications)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NotificationListCard(
                isArabic: isArabic,
                item: item,
                onTap: onOpenNotifications,
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentHeroCard extends StatelessWidget {
  const _StudentHeroCard({required this.isArabic, required this.profile});

  final bool isArabic;
  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final name = profile.name.of(isArabic);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _Avatar(name: name, radius: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.department.of(isArabic)} • ${profile.level.of(isArabic)}',
                    style: const TextStyle(color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusPill(
                        label: profile.enrollmentStatus.of(isArabic),
                        color: const Color(0xFF0F766E),
                      ),
                      _StatusPill(
                        label: profile.code,
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _DashboardShortcut extends StatelessWidget {
  const _DashboardShortcut({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(color: Color(0xFF667085)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubjectsPrototypePage extends StatefulWidget {
  const SubjectsPrototypePage({
    super.key,
    required this.isArabic,
    required this.subjects,
    required this.onOpenSubject,
  });

  final bool isArabic;
  final List<SubjectItem> subjects;
  final ValueChanged<String> onOpenSubject;

  @override
  State<SubjectsPrototypePage> createState() => _SubjectsPrototypePageState();
}

class _SubjectsPrototypePageState extends State<SubjectsPrototypePage> {
  String _query = '';

  String t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final subjects = widget.subjects.where((subject) {
      final value = '${subject.name.ar} ${subject.name.en} ${subject.code}';
      return value.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return PrototypePageFrame(
      isArabic: widget.isArabic,
      title: t('المواد المسجلة', 'Registered subjects'),
      subtitle: t(
        'الطالب يرى فقط المواد المسجل فيها',
        'Students see only their registered subjects',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: t(
                'ابحث باسم المادة أو الكود',
                'Search by subject name or code',
              ),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 16),
          if (subjects.isEmpty)
            _EmptyState(
              isArabic: widget.isArabic,
              titleAr: 'لا توجد نتائج',
              titleEn: 'No subjects found',
              bodyAr: 'جرّب كلمة بحث مختلفة.',
              bodyEn: 'Try a different search term.',
            )
          else
            _AdaptiveWrap(
              children: [
                for (final subject in subjects)
                  _SubjectCard(
                    isArabic: widget.isArabic,
                    subject: subject,
                    onTap: () => widget.onOpenSubject(subject.id),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.isArabic,
    required this.subject,
    required this.onTap,
  });

  final bool isArabic;
  final SubjectItem subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: subject.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: subject.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.code,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subject.name.of(isArabic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subject.description.of(isArabic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF667085), height: 1.4),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: subject.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                color: subject.color,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(subject.doctor.of(isArabic))),
                  Text('${(subject.progress * 100).round()}%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubjectDetailsPrototypePage extends StatelessWidget {
  const SubjectDetailsPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.lectures,
    required this.sections,
    required this.quizzes,
    required this.tasks,
    required this.summaries,
    required this.posts,
    required this.messages,
    required this.onBack,
    required this.onOpenSection,
    required this.onOpenQuiz,
  });

  final bool isArabic;
  final SubjectItem subject;
  final List<LectureItem> lectures;
  final List<SectionItem> sections;
  final List<QuizItem> quizzes;
  final List<TaskItem> tasks;
  final List<SummaryItem> summaries;
  final List<CommunityPost> posts;
  final List<ChatMessage> messages;
  final VoidCallback onBack;
  final ValueChanged<RouteKind> onOpenSection;
  final ValueChanged<String> onOpenQuiz;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: subject.name.of(isArabic),
      subtitle:
          '${subject.code} • ${subject.doctor.of(isArabic)} • ${subject.creditHours} ${t('ساعات', 'hours')}',
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: subject.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: subject.color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          subject.description.of(isArabic),
                          style: const TextStyle(
                            color: Color(0xFF475467),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusPill(
                        label: '${lectures.length} ${t('محاضرات', 'lectures')}',
                        color: const Color(0xFF2563EB),
                      ),
                      _StatusPill(
                        label: '${sections.length} ${t('سكاشن', 'sections')}',
                        color: const Color(0xFF0F766E),
                      ),
                      _StatusPill(
                        label: '${quizzes.length} ${t('كويزات', 'quizzes')}',
                        color: const Color(0xFFB45309),
                      ),
                      _StatusPill(
                        label:
                            '${messages.length} ${t('رسائل شات', 'chat messages')}',
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: t('تبويبات المادة', 'Subject tabs')),
          const SizedBox(height: 10),
          _AdaptiveWrap(
            minTileWidth: 220,
            children: [
              _SubjectActionTile(
                icon: Icons.play_circle_outline_rounded,
                title: t('المحاضرات', 'Lectures'),
                value: '${lectures.length}',
                onTap: () => onOpenSection(RouteKind.lectures),
              ),
              _SubjectActionTile(
                icon: Icons.science_outlined,
                title: t('السكاشن', 'Sections'),
                value: '${sections.length}',
                onTap: () => onOpenSection(RouteKind.sections),
              ),
              _SubjectActionTile(
                icon: Icons.quiz_outlined,
                title: t('الكويزات', 'Quizzes'),
                value: '${quizzes.length}',
                onTap: () => onOpenSection(RouteKind.quizzes),
              ),
              _SubjectActionTile(
                icon: Icons.task_alt_rounded,
                title: t('المهام', 'Tasks'),
                value: '${tasks.length}',
                onTap: () => onOpenSection(RouteKind.tasks),
              ),
              _SubjectActionTile(
                icon: Icons.summarize_outlined,
                title: t('الملخصات', 'Summaries'),
                value: '${summaries.length}',
                onTap: () => onOpenSection(RouteKind.summaries),
              ),
              _SubjectActionTile(
                icon: Icons.forum_outlined,
                title: t('Community المادة', 'Subject Community'),
                value: '${posts.length}',
                onTap: () => onOpenSection(RouteKind.community),
              ),
              _SubjectActionTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: t('Group Chat', 'Group Chat'),
                value: '${messages.length}',
                onTap: () => onOpenSection(RouteKind.chat),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionTitle(title: t('أقرب كويزات المادة', 'Subject quizzes')),
          const SizedBox(height: 10),
          for (final quiz in quizzes.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _QuizCard(
                isArabic: isArabic,
                quiz: quiz,
                subject: subject,
                onOpen: () => onOpenQuiz(quiz.id),
                onEnter: () => onOpenQuiz(quiz.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubjectActionTile extends StatelessWidget {
  const _SubjectActionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(value, style: const TextStyle(color: Color(0xFF667085))),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class LecturesPrototypePage extends StatelessWidget {
  const LecturesPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.lectures,
    required this.onBack,
    required this.onOpenLecture,
    required this.onOpenPdf,
    required this.onOpenVideo,
  });

  final bool isArabic;
  final SubjectItem subject;
  final List<LectureItem> lectures;
  final VoidCallback onBack;
  final ValueChanged<String> onOpenLecture;
  final ValueChanged<String> onOpenPdf;
  final ValueChanged<String> onOpenVideo;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('المحاضرات', 'Lectures'),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      child: Column(
        children: [
          for (final lecture in lectures)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LectureCard(
                isArabic: isArabic,
                lecture: lecture,
                onTap: () => onOpenLecture(lecture.id),
                onOpenPdf: () => onOpenPdf(lecture.id),
                onOpenVideo: () => onOpenVideo(lecture.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  const _LectureCard({
    required this.isArabic,
    required this.lecture,
    required this.onTap,
    required this.onOpenPdf,
    required this.onOpenVideo,
  });

  final bool isArabic;
  final LectureItem lecture;
  final VoidCallback onTap;
  final VoidCallback onOpenPdf;
  final VoidCallback onOpenVideo;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.play_lesson_rounded,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lecture.title.of(isArabic),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(lecture.duration.of(isArabic)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lecture.description.of(isArabic),
                style: const TextStyle(color: Color(0xFF667085), height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionChipButton(
                    icon: Icons.ondemand_video_rounded,
                    label: t('فتح الفيديو', 'Video'),
                    onTap: onOpenVideo,
                    emphasis: true,
                  ),
                  _ActionChipButton(
                    icon: Icons.picture_as_pdf_rounded,
                    label: t('معاينة PDF', 'Preview PDF'),
                    onTap: onOpenPdf,
                  ),
                  _StatusPill(
                    label: lecture.dateLabel.of(isArabic),
                    color: const Color(0xFF0F766E),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LectureDetailsPrototypePage extends StatelessWidget {
  const LectureDetailsPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.lecture,
    required this.onBack,
    required this.onOpenPdf,
    required this.onOpenVideo,
  });

  final bool isArabic;
  final SubjectItem subject;
  final LectureItem lecture;
  final VoidCallback onBack;
  final VoidCallback onOpenPdf;
  final VoidCallback onOpenVideo;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: lecture.title.of(isArabic),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VideoMockPanel(
            title: lecture.videoTitle.of(isArabic),
            subtitle: lecture.duration.of(isArabic),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lecture.description.of(isArabic),
                    style: const TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: onOpenVideo,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(t('تشغيل الفيديو', 'Play video')),
                      ),
                      OutlinedButton.icon(
                        onPressed: onOpenPdf,
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: Text(t('فتح PDF', 'Open PDF')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PdfPreviewPrototypePage extends StatelessWidget {
  const PdfPreviewPrototypePage({
    super.key,
    required this.isArabic,
    required this.lecture,
    required this.onBack,
  });

  final bool isArabic;
  final LectureItem lecture;
  final VoidCallback onBack;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('معاينة PDF', 'PDF Preview'),
      subtitle: lecture.pdfName,
      onBack: onBack,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                height: 460,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 72,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      lecture.pdfName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t(
                        'صفحة 1 من 12 - معاينة تجريبية',
                        'Page 1 of 12 - mock preview',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: t('السابق', 'Previous'),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: t('التالي', 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerPrototypePage extends StatelessWidget {
  const VideoPlayerPrototypePage({
    super.key,
    required this.isArabic,
    required this.lecture,
    required this.onBack,
  });

  final bool isArabic;
  final LectureItem lecture;
  final VoidCallback onBack;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('مشغل الفيديو', 'Video player'),
      subtitle: lecture.title.of(isArabic),
      onBack: onBack,
      child: Column(
        children: [
          _VideoMockPanel(
            title: lecture.videoTitle.of(isArabic),
            subtitle: t(
              'مشغل تجريبي للفيديو المسجل',
              'Mock recorded video player',
            ),
            large: true,
          ),
          const SizedBox(height: 14),
          _StateNoticeCard(
            icon: Icons.info_rounded,
            title: t('Prototype', 'Prototype'),
            body: t(
              'هذا مشغل وهمي يوضح تجربة فتح الفيديو.',
              'This is a mock player showing the video interaction.',
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoMockPanel extends StatelessWidget {
  const _VideoMockPanel({
    required this.title,
    required this.subtitle,
    this.large = false,
  });

  final String title;
  final String subtitle;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: large ? 16 / 9 : 21 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _VideoGridPainter())),
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 46,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.42,
                    color: const Color(0xFF38BDF8),
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SectionsPrototypePage extends StatelessWidget {
  const SectionsPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.sections,
    required this.onBack,
    required this.onAction,
  });

  final bool isArabic;
  final SubjectItem subject;
  final List<SectionItem> sections;
  final VoidCallback onBack;
  final ValueChanged<String> onAction;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('السكاشن', 'Sections'),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      child: Column(
        children: [
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.science_rounded,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              section.title.of(isArabic),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          _StatusPill(
                            label: section.dateLabel.of(isArabic),
                            color: const Color(0xFF0F766E),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${t('المعيد', 'TA')}: ${section.assistant.of(isArabic)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${t('المكان', 'Location')}: ${section.location.of(isArabic)}',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ActionChipButton(
                            icon: Icons.picture_as_pdf_rounded,
                            label: t('فتح ملف السكشن', 'Open section PDF'),
                            onTap: () => onAction(
                              t(
                                'تم فتح ${section.material}',
                                '${section.material} opened',
                              ),
                            ),
                          ),
                          _ActionChipButton(
                            icon: Icons.notifications_active_rounded,
                            label: t('ذكرني', 'Remind me'),
                            onTap: () => onAction(
                              t('تم تفعيل التذكير', 'Reminder enabled'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuizzesPrototypePage extends StatelessWidget {
  const QuizzesPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.quizzes,
    required this.onBack,
    required this.onOpenQuiz,
    required this.onEnterQuiz,
  });

  final bool isArabic;
  final SubjectItem subject;
  final List<QuizItem> quizzes;
  final VoidCallback onBack;
  final ValueChanged<String> onOpenQuiz;
  final ValueChanged<String> onEnterQuiz;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('الكويزات', 'Quizzes'),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      child: Column(
        children: [
          for (final quiz in quizzes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuizCard(
                isArabic: isArabic,
                quiz: quiz,
                subject: subject,
                onOpen: () => onOpenQuiz(quiz.id),
                onEnter: () => onEnterQuiz(quiz.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.isArabic,
    required this.quiz,
    required this.subject,
    required this.onOpen,
    required this.onEnter,
  });

  final bool isArabic;
  final QuizItem quiz;
  final SubjectItem subject;
  final VoidCallback onOpen;
  final VoidCallback onEnter;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (quiz.status) {
      QuizStatus.upcoming => const Color(0xFF2563EB),
      QuizStatus.available => const Color(0xFF0F766E),
      QuizStatus.completed => const Color(0xFF7C3AED),
      QuizStatus.expired => const Color(0xFFDC2626),
    };
    final statusLabel = switch (quiz.status) {
      QuizStatus.upcoming => t('Upcoming', 'Upcoming'),
      QuizStatus.available => t('Available', 'Available'),
      QuizStatus.completed => t('Completed', 'Completed'),
      QuizStatus.expired => t('Expired', 'Expired'),
    };

    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.quiz_rounded, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title.of(isArabic),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject.name.of(isArabic),
                          style: const TextStyle(color: Color(0xFF667085)),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 14),
              _InfoGrid(
                items: [
                  _InfoCell(
                    icon: Icons.person_rounded,
                    label: t('الدكتور/المعيد', 'Instructor'),
                    value: quiz.doctor.of(isArabic),
                  ),
                  _InfoCell(
                    icon: Icons.event_rounded,
                    label: t('تاريخ البداية', 'Start date'),
                    value: quiz.startLabel.of(isArabic),
                  ),
                  _InfoCell(
                    icon: Icons.timer_rounded,
                    label: t('المدة', 'Duration'),
                    value: '${quiz.durationMinutes} ${t('دقيقة', 'min')}',
                  ),
                  _InfoCell(
                    icon: Icons.format_list_numbered_rounded,
                    label: t('عدد الأسئلة', 'Questions'),
                    value: '${quiz.questions.length}',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatusPill(
                    label: quiz.isOnline
                        ? t('Online', 'Online')
                        : t('Offline', 'Offline'),
                    color: quiz.isOnline
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFB45309),
                  ),
                  if (quiz.score != null) ...[
                    const SizedBox(width: 8),
                    _StatusPill(
                      label: '${quiz.score} / ${quiz.questions.length}',
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                  const Spacer(),
                  OutlinedButton(
                    onPressed: onOpen,
                    child: Text(t('التفاصيل', 'Details')),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: quiz.canEnter ? onEnter : null,
                    child: Text(t('Enter', 'Enter')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizDetailsPrototypePage extends StatelessWidget {
  const QuizDetailsPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.quiz,
    required this.onBack,
    required this.onEnterQuiz,
  });

  final bool isArabic;
  final SubjectItem subject;
  final QuizItem quiz;
  final VoidCallback onBack;
  final VoidCallback onEnterQuiz;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: quiz.title.of(isArabic),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuizCard(
            isArabic: isArabic,
            quiz: quiz,
            subject: subject,
            onOpen: () {},
            onEnter: onEnterQuiz,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    title: t('تعليمات الكويز', 'Quiz instructions'),
                  ),
                  const SizedBox(height: 8),
                  for (final instruction in quiz.instructions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(instruction.of(isArabic))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: quiz.canEnter ? onEnterQuiz : null,
                    icon: const Icon(Icons.login_rounded),
                    label: Text(t('Enter Quiz', 'Enter Quiz')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizTakingPrototypePage extends StatefulWidget {
  const QuizTakingPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.quiz,
    required this.onSubmit,
    required this.onExit,
  });

  final bool isArabic;
  final SubjectItem subject;
  final QuizItem quiz;
  final ValueChanged<int> onSubmit;
  final VoidCallback onExit;

  @override
  State<QuizTakingPrototypePage> createState() =>
      _QuizTakingPrototypePageState();
}

class _QuizTakingPrototypePageState extends State<QuizTakingPrototypePage> {
  late final List<int?> _answers = List<int?>.filled(
    widget.quiz.questions.length,
    null,
  );
  int _index = 0;
  int _secondsLeft = 20 * 60;
  Timer? _timer;

  String t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.quiz.durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }
      if (_secondsLeft <= 0) {
        timer.cancel();
        _submit();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_index];
    final answered = _answers.whereType<int>().length;
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    return PrototypePageFrame(
      isArabic: widget.isArabic,
      title: widget.quiz.title.of(widget.isArabic),
      subtitle:
          '${t('السؤال', 'Question')} ${_index + 1} / ${widget.quiz.questions.length}',
      onBack: widget.onExit,
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: answered / widget.quiz.questions.length,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusPill(
                  label: '$minutes:$seconds',
                  color: const Color(0xFFDC2626),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${t('سؤال', 'Question')} ${_index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        question.text.of(widget.isArabic),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (var i = 0; i < question.options.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _QuizOptionTile(
                            selected: _answers[_index] == i,
                            label: question.options[i].of(widget.isArabic),
                            onTap: () => setState(() => _answers[_index] = i),
                          ),
                        ),
                      const Spacer(),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 10,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _index == 0
                                ? null
                                : () => setState(() => _index--),
                            icon: const Icon(Icons.chevron_left_rounded),
                            label: Text(t('Previous', 'Previous')),
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                _index == widget.quiz.questions.length - 1
                                ? null
                                : () => setState(() => _index++),
                            icon: const Icon(Icons.chevron_right_rounded),
                            label: Text(t('Next', 'Next')),
                          ),
                          FilledButton.icon(
                            onPressed: _confirmSubmit,
                            icon: const Icon(Icons.send_rounded),
                            label: Text(t('Submit', 'Submit')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('تأكيد التسليم', 'Confirm submit')),
        content: Text(
          t(
            'هل أنت متأكد من تسليم الكويز؟ لا يمكن تعديل الإجابات بعد التسليم.',
            'Are you sure you want to submit? Answers cannot be changed after submission.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t('تسليم', 'Submit')),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      _submit();
    }
  }

  void _submit() {
    _timer?.cancel();
    var score = 0;
    for (var i = 0; i < widget.quiz.questions.length; i++) {
      if (_answers[i] == widget.quiz.questions[i].correctIndex) {
        score++;
      }
    }
    widget.onSubmit(score);
  }
}

class QuizResultPrototypePage extends StatelessWidget {
  const QuizResultPrototypePage({
    super.key,
    required this.isArabic,
    required this.quiz,
    required this.onBackToSubject,
    required this.onBack,
  });

  final bool isArabic;
  final QuizItem quiz;
  final VoidCallback onBackToSubject;
  final VoidCallback onBack;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('نتيجة الكويز', 'Quiz result'),
      subtitle: quiz.title.of(isArabic),
      onBack: onBack,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 74,
                color: Color(0xFFB45309),
              ),
              const SizedBox(height: 12),
              Text(
                '${quiz.score ?? 0} / ${quiz.questions.length}',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                t(
                  'تم التسليم بنجاح وتحديث الإشعارات.',
                  'Submitted successfully and notifications were updated.',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onBackToSubject,
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(t('العودة للمادة', 'Back to subject')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEAF2FF) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE4E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

class TasksPrototypePage extends StatelessWidget {
  const TasksPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.tasks,
    required this.onBack,
    required this.onUpload,
  });

  final bool isArabic;
  final SubjectItem subject;
  final List<TaskItem> tasks;
  final VoidCallback onBack;
  final ValueChanged<TaskItem> onUpload;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('المهام', 'Tasks'),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      child: Column(
        children: [
          for (final task in tasks)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.task_alt_rounded,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              task.title.of(isArabic),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          _StatusPill(
                            label: _taskStatusLabel(task.status),
                            color: _taskStatusColor(task.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description.of(isArabic),
                        style: const TextStyle(color: Color(0xFF667085)),
                      ),
                      const SizedBox(height: 8),
                      Text(task.dueLabel.of(isArabic)),
                      if (task.uploadedFile != null) ...[
                        const SizedBox(height: 8),
                        _StateNoticeCard(
                          icon: Icons.attach_file_rounded,
                          title: t('ملف مرفوع', 'Uploaded file'),
                          body: task.uploadedFile!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () => onUpload(task),
                            icon: const Icon(Icons.upload_file_rounded),
                            label: Text(
                              task.uploadedFile == null
                                  ? t('رفع ملف', 'Upload')
                                  : t('إعادة رفع', 'Re-upload'),
                            ),
                          ),
                          if (task.grade != null)
                            _StatusPill(
                              label: '${t('الدرجة', 'Grade')}: ${task.grade}',
                              color: const Color(0xFF7C3AED),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _taskStatusLabel(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => t('مطلوب', 'Pending'),
      TaskStatus.submitted => t('تم الرفع', 'Submitted'),
      TaskStatus.graded => t('تم التقييم', 'Graded'),
      TaskStatus.late => t('متأخر', 'Late'),
    };
  }

  Color _taskStatusColor(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => const Color(0xFFB45309),
      TaskStatus.submitted => const Color(0xFF0F766E),
      TaskStatus.graded => const Color(0xFF7C3AED),
      TaskStatus.late => const Color(0xFFDC2626),
    };
  }
}

class SummariesPrototypePage extends StatelessWidget {
  const SummariesPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.summaries,
    required this.onBack,
    required this.onAddSummary,
    required this.onOpenSummary,
  });

  final bool isArabic;
  final SubjectItem subject;
  final List<SummaryItem> summaries;
  final VoidCallback onBack;
  final VoidCallback onAddSummary;
  final ValueChanged<String> onOpenSummary;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('ملخصات الطلبة', 'Student summaries'),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      actions: [
        FilledButton.icon(
          onPressed: onAddSummary,
          icon: const Icon(Icons.add_rounded),
          label: Text(t('إضافة', 'Add')),
        ),
      ],
      child: summaries.isEmpty
          ? _EmptyState(
              isArabic: isArabic,
              titleAr: 'لا توجد ملخصات بعد',
              titleEn: 'No summaries yet',
              bodyAr: 'كن أول طالب يضيف ملخص لهذه المادة.',
              bodyEn: 'Be the first student to add a summary.',
            )
          : Column(
              children: [
                for (final summary in summaries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SummaryCard(
                      isArabic: isArabic,
                      summary: summary,
                      onTap: () => onOpenSummary(summary.id),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.isArabic,
    required this.summary,
    required this.onTap,
  });

  final bool isArabic;
  final SummaryItem summary;
  final VoidCallback onTap;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Avatar(name: summary.author.of(isArabic), radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.title.of(isArabic),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.author.of(isArabic)} • ${summary.createdLabel.of(isArabic)}',
                      style: const TextStyle(color: Color(0xFF667085)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (summary.attachmentName != null)
                          _StatusPill(
                            label: summary.attachmentName!,
                            color: const Color(0xFFDC2626),
                          ),
                        if (summary.videoUrl != null)
                          _StatusPill(
                            label: t('فيديو', 'Video'),
                            color: const Color(0xFF2563EB),
                          ),
                        _StatusPill(
                          label: '${summary.likes} ${t('إعجاب', 'likes')}',
                          color: const Color(0xFF0F766E),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryDetailsPrototypePage extends StatelessWidget {
  const SummaryDetailsPrototypePage({
    super.key,
    required this.isArabic,
    required this.summary,
    required this.onBack,
    required this.onPreview,
  });

  final bool isArabic;
  final SummaryItem summary;
  final VoidCallback onBack;
  final ValueChanged<String> onPreview;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: summary.title.of(isArabic),
      subtitle:
          '${summary.author.of(isArabic)} • ${summary.createdLabel.of(isArabic)}',
      onBack: onBack,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Avatar(name: summary.author.of(isArabic), radius: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      summary.author.of(isArabic),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusPill(
                    label: '${summary.likes} ${t('إعجاب', 'likes')}',
                    color: const Color(0xFF0F766E),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                t(
                  'هذا ملخص تجريبي من الطلبة يحتوي على نقاط المراجعة الأساسية وروابط الملفات المرتبطة.',
                  'This mock student summary includes essential revision points and linked learning files.',
                ),
                style: const TextStyle(height: 1.55),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (summary.attachmentName != null)
                    FilledButton.icon(
                      onPressed: () => onPreview(
                        t(
                          'فتح ${summary.attachmentName}',
                          'Opening ${summary.attachmentName}',
                        ),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: Text(t('معاينة المرفق', 'Preview attachment')),
                    ),
                  if (summary.videoUrl != null)
                    OutlinedButton.icon(
                      onPressed: () => onPreview(
                        t('تشغيل فيديو الملخص', 'Playing summary video'),
                      ),
                      icon: const Icon(Icons.play_circle_rounded),
                      label: Text(t('تشغيل الفيديو', 'Play video')),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddSummaryPrototypePage extends StatefulWidget {
  const AddSummaryPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.onBack,
    required this.onSubmit,
  });

  final bool isArabic;
  final SubjectItem subject;
  final VoidCallback onBack;
  final void Function(String title, String? videoUrl, String? attachmentName)
  onSubmit;

  @override
  State<AddSummaryPrototypePage> createState() =>
      _AddSummaryPrototypePageState();
}

class _AddSummaryPrototypePageState extends State<AddSummaryPrototypePage> {
  final _title = TextEditingController();
  final _video = TextEditingController();
  final _attachment = TextEditingController(text: 'my-summary.pdf');

  String t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void dispose() {
    _title.dispose();
    _video.dispose();
    _attachment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: widget.isArabic,
      title: t('إضافة ملخص', 'Add summary'),
      subtitle: widget.subject.name.of(widget.isArabic),
      onBack: widget.onBack,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: t('عنوان الملخص', 'Summary title'),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _video,
                decoration: InputDecoration(
                  labelText: t('رابط فيديو اختياري', 'Optional video URL'),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _attachment,
                decoration: InputDecoration(
                  labelText: t('اسم المرفق', 'Attachment name'),
                  prefixIcon: const Icon(Icons.attach_file_rounded),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  final title = _title.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          t('اكتب عنوان الملخص', 'Enter the summary title'),
                        ),
                      ),
                    );
                    return;
                  }
                  widget.onSubmit(
                    title,
                    _video.text.trim().isEmpty ? null : _video.text.trim(),
                    _attachment.text.trim().isEmpty
                        ? null
                        : _attachment.text.trim(),
                  );
                },
                icon: const Icon(Icons.publish_rounded),
                label: Text(t('نشر الملخص', 'Publish summary')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityPrototypePage extends StatelessWidget {
  const CommunityPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.posts,
    required this.selectedFilter,
    required this.onBack,
    required this.onFilterChanged,
    required this.onReact,
    required this.onOpenPost,
  });

  final bool isArabic;
  final SubjectItem subject;
  final List<CommunityPost> posts;
  final CommunityFilter selectedFilter;
  final VoidCallback onBack;
  final ValueChanged<CommunityFilter> onFilterChanged;
  final ValueChanged<CommunityPost> onReact;
  final ValueChanged<String> onOpenPost;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('Community المادة', 'Subject Community'),
      subtitle: subject.name.of(isArabic),
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<CommunityFilter>(
            segments: [
              ButtonSegment(
                value: CommunityFilter.newest,
                label: Text(t('الأحدث', 'Newest')),
                icon: const Icon(Icons.trending_up_rounded),
              ),
              ButtonSegment(
                value: CommunityFilter.oldest,
                label: Text(t('الأقدم', 'Oldest')),
                icon: const Icon(Icons.history_rounded),
              ),
              ButtonSegment(
                value: CommunityFilter.all,
                label: Text(t('الكل', 'All')),
                icon: const Icon(Icons.all_inbox_rounded),
              ),
            ],
            selected: {selectedFilter},
            onSelectionChanged: (value) => onFilterChanged(value.first),
          ),
          const SizedBox(height: 16),
          for (final post in posts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PostCard(
                isArabic: isArabic,
                post: post,
                onReact: () => onReact(post),
                onOpen: () => onOpenPost(post.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.isArabic,
    required this.post,
    required this.onReact,
    required this.onOpen,
  });

  final bool isArabic;
  final CommunityPost post;
  final VoidCallback onReact;
  final VoidCallback onOpen;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(name: post.author.of(isArabic), radius: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.of(isArabic),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${post.role.of(isArabic)} • ${post.createdLabel.of(isArabic)}',
                          style: const TextStyle(color: Color(0xFF667085)),
                        ),
                      ],
                    ),
                  ),
                  if (post.isPinned)
                    _StatusPill(
                      label: t('مثبت', 'Pinned'),
                      color: const Color(0xFFB45309),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.body.of(isArabic), style: const TextStyle(height: 1.5)),
              if (post.attachmentName != null) ...[
                const SizedBox(height: 12),
                _StatusPill(
                  label: post.attachmentName!,
                  color: const Color(0xFFDC2626),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionChipButton(
                    icon: Icons.favorite_border_rounded,
                    label: '${post.reactions}',
                    onTap: onReact,
                  ),
                  _ActionChipButton(
                    icon: Icons.comment_outlined,
                    label:
                        '${post.comments.length} ${t('تعليقات', 'comments')}',
                    onTap: onOpen,
                    emphasis: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostDetailsPrototypePage extends StatefulWidget {
  const PostDetailsPrototypePage({
    super.key,
    required this.isArabic,
    required this.post,
    required this.onBack,
    required this.onReact,
    required this.onAddComment,
  });

  final bool isArabic;
  final CommunityPost post;
  final VoidCallback onBack;
  final ValueChanged<CommunityPost> onReact;
  final void Function(CommunityPost post, String comment) onAddComment;

  @override
  State<PostDetailsPrototypePage> createState() =>
      _PostDetailsPrototypePageState();
}

class _PostDetailsPrototypePageState extends State<PostDetailsPrototypePage> {
  final _comment = TextEditingController();

  String t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: widget.isArabic,
      title: t('تعليقات المنشور', 'Post comments'),
      subtitle: widget.post.author.of(widget.isArabic),
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PostCard(
            isArabic: widget.isArabic,
            post: widget.post,
            onReact: () => widget.onReact(widget.post),
            onOpen: () {},
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: t('التعليقات', 'Comments')),
          const SizedBox(height: 10),
          if (widget.post.comments.isEmpty)
            _EmptyState(
              isArabic: widget.isArabic,
              titleAr: 'لا توجد تعليقات بعد',
              titleEn: 'No comments yet',
              bodyAr: 'ابدأ النقاش بسؤال واضح.',
              bodyEn: 'Start the discussion with a clear question.',
            )
          else
            for (final comment in widget.post.comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: _Avatar(
                      name: comment.author.of(widget.isArabic),
                      radius: 20,
                    ),
                    title: Text(comment.author.of(widget.isArabic)),
                    subtitle: Text(comment.body.of(widget.isArabic)),
                    trailing: Text(comment.createdLabel.of(widget.isArabic)),
                  ),
                ),
              ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comment,
                      decoration: InputDecoration(
                        hintText: t('اكتب تعليقك', 'Write a comment'),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      final text = _comment.text.trim();
                      if (text.isEmpty) {
                        return;
                      }
                      widget.onAddComment(widget.post, text);
                      _comment.clear();
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupChatPrototypePage extends StatefulWidget {
  const GroupChatPrototypePage({
    super.key,
    required this.isArabic,
    required this.subject,
    required this.isRegistered,
    required this.messages,
    required this.profile,
    required this.onBack,
    required this.onSend,
    required this.onDelete,
    required this.onReport,
  });

  final bool isArabic;
  final SubjectItem subject;
  final bool isRegistered;
  final List<ChatMessage> messages;
  final StudentProfile profile;
  final VoidCallback onBack;
  final ValueChanged<String> onSend;
  final ValueChanged<ChatMessage> onDelete;
  final VoidCallback onReport;

  @override
  State<GroupChatPrototypePage> createState() => _GroupChatPrototypePageState();
}

class _GroupChatPrototypePageState extends State<GroupChatPrototypePage> {
  final _message = TextEditingController();

  String t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRegistered) {
      return PrototypePageFrame(
        isArabic: widget.isArabic,
        title: t('Group Chat', 'Group Chat'),
        subtitle: widget.subject.name.of(widget.isArabic),
        onBack: widget.onBack,
        child: _EmptyState(
          isArabic: widget.isArabic,
          titleAr: 'غير مسموح',
          titleEn: 'Access denied',
          bodyAr: 'لا يمكن دخول شات مادة غير مسجل فيها.',
          bodyEn: 'Students cannot enter chats for unregistered subjects.',
        ),
      );
    }

    return PrototypePageFrame(
      isArabic: widget.isArabic,
      title: t('Group Chat', 'Group Chat'),
      subtitle: widget.subject.name.of(widget.isArabic),
      onBack: widget.onBack,
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.messages[index];
                    return _ChatBubble(
                      isArabic: widget.isArabic,
                      message: message,
                      onTap: () => _showMessageOptions(message),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: t('إرفاق', 'Attach'),
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                t(
                                  'اختيار مرفق تجريبي',
                                  'Mock attachment picker',
                                ),
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.attach_file_rounded),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          hintText: t('اكتب رسالة', 'Write a message'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: t('إرسال', 'Send'),
                      onPressed: () {
                        final text = _message.text.trim();
                        if (text.isEmpty) {
                          return;
                        }
                        widget.onSend(text);
                        _message.clear();
                      },
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMessageOptions(ChatMessage message) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: Text(t('Copy', 'Copy')),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t('تم النسخ', 'Copied'))),
                  );
                },
              ),
              if (message.isMine)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: Text(t('Delete my message', 'Delete my message')),
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onDelete(message);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.report_gmailerrorred_rounded),
                title: Text(t('Report', 'Report')),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onReport();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isArabic,
    required this.message,
    required this.onTap,
  });

  final bool isArabic;
  final ChatMessage message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final align = message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = message.isMine
        ? const Color(0xFFEAF2FF)
        : const Color(0xFFF8FAFC);
    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Avatar(name: message.author.of(isArabic), radius: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.author.of(isArabic),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        Text(message.content.of(isArabic)),
                        const SizedBox(height: 4),
                        Text(
                          message.timeLabel.of(isArabic),
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SchedulePrototypePage extends StatefulWidget {
  const SchedulePrototypePage({
    super.key,
    required this.isArabic,
    required this.schedule,
    required this.subjects,
    required this.onOpenSubject,
    required this.onOpenLecture,
  });

  final bool isArabic;
  final List<ScheduleItem> schedule;
  final List<SubjectItem> subjects;
  final ValueChanged<String> onOpenSubject;
  final void Function(String subjectId, String lectureId) onOpenLecture;

  @override
  State<SchedulePrototypePage> createState() => _SchedulePrototypePageState();
}

class _SchedulePrototypePageState extends State<SchedulePrototypePage> {
  int _selectedDay = 0;

  String t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final days = widget.schedule.map((item) => item.day).toList();
    final day = days[_selectedDay];
    final items = widget.schedule
        .where((item) => item.day.ar == day.ar && item.day.en == day.en)
        .toList();

    return PrototypePageFrame(
      isArabic: widget.isArabic,
      title: t('جدول المحاضرات', 'Class schedule'),
      subtitle: t(
        'جدول أسبوعي للمواد المسجلة فقط',
        'Weekly schedule for registered subjects only',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < days.length; i++)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      selected: i == _selectedDay,
                      label: Text(days[i].of(widget.isArabic)),
                      onSelected: (_) => setState(() => _selectedDay = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptyState(
              isArabic: widget.isArabic,
              titleAr: 'لا توجد محاضرات',
              titleEn: 'No classes',
              bodyAr: 'اليوم المحدد فارغ.',
              bodyEn: 'The selected day is empty.',
            )
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ScheduleCard(
                  isArabic: widget.isArabic,
                  item: item,
                  subject: widget.subjects.firstWhere(
                    (subject) => subject.id == item.subjectId,
                  ),
                  onOpenSubject: () => widget.onOpenSubject(item.subjectId),
                  onOpenLecture: () =>
                      widget.onOpenLecture(item.subjectId, item.lectureId),
                ),
              ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.isArabic,
    required this.item,
    required this.subject,
    required this.onOpenSubject,
    required this.onOpenLecture,
  });

  final bool isArabic;
  final ScheduleItem item;
  final SubjectItem subject;
  final VoidCallback onOpenSubject;
  final VoidCallback onOpenLecture;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpenLecture,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_month_rounded, color: subject.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name.of(isArabic),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.type.of(isArabic)} • ${item.location.of(isArabic)}',
                      style: const TextStyle(color: Color(0xFF667085)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusPill(
                          label: item.time,
                          color: const Color(0xFF2563EB),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.menu_book_rounded, size: 18),
                          label: Text(t('فتح المادة', 'Open subject')),
                          onPressed: onOpenSubject,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsPrototypePage extends StatelessWidget {
  const NotificationsPrototypePage({
    super.key,
    required this.isArabic,
    required this.notifications,
    required this.unreadCount,
    required this.selectedFilter,
    required this.notificationsEnabled,
    required this.onFilterChanged,
    required this.onOpenNotification,
  });

  final bool isArabic;
  final List<NotificationItem> notifications;
  final int unreadCount;
  final NotificationFilter selectedFilter;
  final bool notificationsEnabled;
  final ValueChanged<NotificationFilter> onFilterChanged;
  final ValueChanged<NotificationItem> onOpenNotification;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('الإشعارات', 'Notifications'),
      subtitle: t('$unreadCount غير مقروءة', '$unreadCount unread'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!notificationsEnabled)
            _StateNoticeCard(
              icon: Icons.notifications_off_rounded,
              title: t('الإشعارات متوقفة', 'Notifications disabled'),
              body: t(
                'يمكن تشغيلها من إعدادات الإشعارات.',
                'You can enable them from notification settings.',
              ),
            ),
          if (notificationsEnabled) ...[
            SegmentedButton<NotificationFilter>(
              segments: [
                ButtonSegment(
                  value: NotificationFilter.all,
                  label: Text(t('All', 'All')),
                  icon: const Icon(Icons.all_inbox_rounded),
                ),
                ButtonSegment(
                  value: NotificationFilter.unread,
                  label: Text(t('Unread', 'Unread')),
                  icon: const Icon(Icons.mark_email_unread_rounded),
                ),
                ButtonSegment(
                  value: NotificationFilter.important,
                  label: Text(t('Important', 'Important')),
                  icon: const Icon(Icons.priority_high_rounded),
                ),
              ],
              selected: {selectedFilter},
              onSelectionChanged: (value) => onFilterChanged(value.first),
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              _EmptyState(
                isArabic: isArabic,
                titleAr: 'لا توجد إشعارات',
                titleEn: 'No notifications',
                bodyAr: 'الفلتر الحالي لا يحتوي عناصر.',
                bodyEn: 'The current filter has no items.',
              )
            else
              for (final item in notifications)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NotificationListCard(
                    isArabic: isArabic,
                    item: item,
                    onTap: () => onOpenNotification(item),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _NotificationListCard extends StatelessWidget {
  const _NotificationListCard({
    required this.isArabic,
    required this.item,
    required this.onTap,
  });

  final bool isArabic;
  final NotificationItem item;
  final VoidCallback onTap;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final typeColor = switch (item.type) {
      NotificationType.college => const Color(0xFF2563EB),
      NotificationType.subject => const Color(0xFF0F766E),
      NotificationType.personal => const Color(0xFFB45309),
    };
    final typeLabel = switch (item.type) {
      NotificationType.college => t(
        'College Announcement',
        'College Announcement',
      ),
      NotificationType.subject => t(
        'Subject Announcement',
        'Subject Announcement',
      ),
      NotificationType.personal => t(
        'Personal Notification',
        'Personal Notification',
      ),
    };

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.campaign_rounded, color: typeColor),
                  ),
                  if (!item.isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title.of(isArabic),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (item.isImportant)
                          const Icon(
                            Icons.priority_high_rounded,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body.of(isArabic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF667085)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusPill(label: typeLabel, color: typeColor),
                        Text(item.createdLabel.of(isArabic)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationDetailsPrototypePage extends StatelessWidget {
  const NotificationDetailsPrototypePage({
    super.key,
    required this.isArabic,
    required this.notification,
    required this.onBack,
    required this.onOpenTarget,
  });

  final bool isArabic;
  final NotificationItem notification;
  final VoidCallback onBack;
  final ValueChanged<NotificationItem> onOpenTarget;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('تفاصيل الإشعار', 'Notification details'),
      subtitle: notification.createdLabel.of(isArabic),
      onBack: onBack,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.campaign_rounded,
                    color: Color(0xFF2563EB),
                    size: 34,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title.of(isArabic),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                notification.body.of(isArabic),
                style: const TextStyle(height: 1.6),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusPill(
                    label: notification.isRead
                        ? t('تمت القراءة', 'Read')
                        : t('غير مقروء', 'Unread'),
                    color: const Color(0xFF0F766E),
                  ),
                  if (notification.isImportant)
                    _StatusPill(
                      label: t('Important', 'Important'),
                      color: const Color(0xFFDC2626),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => onOpenTarget(notification),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(t('فتح المكان المرتبط', 'Open related place')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MorePrototypePage extends StatelessWidget {
  const MorePrototypePage({
    super.key,
    required this.isArabic,
    required this.profile,
    required this.notificationsEnabled,
    required this.onOpenProfile,
    required this.onOpenResults,
    required this.onOpenLanguage,
    required this.onOpenNotificationSettings,
    required this.onLogout,
  });

  final bool isArabic;
  final StudentProfile profile;
  final bool notificationsEnabled;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenResults;
  final VoidCallback onOpenLanguage;
  final VoidCallback onOpenNotificationSettings;
  final VoidCallback onLogout;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('المزيد', 'More'),
      subtitle: t(
        'الحساب والإعدادات والنتائج',
        'Account, settings, and results',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StudentHeroCard(isArabic: isArabic, profile: profile),
          const SizedBox(height: 16),
          _MoreTile(
            icon: Icons.person_rounded,
            title: t('My Profile', 'My Profile'),
            subtitle: t('البيانات الرسمية للطالب', 'Official student data'),
            onTap: onOpenProfile,
          ),
          _MoreTile(
            icon: Icons.workspace_premium_rounded,
            title: t('Academic Results', 'Academic Results'),
            subtitle: t('درجات المواد والتقدير', 'Grades and academic status'),
            onTap: onOpenResults,
          ),
          _MoreTile(
            icon: Icons.language_rounded,
            title: t('Language Settings', 'Language Settings'),
            subtitle: isArabic ? 'العربية' : 'English',
            onTap: onOpenLanguage,
          ),
          _MoreTile(
            icon: notificationsEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            title: t('Notification Settings', 'Notification Settings'),
            subtitle: notificationsEnabled
                ? t('الإشعارات مفعلة', 'Notifications enabled')
                : t('الإشعارات متوقفة', 'Notifications disabled'),
            onTap: onOpenNotificationSettings,
          ),
          _MoreTile(
            icon: Icons.logout_rounded,
            title: t('Logout', 'Logout'),
            subtitle: t('إنهاء الجلسة الحالية', 'End current session'),
            danger: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFDC2626) : const Color(0xFF2563EB);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

class ProfilePrototypePage extends StatelessWidget {
  const ProfilePrototypePage({
    super.key,
    required this.isArabic,
    required this.profile,
    required this.onBack,
  });

  final bool isArabic;
  final StudentProfile profile;
  final VoidCallback onBack;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (t('الاسم', 'Name'), profile.name.of(isArabic)),
      (t('الكود', 'Code'), profile.code),
      (t('الرقم القومي', 'National ID'), profile.maskedNationalId),
      (t('القسم', 'Department'), profile.department.of(isArabic)),
      (t('الفرقة', 'Level'), profile.level.of(isArabic)),
      (
        t('حالة القيد', 'Enrollment status'),
        profile.enrollmentStatus.of(isArabic),
      ),
      (t('سنة القبول', 'Admission year'), profile.admissionYear),
      (t('الجنسية', 'Nationality'), profile.nationality.of(isArabic)),
      (t('تاريخ الميلاد', 'Birth date'), profile.birthDate),
      (
        t('المؤهل السابق', 'Previous qualification'),
        profile.previousQualification.of(isArabic),
      ),
    ];

    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('My Profile', 'My Profile'),
      subtitle: profile.email,
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StudentHeroCard(isArabic: isArabic, profile: profile),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final row in rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              row.$1,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(
                              row.$2,
                              textAlign: isArabic
                                  ? TextAlign.left
                                  : TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _StateNoticeCard(
            icon: Icons.privacy_tip_rounded,
            title: t('خصوصية Microsoft', 'Microsoft privacy'),
            body: t(
              'Tolab يحتفظ بربط الحساب فقط ولا يخزن كلمة مرور Microsoft نهائيا.',
              'Tolab keeps the account link only and never stores the Microsoft password.',
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsPrototypePage extends StatelessWidget {
  const ResultsPrototypePage({
    super.key,
    required this.isArabic,
    required this.profile,
    required this.results,
    required this.onBack,
  });

  final bool isArabic;
  final StudentProfile profile;
  final List<ResultItem> results;
  final VoidCallback onBack;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final average =
        results.map((item) => item.total).reduce((a, b) => a + b) /
        results.length;
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('النتائج الأكاديمية', 'Academic Results'),
      subtitle:
          '${profile.name.of(isArabic)} • GPA mock ${(average / 25).toStringAsFixed(2)}',
      onBack: onBack,
      child: Column(
        children: [
          _AdaptiveWrap(
            minTileWidth: 220,
            children: [
              _DashboardShortcut(
                icon: Icons.grade_rounded,
                title: t('متوسط الدرجات', 'Average'),
                value: average.toStringAsFixed(1),
                color: const Color(0xFF2563EB),
                onTap: () {},
              ),
              _DashboardShortcut(
                icon: Icons.done_all_rounded,
                title: t('مواد ناجحة', 'Passed subjects'),
                value: '${results.length}',
                color: const Color(0xFF0F766E),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final result in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.grade,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.subject.of(isArabic),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(result.notes.of(isArabic)),
                          ],
                        ),
                      ),
                      _StatusPill(
                        label: '${result.total}%',
                        color: const Color(0xFF0F766E),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LanguageSettingsPrototypePage extends StatelessWidget {
  const LanguageSettingsPrototypePage({
    super.key,
    required this.isArabic,
    required this.onBack,
    required this.onChanged,
  });

  final bool isArabic;
  final VoidCallback onBack;
  final ValueChanged<bool> onChanged;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('إعدادات اللغة', 'Language Settings'),
      subtitle: t(
        'دعم كامل للـ RTL والعربية والإنجليزية',
        'Full RTL, Arabic, and English support',
      ),
      onBack: onBack,
      child: Column(
        children: [
          _LanguageTile(
            title: 'العربية',
            subtitle: 'واجهة من اليمين لليسار',
            selected: isArabic,
            onTap: () => onChanged(true),
          ),
          const SizedBox(height: 10),
          _LanguageTile(
            title: 'English',
            subtitle: 'Left-to-right interface',
            selected: !isArabic,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_off,
          color: selected ? const Color(0xFF2563EB) : null,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: selected ? const Icon(Icons.check_rounded) : null,
      ),
    );
  }
}

class NotificationSettingsPrototypePage extends StatelessWidget {
  const NotificationSettingsPrototypePage({
    super.key,
    required this.isArabic,
    required this.enabled,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.onBack,
    required this.onChanged,
  });

  final bool isArabic;
  final bool enabled;
  final bool pushEnabled;
  final bool emailEnabled;
  final VoidCallback onBack;
  final void Function({bool? enabled, bool? push, bool? email}) onChanged;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('إعدادات الإشعارات', 'Notification Settings'),
      subtitle: t(
        'الإعلانات العامة تظهر لكل الطلاب، وإعلانات المادة لطلابها فقط',
        'College announcements go to everyone; subject announcements go to enrolled students only',
      ),
      onBack: onBack,
      child: Column(
        children: [
          SwitchListTile(
            value: enabled,
            onChanged: (value) => onChanged(enabled: value),
            title: Text(t('تفعيل الإشعارات', 'Enable notifications')),
            subtitle: Text(
              t(
                'المستخدم الموقوف لا يستقبل إشعارات',
                'Disabled users receive no notifications',
              ),
            ),
            secondary: const Icon(Icons.notifications_active_rounded),
          ),
          SwitchListTile(
            value: pushEnabled,
            onChanged: enabled ? (value) => onChanged(push: value) : null,
            title: Text(t('Push Notifications', 'Push Notifications')),
            secondary: const Icon(Icons.phone_iphone_rounded),
          ),
          SwitchListTile(
            value: emailEnabled,
            onChanged: enabled ? (value) => onChanged(email: value) : null,
            title: Text(t('Email Notifications', 'Email Notifications')),
            secondary: const Icon(Icons.email_rounded),
          ),
          const SizedBox(height: 10),
          _StateNoticeCard(
            icon: Icons.rule_rounded,
            title: t('قواعد الوصول', 'Access rules'),
            body: t(
              'لا تظهر إشعارات مادة إلا للطلاب المسجلين فيها.',
              'Subject announcements appear only for enrolled students.',
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutFlowPrototypePage extends StatelessWidget {
  const LogoutFlowPrototypePage({
    super.key,
    required this.isArabic,
    required this.profile,
    required this.onBack,
    required this.onConfirm,
  });

  final bool isArabic;
  final StudentProfile profile;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  String t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    return PrototypePageFrame(
      isArabic: isArabic,
      title: t('تسجيل الخروج', 'Logout'),
      subtitle: profile.email,
      onBack: onBack,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 64,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                t('هل تريد إنهاء الجلسة؟', 'End this session?'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t(
                  'بعد الخروج ستعود إلى شاشة Microsoft Login. لن يتم حذف ربط الرقم القومي في النظام الحقيقي.',
                  'After logout you return to Microsoft Login. A real system would keep the verified link.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF667085), height: 1.45),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: onBack,
                    child: Text(t('إلغاء', 'Cancel')),
                  ),
                  FilledButton.icon(
                    onPressed: () => _confirmDialog(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(t('تأكيد الخروج', 'Confirm logout')),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('تأكيد الخروج', 'Confirm logout')),
        content: Text(
          t('سيتم إنهاء الجلسة الحالية.', 'The current session will be ended.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t('خروج', 'Logout')),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      onConfirm();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        ?action,
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.radius});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'T' : name.trim().characters.first;
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEAF2FF),
      child: Text(
        initial,
        style: TextStyle(
          color: const Color(0xFF2563EB),
          fontSize: radius * 0.72,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoCell {
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});

  final List<_InfoCell> items;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveWrap(
      minTileWidth: 210,
      spacing: 10,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: const Color(0xFF2563EB), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
