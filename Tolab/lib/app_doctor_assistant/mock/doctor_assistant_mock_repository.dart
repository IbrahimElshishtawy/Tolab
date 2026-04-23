import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_admin/core/colors/app_colors.dart';
import '../../app_admin/modules/schedule/models/schedule_models.dart';
import '../core/models/academic_models.dart';
import '../core/models/content_models.dart';
import '../core/models/dashboard_models.dart';
import '../core/models/notification_models.dart';
import '../core/models/session_user.dart';
import '../core/models/staff_models.dart';
import '../core/navigation/app_routes.dart';
import '../models/doctor_assistant_models.dart';
import 'mock_portal_models.dart';
import 'mock_sample_payloads.dart';

class DoctorAssistantMockRepository {
  DoctorAssistantMockRepository._() {
    _seed();
  }

  static final DoctorAssistantMockRepository instance =
      DoctorAssistantMockRepository._();

  final Map<String, _MockAccount> _accountsByEmail = {};
  final List<TeachingSubject> _subjects = [];
  final List<WorkspaceNotificationItem> _notifications = [];
  final List<ScheduleEventItem> _schedule = [];
  final List<UploadModel> _uploads = [];
  final List<MockStudentResult> _results = [];
  final List<MockAnnouncementItem> _announcements = [];
  final List<MockStudentDirectoryEntry> _students = [];
  final List<MockGroupPost> _groupPosts = [];
  final List<MockMessageThread> _messageThreads = [];
  final List<DepartmentModel> _departments = [];

  int _nextUploadId = 10;
  int _nextLectureId = 3000;
  int _nextSectionId = 4000;
  int _nextQuizId = 5000;
  int _nextTaskId = 6000;

  Future<void> simulateLatency([
    Duration duration = const Duration(milliseconds: 280),
  ]) {
    return Future<void>.delayed(duration);
  }

  SessionUser authenticate({required String email, required String password}) {
    final account = _accountsByEmail[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw Exception('Invalid university email or password.');
    }

    if (!account.user.isActive) {
      throw Exception(
        'This account is inactive. Please contact administration.',
      );
    }

    return account.user;
  }

  SessionUser userByEmail(String email) {
    final account = _accountsByEmail[email.trim().toLowerCase()];
    if (account == null) {
      throw Exception('Mock account not found for $email.');
    }
    return account.user;
  }

  bool hasAccount(String email) {
    return _accountsByEmail.containsKey(email.trim().toLowerCase());
  }

  SessionUser? restoreUserFromSession(Map<String, dynamic>? session) {
    final rawUser = session?['user'];
    if (rawUser is Map<String, dynamic>) {
      return SessionUser.fromJson(rawUser);
    }
    if (rawUser is Map) {
      return SessionUser.fromJson(Map<String, dynamic>.from(rawUser));
    }
    return null;
  }

  SessionUser refreshUser(SessionUser user) {
    final account = _accountForUser(user);
    return account?.user ?? user;
  }

  SessionUser updateUserSettings(
    SessionUser user,
    Map<String, dynamic> payload,
  ) {
    final account = _accountForUser(user);
    if (account == null) {
      return user;
    }

    final nextUser = SessionUser(
      id: account.user.id,
      fullName: account.user.fullName,
      universityEmail: account.user.universityEmail,
      roleType: account.user.roleType,
      isActive: account.user.isActive,
      avatar: account.user.avatar,
      phone: payload['phone']?.toString() ?? account.user.phone,
      notificationEnabled:
          payload['notification_enabled'] as bool? ??
          account.user.notificationEnabled,
      language: payload['language']?.toString() ?? account.user.language,
      permissions: List<String>.from(account.user.permissions),
    );

    _accountsByEmail[account.user.universityEmail
        .toLowerCase()] = account.copyWith(
      user: nextUser,
      locationLabel:
          payload['location_label']?.toString() ?? account.locationLabel,
      officeHours: payload['office_hours']?.toString() ?? account.officeHours,
    );
    return nextUser;
  }

  List<TeachingSubject> subjectsFor(SessionUser user) =>
      List<TeachingSubject>.unmodifiable(_subjects);

  TeachingSubject subjectById(int subjectId) {
    return _subjects.firstWhere(
      (subject) => subject.id == subjectId,
      orElse: () => _subjects.first,
    );
  }

  List<SubjectModel> subjectModelsFor(SessionUser user) {
    return _subjects
        .map(
          (subject) => SubjectModel(
            id: subject.id,
            name: subject.name,
            code: subject.code,
            isActive: true,
            departmentName: subject.department,
            academicYearName: subject.academicTerm,
            description: subject.description,
            sections: subject.sections
                .map(
                  (section) => SectionModel(
                    id: _numericId(section.id),
                    name: section.title,
                    code: section.groupLabel,
                    isActive: true,
                    assistantName: section.assistantName,
                  ),
                )
                .toList(),
          ),
        )
        .toList(growable: false);
  }

  SubjectModel subjectModelById(int subjectId) {
    return subjectModelsFor(_accountsByEmail.values.first.user).firstWhere(
      (subject) => subject.id == subjectId,
      orElse: () => subjectModelsFor(_accountsByEmail.values.first.user).first,
    );
  }

  List<LectureModel> lecturesFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.lectures.map(
            (lecture) => LectureModel(
              id: _numericId(lecture.id),
              subjectId: subject.id,
              title: lecture.title,
              weekNumber: _weekNumber(lecture.weekLabel),
              instructorName: _ownerNameForSubject(subject.id),
              isPublished: lecture.statusLabel.toLowerCase() != 'draft',
              publishedAt: lecture.statusLabel.toLowerCase() == 'draft'
                  ? null
                  : DateTime(2026, 4, 22, 9, 0).toIso8601String(),
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveLecture(Map<String, dynamic> payload, SessionUser user) {
    final subject = _subjectForPayload(payload['subject']?.toString());
    final lectures = List<TeachingLecture>.from(subject.lectures)
      ..insert(
        0,
        TeachingLecture(
          id: 'mock-lec-${_nextLectureId++}',
          title: payload['title']?.toString() ?? 'Untitled lecture',
          audience: payload['scope']?.toString() ?? 'All groups',
          dayLabel: _leadingWord(
            payload['schedule']?.toString(),
            fallback: 'Sunday',
          ),
          timeLabel: payload['schedule']?.toString() ?? '09:00 - 11:00',
          room: _roomFromNotes(payload['notes']?.toString()),
          statusLabel: 'Draft',
          weekLabel: 'Week ${subject.lectures.length + 8}',
        ),
      );
    _replaceSubject(subject, _cloneSubject(subject, lectures: lectures));
  }

  void deleteLecture(int lectureId) {
    for (var index = 0; index < _subjects.length; index++) {
      final subject = _subjects[index];
      final filtered = subject.lectures
          .where((lecture) => _numericId(lecture.id) != lectureId)
          .toList(growable: false);
      if (filtered.length != subject.lectures.length) {
        _subjects[index] = _cloneSubject(subject, lectures: filtered);
        break;
      }
    }
  }

  List<SectionContentModel> sectionContentFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.sections.map(
            (section) => SectionContentModel(
              id: _numericId(section.id),
              subjectId: subject.id,
              title: section.title,
              weekNumber: _weekNumber(section.groupLabel),
              assistantName: section.assistantName,
              isPublished: section.statusLabel.toLowerCase() != 'draft',
              publishedAt: section.statusLabel.toLowerCase() == 'draft'
                  ? null
                  : DateTime(2026, 4, 22, 8, 0).toIso8601String(),
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveSectionContent(Map<String, dynamic> payload, SessionUser user) {
    final subject = _subjectForPayload(payload['subject']?.toString());
    final sections = List<TeachingSection>.from(subject.sections)
      ..insert(
        0,
        TeachingSection(
          id: 'mock-sec-${_nextSectionId++}',
          title: payload['title']?.toString() ?? 'Untitled section',
          assistantName: user.fullName,
          dayLabel: _leadingWord(
            payload['schedule']?.toString(),
            fallback: 'Monday',
          ),
          timeLabel: payload['schedule']?.toString() ?? '12:00 - 13:30',
          room: _roomFromNotes(payload['notes']?.toString()),
          statusLabel: 'Draft',
          groupLabel: payload['scope']?.toString() ?? 'Section group',
        ),
      );
    _replaceSubject(subject, _cloneSubject(subject, sections: sections));
  }

  List<QuizModel> quizzesFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.quizzes.map(
            (quiz) => QuizModel(
              id: _numericId(quiz.id),
              subjectId: subject.id,
              title: quiz.title,
              ownerName: _ownerNameForSubject(subject.id),
              quizType: quiz.statusLabel.toLowerCase() == 'published'
                  ? 'graded'
                  : 'timed',
              quizDate: quiz.windowLabel,
              isPublished: quiz.statusLabel.toLowerCase() == 'published',
              quizLink: 'mock://quizzes/${quiz.id}',
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveQuiz(Map<String, dynamic> payload, SessionUser user) {
    final subject = _subjectForPayload(payload['subject']?.toString());
    final quizzes = List<TeachingQuiz>.from(subject.quizzes)
      ..insert(
        0,
        TeachingQuiz(
          id: 'mock-quiz-${_nextQuizId++}',
          title: payload['title']?.toString() ?? 'Untitled quiz',
          windowLabel: payload['schedule']?.toString() ?? 'Tue 10:30 - 45 min',
          statusLabel: 'Draft',
          attemptsLabel: 'Awaiting publish',
          scopeLabel: payload['scope']?.toString() ?? 'Target cohort',
        ),
      );
    _replaceSubject(subject, _cloneSubject(subject, quizzes: quizzes));
  }

  List<TaskModel> tasksFor(SessionUser user) {
    return _subjects
        .expand(
          (subject) => subject.tasks.map(
            (task) => TaskModel(
              id: _numericId(task.id),
              subjectId: subject.id,
              title: task.title,
              ownerName: _ownerNameForSubject(subject.id),
              referenceName: task.scopeLabel,
              dueDate: task.deadlineLabel,
              isPublished: task.statusLabel.toLowerCase() == 'published',
              fileUrl: 'mock://tasks/${task.id}',
            ),
          ),
        )
        .toList(growable: false);
  }

  void saveTask(Map<String, dynamic> payload, SessionUser user) {
    final subjectId = (payload['subject_id'] as num?)?.toInt();
    final subject = subjectId == null
        ? _subjectForPayload(payload['subject']?.toString())
        : _subjects.firstWhere(
            (candidate) => candidate.id == subjectId,
            orElse: () => _subjectForPayload(payload['subject']?.toString()),
          );
    final publishImmediately = payload['publish_immediately'] == true;
    final addToSchedule = payload['add_to_schedule'] == true;
    final statusLabel = publishImmediately
        ? 'Published'
        : addToSchedule
        ? 'Scheduled'
        : 'Draft';
    final progressLabel = publishImmediately
        ? '0% submitted'
        : addToSchedule
        ? 'Scheduled for release'
        : 'Awaiting publish';
    final tasks = List<TeachingTask>.from(subject.tasks)
      ..insert(
        0,
        TeachingTask(
          id: 'mock-task-${_nextTaskId++}',
          title: payload['title']?.toString() ?? 'Untitled task',
          deadlineLabel:
              payload['deadline_label']?.toString() ??
              payload['schedule']?.toString() ??
              'Due Thu 17 Apr',
          statusLabel: statusLabel,
          progressLabel: progressLabel,
          scopeLabel:
              payload['audience']?.toString() ??
              payload['scope']?.toString() ??
              'Assigned cohort',
        ),
      );
    _replaceSubject(subject, _cloneSubject(subject, tasks: tasks));
  }

  List<NotificationModel> notificationModelsFor(SessionUser user) {
    return _notifications
        .map(
          (item) => NotificationModel(
            id: int.tryParse(item.id) ?? _numericId(item.id),
            title: item.title,
            body: item.body,
            category: item.courseLabel,
            isRead: item.isRead,
            createdAt: DateTime(2026, 4, 22, 10, 0).toIso8601String(),
          ),
        )
        .toList(growable: false);
  }

  List<WorkspaceNotificationItem> notificationsFor(SessionUser user) =>
      List<WorkspaceNotificationItem>.unmodifiable(_notifications);

  void markNotificationRead(int notificationId) {
    final index = _notifications.indexWhere(
      (item) =>
          (int.tryParse(item.id) ?? _numericId(item.id)) == notificationId,
    );
    if (index == -1) {
      return;
    }
    final current = _notifications[index];
    _notifications[index] = WorkspaceNotificationItem(
      id: current.id,
      title: current.title,
      body: current.body,
      timeLabel: current.timeLabel,
      statusLabel: current.statusLabel,
      courseLabel: current.courseLabel,
      isRead: true,
      icon: current.icon,
    );
  }

  int unreadNotificationsFor(SessionUser user) =>
      _notifications.where((notification) => !notification.isRead).length;

  List<UploadModel> uploadsFor(SessionUser user) =>
      List<UploadModel>.unmodifiable(_uploads);

  void addUpload({
    required String name,
    required String mimeType,
    required int sizeBytes,
  }) {
    final sizeInMb = sizeBytes / (1024 * 1024);
    _uploads.insert(
      0,
      UploadModel(
        id: _nextUploadId++,
        name: name,
        mimeType: mimeType.toUpperCase(),
        sizeLabel: sizeInMb >= 1
            ? '${sizeInMb.toStringAsFixed(1)} MB'
            : '${max(1, (sizeBytes / 1024).round())} KB',
        url: 'mock://uploads/${name.toLowerCase().replaceAll(' ', '-')}',
      ),
    );
  }

  List<ScheduleEventItem> scheduleFor(SessionUser user) =>
      List<ScheduleEventItem>.unmodifiable(_schedule);

  List<ScheduleEventModel> scheduleModelsFor(SessionUser user) {
    return _schedule
        .map(
          (event) => ScheduleEventModel(
            id: _numericId(event.id),
            title: event.title,
            eventType: event.type.label,
            eventDate:
                '${event.startAt.year}-${event.startAt.month.toString().padLeft(2, '0')}-${event.startAt.day.toString().padLeft(2, '0')}',
            colorKey: event.type.name,
            startTime:
                '${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')}',
            endTime:
                '${event.endAt.hour.toString().padLeft(2, '0')}:${event.endAt.minute.toString().padLeft(2, '0')}',
            location: event.location,
          ),
        )
        .toList(growable: false);
  }

  Map<String, List<String>> scheduleConflictsFor(SessionUser user) => const {
    'evt-quiz-se': ['Assessment overlaps with section A2 support coverage.'],
  };

  WorkspaceProfileSnapshot profileFor(SessionUser user) {
    final account = _accountForUser(user);
    final primaryStats = user.isDoctor
        ? <WorkspaceOverviewMetric>[
            WorkspaceOverviewMetric(
              label: 'Active Subjects',
              value: '${subjectsFor(user).length}',
              caption: 'Courses currently under direct supervision',
              icon: Icons.menu_book_rounded,
              color: AppColors.primary,
            ),
            WorkspaceOverviewMetric(
              label: 'Weekly Hours',
              value: '18',
              caption: 'Lectures, office hours, and review time',
              icon: Icons.schedule_rounded,
              color: AppColors.info,
            ),
            WorkspaceOverviewMetric(
              label: 'Students Tracked',
              value: '${studentsFor(user).length * 31}',
              caption: 'Students monitored through mock analytics',
              icon: Icons.groups_rounded,
              color: AppColors.secondary,
            ),
          ]
        : <WorkspaceOverviewMetric>[
            WorkspaceOverviewMetric(
              label: 'Supported Sections',
              value:
                  '${subjectsFor(user).fold<int>(0, (sum, subject) => sum + subject.sections.length)}',
              caption: 'Labs and tutorials currently coordinated',
              icon: Icons.widgets_rounded,
              color: AppColors.primary,
            ),
            WorkspaceOverviewMetric(
              label: 'Weekly Hours',
              value: '16',
              caption: 'Delivery support and student follow-up',
              icon: Icons.schedule_rounded,
              color: AppColors.info,
            ),
            WorkspaceOverviewMetric(
              label: 'Open Tasks',
              value:
                  '${tasksFor(user).where((task) => !task.isPublished).length + 7}',
              caption: 'Drafts and support actions in flight',
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
            ),
          ];

    return WorkspaceProfileSnapshot(
      roleHeadline: user.isDoctor
          ? 'Lead academic delivery across core subjects.'
          : user.isAdmin
          ? 'Coordinate staff operations, visibility, and academic execution.'
          : 'Coordinate sections, support delivery, and keep weekly execution tight.',
      roleSummary: user.isDoctor
          ? 'This profile is tuned for lecture publishing, assessment cadence, and course-level visibility.'
          : user.isAdmin
          ? 'This profile highlights governance, staffing, and operational readiness using the same frontend mock data layer.'
          : 'This profile highlights section readiness, grading support, and student follow-up with local sample data.',
      focusAreas: List<String>.from(
        account?.focusAreas ?? const ['Academic Delivery'],
      ),
      officeHours: account?.officeHours ?? 'Sun - Thu, 09:00 - 15:00',
      locationLabel: account?.locationLabel ?? 'Campus Office',
      phoneLabel: account?.user.phone ?? '+20 100 555 0101',
      primaryStats: primaryStats,
    );
  }

  List<StaffMemberModel> staffMembers() {
    return _accountsByEmail.values
        .map(
          (account) => StaffMemberModel(
            user: account.user,
            departmentName: account.department,
            assignmentSummary: account.user.isAdmin
                ? 'Approvals, staffing, and operational reviews'
                : account.user.isDoctor
                ? 'Lectures, assessments, and subject ownership'
                : 'Sections, grading support, and student follow-up',
          ),
        )
        .toList(growable: false);
  }

  Map<String, dynamic> adminOverview() =>
      Map<String, dynamic>.from(MockSamplePayloads.adminOverview);

  List<String> adminPermissions() =>
      List<String>.from(MockSamplePayloads.adminPermissions);

  List<DepartmentModel> departments() =>
      List<DepartmentModel>.unmodifiable(_departments);

  void toggleStaffActivation(int userId, bool isActive) {
    final account = _accountsByEmail.values.firstWhere(
      (candidate) => candidate.user.id == userId,
      orElse: () => _accountsByEmail.values.first,
    );
    final nextUser = SessionUser(
      id: account.user.id,
      fullName: account.user.fullName,
      universityEmail: account.user.universityEmail,
      roleType: account.user.roleType,
      isActive: isActive,
      avatar: account.user.avatar,
      phone: account.user.phone,
      notificationEnabled: account.user.notificationEnabled,
      language: account.user.language,
      permissions: List<String>.from(account.user.permissions),
    );
    _accountsByEmail[nextUser.universityEmail.toLowerCase()] = account.copyWith(
      user: nextUser,
    );
  }

  List<MockStudentResult> resultsFor(SessionUser user) =>
      List<MockStudentResult>.unmodifiable(_results);

  List<MockAnnouncementItem> announcementsFor(SessionUser user) =>
      List<MockAnnouncementItem>.unmodifiable(_announcements);

  List<MockStudentDirectoryEntry> studentsFor(SessionUser user) =>
      List<MockStudentDirectoryEntry>.unmodifiable(_students);

  List<MockGroupPost> groupPostsFor(SessionUser user) =>
      List<MockGroupPost>.unmodifiable(_groupPosts);

  List<MockMessageThread> messageThreadsFor(SessionUser user) =>
      List<MockMessageThread>.unmodifiable(_messageThreads);

  MockAnalyticsSnapshot analyticsFor(SessionUser user) {
    final averageScore =
        _results.fold<double>(0, (sum, item) => sum + item.percentage) /
        max(1, _results.length);

    return MockAnalyticsSnapshot(
      summary:
          'Mock analytics combine student engagement, grade momentum, and subject health using local fixtures only.',
      kpis: <MockAnalyticsKpi>[
        MockAnalyticsKpi(
          label: 'Avg. Score',
          value: '${averageScore.toStringAsFixed(1)}%',
          deltaLabel: '+4.2 this week',
          tone: 'primary',
        ),
        MockAnalyticsKpi(
          label: 'Attendance',
          value:
              '${(_students.fold<int>(0, (sum, item) => sum + item.attendanceRate) / max(1, _students.length)).round()}%',
          deltaLabel: '+2 pts',
          tone: 'success',
        ),
        MockAnalyticsKpi(
          label: 'High Risk',
          value:
              '${_students.where((item) => item.riskLabel.toLowerCase().contains('risk')).length}',
          deltaLabel: 'Needs follow-up',
          tone: 'warning',
        ),
      ],
      activityTrend: const <MockAnalyticsPoint>[
        MockAnalyticsPoint(label: 'Sat', value: 46),
        MockAnalyticsPoint(label: 'Sun', value: 58),
        MockAnalyticsPoint(label: 'Mon', value: 64),
        MockAnalyticsPoint(label: 'Tue', value: 72),
        MockAnalyticsPoint(label: 'Wed', value: 69),
        MockAnalyticsPoint(label: 'Thu', value: 77),
      ],
      completionTrend: const <MockAnalyticsPoint>[
        MockAnalyticsPoint(label: 'W1', value: 52),
        MockAnalyticsPoint(label: 'W2', value: 61),
        MockAnalyticsPoint(label: 'W3', value: 67),
        MockAnalyticsPoint(label: 'W4', value: 74),
      ],
      subjectPulse: _subjects
          .map(
            (subject) => MockAnalyticsSubjectPulse(
              subjectCode: subject.code,
              subjectName: subject.name,
              healthScore: (subject.progress * 100).round() + 12,
              completionRate: (subject.progress * 100).round(),
              riskLabel: subject.progress >= 0.75
                  ? 'Healthy'
                  : subject.progress >= 0.6
                  ? 'Watch'
                  : 'Needs Attention',
            ),
          )
          .toList(growable: false),
    );
  }

  DashboardSnapshot dashboardFor(SessionUser user) {
    final subjects = subjectsFor(user);
    final lectures = lecturesFor(user);
    final quizzes = quizzesFor(user);
    final tasks = tasksFor(user);
    final unreadNotifications = unreadNotificationsFor(user);
    final analytics = analyticsFor(user);
    final averageScore = _results.isEmpty
        ? 0.0
        : _results.fold<double>(0, (sum, item) => sum + item.percentage) /
              _results.length;
    final riskStudents = studentsFor(user)
        .where((student) => student.riskLabel.toLowerCase().contains('risk'))
        .toList(growable: false);

    final topResults = [..._results]
      ..sort((left, right) => right.percentage.compareTo(left.percentage));

    return DashboardSnapshot.fromJson(<String, dynamic>{
      'header': {
        'user': {
          'id': user.id,
          'name': user.fullName,
          'role': user.roleType.toUpperCase(),
          'greeting': user.isAdmin
              ? 'Operational pulse is steady today'
              : 'Good morning, ${user.fullName.split(' ').first}',
          'subtitle': user.isDoctor
              ? 'You have ${lectures.length} lecture blocks, ${tasks.length} tasks, and $unreadNotifications fresh alerts.'
              : user.isAdmin
              ? 'Staff, courses, and notifications are all running from local mock fixtures.'
              : 'Section coordination is active across ${subjects.length} subjects today.',
          'departments': [
            (_accountForUser(user)?.department ?? 'Computer Science'),
          ],
          'academic_years': subjects
              .map((subject) => subject.academicTerm)
              .take(2)
              .toList(),
        },
        'notification_badge': unreadNotifications,
        'generated_at': DateTime(2026, 4, 22, 10, 30).toIso8601String(),
      },
      'quick_actions': [
        if (user.hasPermission('lectures.create'))
          {
            'id': 'qa-lecture',
            'label': 'Create lecture',
            'description': 'Draft the next lecture block and publish timing.',
            'route': AppRoutes.lectures,
            'permission': 'lectures.create',
            'icon': 'calendar',
            'tone': 'primary',
          },
        if (user.hasPermission('quizzes.create'))
          {
            'id': 'qa-quiz',
            'label': 'Create quiz',
            'description': 'Open a new assessment window for the current week.',
            'route': AppRoutes.quizzes,
            'permission': 'quizzes.create',
            'icon': 'quiz',
            'tone': 'secondary',
          },
        {
          'id': 'qa-results',
          'label': 'Review results',
          'description': 'Check the latest grading and publication status.',
          'route': AppRoutes.results,
          'permission': 'results.view',
          'icon': 'chart',
          'tone': 'success',
        },
      ],
      'action_center': {
        'summary':
            'Three work items need attention before the next delivery cycle.',
        'items': [
          {
            'id': 'action-1',
            'type': 'grading',
            'priority': 'HIGH',
            'title': 'Finalize pending grading',
            'explanation':
                '${tasks.length} assignment milestones still need publication or review.',
            'cta_label': 'Open results',
            'route': AppRoutes.results,
          },
          {
            'id': 'action-2',
            'type': 'alerts',
            'priority': 'MEDIUM',
            'title': 'Respond to unread alerts',
            'explanation':
                '$unreadNotifications alert items are still unread in the workspace.',
            'cta_label': 'Open alerts',
            'route': AppRoutes.notifications,
          },
        ],
      },
      'today_focus': {
        'headline':
            'Keep delivery smooth across lectures, tasks, and support threads.',
        'summary':
            'The frontend is now running against a realistic local academic fixture set, so every dashboard block remains interactive without backend dependencies.',
        'metrics': [
          {
            'label': 'Subjects',
            'value': '${subjects.length}',
            'tone': 'primary',
          },
          {
            'label': 'Live Quizzes',
            'value': '${quizzes.length}',
            'tone': 'secondary',
          },
          {
            'label': 'Uploads',
            'value': '${_uploads.length}',
            'tone': 'success',
          },
        ],
        'primary_action': {
          'id': 'focus-1',
          'type': 'manage',
          'priority': 'HIGH',
          'title': 'Open announcements',
          'explanation':
              'Review pinned updates and active group communication.',
          'cta_label': 'View announcements',
          'route': AppRoutes.announcements,
        },
      },
      'timeline': {
        'groups': [
          {
            'id': 'today',
            'label': 'Today',
            'items': _schedule
                .take(3)
                .map(
                  (event) => {
                    'id': event.id,
                    'type': event.type.name,
                    'title': event.title,
                    'subject_name': event.subject,
                    'when_label':
                        '${event.startAt.hour.toString().padLeft(2, '0')}:${event.startAt.minute.toString().padLeft(2, '0')} - ${event.endAt.hour.toString().padLeft(2, '0')}:${event.endAt.minute.toString().padLeft(2, '0')}',
                    'status': event.status.label,
                    'route': AppRoutes.schedule,
                  },
                )
                .toList(),
          },
        ],
      },
      'subjects_overview': {
        'summary':
            'Each subject reflects realistic cohort size, section load, and health indicators.',
        'items': subjects
            .map(
              (subject) => {
                'id': subject.id,
                'name': subject.name,
                'code': subject.code,
                'department': subject.department,
                'academic_year': subject.academicTerm,
                'batch': '2026',
                'student_count': subject.studentCount,
                'groups_count': subject.sections.length,
                'sections_count': subject.sectionCount,
                'health_score': (subject.progress * 100).round() + 10,
                'risk_level': subject.progress >= 0.75 ? 'LOW' : 'WATCH',
                'quick_actions': [
                  {
                    'label': 'Open',
                    'route': '${AppRoutes.subjects}/${subject.id}',
                  },
                  {'label': 'Announcements', 'route': AppRoutes.announcements},
                ],
              },
            )
            .toList(),
      },
      'students_attention': {
        'count': riskStudents.length,
        'items': riskStudents
            .map(
              (student) => {
                'student_id': _numericId(student.id),
                'name': student.name,
                'reason':
                    '${student.riskLabel} - attendance ${student.attendanceRate}%',
                'severity': 'HIGH',
                'cta_label': 'Review student',
                'route': AppRoutes.students,
                'details': [
                  '${student.subjectCode} / ${student.sectionLabel}',
                  'Engagement score ${student.engagementScore}',
                ],
                'last_seen': student.lastActiveAt.toIso8601String(),
              },
            )
            .toList(),
      },
      'student_activity_insights': {
        'summary':
            'Engagement and grading are derived from the same local student and result fixtures.',
        'active_students': _students
            .where((student) => student.engagementScore >= 70)
            .length,
        'inactive_students': _students
            .where((student) => student.engagementScore < 50)
            .length,
        'missing_submissions': 12,
        'new_comments': 9,
        'unread_messages': _messageThreads.fold<int>(
          0,
          (sum, thread) => sum + thread.unreadCount,
        ),
        'low_engagement_count': _students
            .where((student) => student.engagementScore < 60)
            .length,
        'engagement_rate': 78,
        'students_needing_attention': riskStudents.length,
        'items': riskStudents
            .map(
              (student) => {
                'student_id': _numericId(student.id),
                'name': student.name,
                'reason': 'Low activity trend this week',
                'severity': 'MEDIUM',
                'cta_label': 'Open students',
                'route': AppRoutes.students,
              },
            )
            .toList(),
      },
      'course_health': {
        'overall_score': 84,
        'status': 'HEALTHY',
        'summary':
            'Mock subject health remains strong, with two courses still needing follow-up.',
        'metrics': [
          {'label': 'Completion', 'value': '74%', 'tone': 'primary'},
          {'label': 'Attendance', 'value': '82%', 'tone': 'success'},
          {
            'label': 'Alerts',
            'value': '$unreadNotifications',
            'tone': 'warning',
          },
        ],
        'subjects': subjects
            .map(
              (subject) => {
                'subject_id': subject.id,
                'subject_name': subject.name,
                'score': (subject.progress * 100).round() + 10,
                'status': subject.progress >= 0.75 ? 'HEALTHY' : 'WATCH',
              },
            )
            .toList(),
      },
      'group_activity_feed': {
        'items': _groupPosts
            .map(
              (post) => {
                'id': post.id,
                'activity_type': 'post',
                'subject_name': post.subjectCode,
                'group_name': 'Course groups',
                'author_name': post.authorName,
                'content': post.body,
                'route': AppRoutes.announcements,
                'timestamp': post.createdAt.toIso8601String(),
              },
            )
            .toList(),
      },
      'notifications_preview': {
        'unread_count': unreadNotifications,
        'items': _notifications
            .take(3)
            .map(
              (item) => {
                'id': int.tryParse(item.id) ?? _numericId(item.id),
                'title': item.title,
                'body': item.body,
                'category': item.courseLabel,
                'route': AppRoutes.notifications,
                'time': DateTime(2026, 4, 22, 9, 0).toIso8601String(),
                'is_unread': !item.isRead,
              },
            )
            .toList(),
      },
      'pending_grading': {
        'can_manage': true,
        'count': tasks.length,
        'summary':
            'Assignments and quiz marks can be reviewed locally before real APIs are connected.',
        'items': _results
            .take(3)
            .map(
              (result) => {
                'task_id': _numericId(result.id),
                'title': result.assessmentTitle,
                'subject_name': result.subjectName,
                'pending_count': max(1, (100 - result.percentage).round()),
                'cta_label': 'Review',
                'route': AppRoutes.results,
              },
            )
            .toList(),
      },
      'performance_analytics': {
        'is_limited': false,
        'summary': analytics.summary,
        'average_score': double.parse(averageScore.toStringAsFixed(1)),
        'trend': analytics.activityTrend
            .map((point) => {'label': point.label, 'value': point.value})
            .toList(),
        'top_performers': topResults
            .take(3)
            .map(
              (result) => {
                'student_name': result.studentName,
                'average_score': result.percentage,
              },
            )
            .toList(),
        'low_performers': topResults.reversed
            .take(2)
            .map(
              (result) => {
                'student_name': result.studentName,
                'average_score': result.percentage,
              },
            )
            .toList(),
      },
      'risk_alerts': {
        'count': riskStudents.length,
        'items': riskStudents
            .map(
              (student) => {
                'id': student.id,
                'severity': 'HIGH',
                'title': '${student.name} needs follow-up',
                'explanation':
                    '${student.subjectCode} attendance is ${student.attendanceRate}% with engagement ${student.engagementScore}.',
                'cta_label': 'Open students',
                'route': AppRoutes.students,
              },
            )
            .toList(),
      },
      'weekly_summary': {
        'headline':
            'Frontend-only workspace is ready for realistic review cycles.',
        'items': [
          {'label': 'Subjects', 'value': '${subjects.length}'},
          {'label': 'Results', 'value': '${_results.length}'},
          {'label': 'Threads', 'value': '${_messageThreads.length}'},
        ],
      },
      'smart_suggestions': {
        'items': [
          {
            'id': 'suggest-1',
            'title': 'Open analytics before publishing the next task',
            'explanation':
                'The mock analytics page highlights low-engagement segments you may want to support.',
            'cta_label': 'View analytics',
            'route': AppRoutes.analytics,
          },
          {
            'id': 'suggest-2',
            'title': 'Pin a quick announcement for upcoming deadlines',
            'explanation':
                'Announcements and group posts are ready in the local workspace.',
            'cta_label': 'Open announcements',
            'route': AppRoutes.announcements,
          },
        ],
      },
    });
  }

  void _seed() {
    for (final accountMap in MockSamplePayloads.accounts) {
      final account = _MockAccount.fromJson(accountMap);
      _accountsByEmail[account.user.universityEmail.toLowerCase()] = account;
    }

    _subjects.addAll(
      MockSamplePayloads.teachingSubjects.map(_teachingSubjectFromJson),
    );
    _notifications.addAll(
      MockSamplePayloads.notifications.map(_workspaceNotificationFromJson),
    );
    _schedule.addAll(
      MockSamplePayloads.schedule.map(
        (item) => ScheduleEventItem.fromJson(Map<String, dynamic>.from(item)),
      ),
    );
    _uploads.addAll(
      MockSamplePayloads.uploads.map(
        (item) => UploadModel.fromJson(Map<String, dynamic>.from(item)),
      ),
    );
    _results.addAll(MockSamplePayloads.results.map(_resultFromJson));
    _announcements.addAll(
      MockSamplePayloads.announcements.map(_announcementFromJson),
    );
    _students.addAll(MockSamplePayloads.students.map(_studentFromJson));
    _groupPosts.addAll(MockSamplePayloads.groupPosts.map(_groupPostFromJson));
    _messageThreads.addAll(
      MockSamplePayloads.messageThreads.map(_messageThreadFromJson),
    );
    _departments.addAll(
      MockSamplePayloads.departments.map(
        (item) => DepartmentModel.fromJson(Map<String, dynamic>.from(item)),
      ),
    );
  }

  _MockAccount? _accountForUser(SessionUser user) {
    return _accountsByEmail[user.universityEmail.toLowerCase()];
  }

  TeachingSubject _subjectForPayload(String? value) {
    final needle = value?.trim().toLowerCase();
    if (needle == null || needle.isEmpty) {
      return _subjects.first;
    }

    return _subjects.firstWhere(
      (subject) =>
          subject.name.toLowerCase().contains(needle) ||
          subject.code.toLowerCase().contains(needle),
      orElse: () => _subjects.first,
    );
  }

  void _replaceSubject(TeachingSubject current, TeachingSubject next) {
    final index = _subjects.indexWhere((subject) => subject.id == current.id);
    if (index != -1) {
      _subjects[index] = next;
    }
  }

  TeachingSubject _cloneSubject(
    TeachingSubject source, {
    List<TeachingLecture>? lectures,
    List<TeachingSection>? sections,
    List<TeachingQuiz>? quizzes,
    List<TeachingTask>? tasks,
  }) {
    return TeachingSubject(
      id: source.id,
      code: source.code,
      name: source.name,
      department: source.department,
      academicTerm: source.academicTerm,
      description: source.description,
      studentCount: source.studentCount,
      sectionCount: source.sectionCount,
      progress: source.progress,
      accentColor: source.accentColor,
      lectures: lectures ?? source.lectures,
      sections: sections ?? source.sections,
      quizzes: quizzes ?? source.quizzes,
      tasks: tasks ?? source.tasks,
    );
  }

  String _ownerNameForSubject(int subjectId) {
    final subject = subjectById(subjectId);
    if (subject.department == 'Computer Science') {
      return 'Dr. Salma Hassan';
    }
    if (subject.department == 'Information Systems') {
      return 'Dr. Khaled Mostafa';
    }
    return 'Dr. Hala Ezz';
  }

  String _roomFromNotes(String? notes) {
    final trimmed = notes?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Room to be confirmed';
    }
    return trimmed.length > 32 ? '${trimmed.substring(0, 32)}...' : trimmed;
  }

  TeachingSubject _teachingSubjectFromJson(Map<String, dynamic> json) {
    return TeachingSubject(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      academicTerm: json['academic_term']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      studentCount: (json['student_count'] as num?)?.toInt() ?? 0,
      sectionCount: (json['section_count'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      accentColor: Color((json['accent_color'] as num?)?.toInt() ?? 0xFF2563EB),
      lectures: (json['lectures'] as List? ?? const [])
          .map(
            (item) => TeachingLecture(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              audience: item['audience']?.toString() ?? '',
              dayLabel: item['day_label']?.toString() ?? '',
              timeLabel: item['time_label']?.toString() ?? '',
              room: item['room']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              weekLabel: item['week_label']?.toString() ?? '',
            ),
          )
          .toList(growable: false),
      sections: (json['sections'] as List? ?? const [])
          .map(
            (item) => TeachingSection(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              assistantName: item['assistant_name']?.toString() ?? '',
              dayLabel: item['day_label']?.toString() ?? '',
              timeLabel: item['time_label']?.toString() ?? '',
              room: item['room']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              groupLabel: item['group_label']?.toString() ?? '',
            ),
          )
          .toList(growable: false),
      quizzes: (json['quizzes'] as List? ?? const [])
          .map(
            (item) => TeachingQuiz(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              windowLabel: item['window_label']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              attemptsLabel: item['attempts_label']?.toString() ?? '',
              scopeLabel: item['scope_label']?.toString() ?? '',
            ),
          )
          .toList(growable: false),
      tasks: (json['tasks'] as List? ?? const [])
          .map(
            (item) => TeachingTask(
              id: item['id']?.toString() ?? '',
              title: item['title']?.toString() ?? '',
              deadlineLabel: item['deadline_label']?.toString() ?? '',
              statusLabel: item['status_label']?.toString() ?? '',
              progressLabel: item['progress_label']?.toString() ?? '',
              scopeLabel: item['scope_label']?.toString() ?? '',
            ),
          )
          .toList(growable: false),
    );
  }

  WorkspaceNotificationItem _workspaceNotificationFromJson(
    Map<String, dynamic> json,
  ) {
    final category = json['category']?.toString() ?? '';
    return WorkspaceNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      timeLabel: _relativeTime(_dateTime(json['created_at'])),
      statusLabel: json['status_label']?.toString() ?? '',
      courseLabel: json['course_label']?.toString() ?? '',
      isRead: json['is_read'] == true,
      icon: switch (category) {
        'schedule' => Icons.meeting_room_rounded,
        'quiz' => Icons.quiz_rounded,
        'attendance' => Icons.check_circle_outline_rounded,
        'task' => Icons.assignment_late_rounded,
        _ => Icons.notifications_active_rounded,
      },
    );
  }

  MockStudentResult _resultFromJson(Map<String, dynamic> json) {
    return MockStudentResult(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      studentCode: json['student_code']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      assessmentTitle: json['assessment_title']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
      statusLabel: json['status_label']?.toString() ?? '',
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  MockAnnouncementItem _announcementFromJson(Map<String, dynamic> json) {
    return MockAnnouncementItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      audienceLabel: json['audience_label']?.toString() ?? '',
      priorityLabel: json['priority_label']?.toString() ?? '',
      isPinned: json['is_pinned'] == true,
      publishedAt: _dateTime(json['published_at']),
      authorName: json['author_name']?.toString() ?? '',
    );
  }

  MockStudentDirectoryEntry _studentFromJson(Map<String, dynamic> json) {
    return MockStudentDirectoryEntry(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      sectionLabel: json['section_label']?.toString() ?? '',
      attendanceRate: (json['attendance_rate'] as num?)?.toInt() ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
      engagementScore: (json['engagement_score'] as num?)?.toInt() ?? 0,
      riskLabel: json['risk_label']?.toString() ?? '',
      lastActiveAt: _dateTime(json['last_active_at']),
    );
  }

  MockGroupPost _groupPostFromJson(Map<String, dynamic> json) {
    return MockGroupPost(
      id: json['id']?.toString() ?? '',
      subjectCode: json['subject_code']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      reactionsCount: (json['reactions_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      createdAt: _dateTime(json['created_at']),
    );
  }

  MockMessageThread _messageThreadFromJson(Map<String, dynamic> json) {
    return MockMessageThread(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      participantsLabel: json['participants_label']?.toString() ?? '',
      lastMessage: json['last_message']?.toString() ?? '',
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  int _numericId(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? raw.hashCode.abs();
  }

  int _weekNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 1;
  }

  String _leadingWord(String? raw, {required String fallback}) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value.split(' ').first;
  }

  DateTime _dateTime(Object? raw) {
    return DateTime.tryParse(raw?.toString() ?? '') ?? DateTime(2026, 4, 22);
  }

  String _relativeTime(DateTime dateTime) {
    final difference = DateTime(2026, 4, 22, 10, 30).difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }
    return '${difference.inDays} day ago';
  }
}

class _MockAccount {
  const _MockAccount({
    required this.user,
    required this.password,
    required this.department,
    required this.officeHours,
    required this.locationLabel,
    required this.focusAreas,
  });

  final SessionUser user;
  final String password;
  final String department;
  final String officeHours;
  final String locationLabel;
  final List<String> focusAreas;

  factory _MockAccount.fromJson(Map<String, dynamic> json) {
    return _MockAccount(
      user: SessionUser.fromJson(json),
      password: json['password']?.toString() ?? '',
      department: json['department']?.toString() ?? 'Computer Science',
      officeHours:
          json['office_hours']?.toString() ?? 'Sun - Thu, 09:00 - 15:00',
      locationLabel: json['location_label']?.toString() ?? 'Campus Office',
      focusAreas: (json['focus_areas'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  _MockAccount copyWith({
    SessionUser? user,
    String? locationLabel,
    String? officeHours,
  }) {
    return _MockAccount(
      user: user ?? this.user,
      password: password,
      department: department,
      officeHours: officeHours ?? this.officeHours,
      locationLabel: locationLabel ?? this.locationLabel,
      focusAreas: focusAreas,
    );
  }
}
