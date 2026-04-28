import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/student_profile.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/formatters.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../data/repositories/mock_home_repository.dart';

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) {
  return ref.watch(homeRepositoryProvider).fetchDashboard();
});

final studentHomeViewModelProvider = Provider<AsyncValue<StudentHomeViewModel>>(
  (ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final notifications = ref.watch(notificationsStreamProvider).value;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return dashboardAsync.whenData(
      (dashboard) => StudentHomeViewModel.fromDashboard(
        dashboard,
        notifications: notifications ?? dashboard.notifications,
        unreadCount: unreadCount,
      ),
    );
  },
);

class StudentHomeViewModel {
  StudentHomeViewModel({
    required this.profile,
    required this.unreadCount,
    required this.quickActions,
    required this.requiredTodayItems,
    required this.timelineGroups,
    required this.academicSnapshot,
    required this.todayLecturesCount,
    required this.availableQuizzesCount,
    required this.importantAnnouncementsCount,
    required this.overallProgress,
    required this.averageGrade,
    required this.courseActivities,
    required this.upcomingQuizzes,
    required this.nearbyTasks,
    required this.notificationsPreview,
    required this.studyInsights,
    required this.dailyTip,
  });

  factory StudentHomeViewModel.fromDashboard(
    HomeDashboardData dashboard, {
    required List<AppNotificationItem> notifications,
    required int unreadCount,
  }) {
    final now = DateTime.now();
    final lectures = [...dashboard.upcomingLectures]
      ..sort((a, b) => _compareDates(a.startsAt, b.startsAt));
    final sections = [...dashboard.upcomingSections]
      ..sort((a, b) => _compareDates(a.startsAt, b.startsAt));
    final quizzes = [...dashboard.upcomingQuizzes]
      ..sort((a, b) => _compareDates(a.startsAt, b.startsAt));
    final tasks = [...dashboard.tasks]
      ..sort((a, b) => _compareDates(a.dueAt, b.dueAt));

    final nextLecture = lectures.cast<LectureItem?>().firstWhere(
      (lecture) => lecture?.startsAt?.isAfter(now) ?? false,
      orElse: () => null,
    );
    final nextSection = sections.cast<SectionItem?>().firstWhere(
      (section) => section?.startsAt?.isAfter(now) ?? false,
      orElse: () => null,
    );
    final openQuiz = quizzes.cast<QuizItem?>().firstWhere(
      (quiz) => _isQuizOpen(quiz, now),
      orElse: () => null,
    );
    final nearestTaskDeadline = tasks.cast<TaskItem?>().firstWhere(
      (task) =>
          task?.isCompleted == false &&
          task?.dueAt != null &&
          task!.dueAt!.isAfter(now),
      orElse: () => null,
    );
    final missingTask = tasks.cast<TaskItem?>().firstWhere(
      (task) => task?.isMissingSubmission == true,
      orElse: () => null,
    );

    final timelineItems = _buildTimelineItems(
      lectures: lectures,
      sections: sections,
      quizzes: quizzes,
      tasks: tasks,
      now: now,
    );

    final totalTasks =
        dashboard.studyInsights.completedTasks +
        dashboard.studyInsights.pendingTasks;
    final todayLecturesCount = lectures.where((lecture) {
      final startsAt = lecture.startsAt;
      return startsAt != null && _isSameDate(startsAt, now);
    }).length;
    final availableQuizzesCount = quizzes
        .where((quiz) => _isQuizOpen(quiz, now))
        .length;
    final importantAnnouncementsCount = notifications
        .where((notification) => notification.isImportant)
        .length;
    final overallProgress = dashboard.subjects.isEmpty
        ? 0.0
        : dashboard.subjects
                  .map((subject) => subject.progress)
                  .reduce((a, b) => a + b) /
              dashboard.subjects.length;
    final averageGrade = (dashboard.profile.gpa / 4 * 100).clamp(0, 100);
    final delayedSubjects = dashboard.subjects
        .where((subject) => subject.status == 'مطلوب تسليم')
        .toList();
    final academicTips = _buildAcademicTips(
      dashboard: dashboard,
      openQuiz: openQuiz,
      missingTask: missingTask,
    );

    return StudentHomeViewModel(
      profile: dashboard.profile,
      unreadCount: unreadCount,
      quickActions: [
        const StudentQuickActionItem(
          type: StudentQuickActionType.viewTimetable,
          target: StudentActionTarget(routeName: RouteNames.timetable),
          helperText: 'اليوم وغدًا وهذا الأسبوع',
        ),
        StudentQuickActionItem(
          type: StudentQuickActionType.openQuiz,
          target: openQuiz != null
              ? _quizTarget(openQuiz)
              : const StudentActionTarget(routeName: RouteNames.quizzes),
          helperText: openQuiz != null
              ? 'يوجد كويز متاح الآن'
              : 'راجعي الكويزات القادمة',
        ),
        StudentQuickActionItem(
          type: StudentQuickActionType.uploadAssignment,
          target: missingTask != null
              ? _assignmentTarget(missingTask)
              : nearestTaskDeadline != null
              ? _assignmentTarget(nearestTaskDeadline)
              : null,
          helperText: missingTask != null
              ? 'لديك شيت يحتاج إلى رفع'
              : nearestTaskDeadline != null
              ? nearestTaskDeadline.title
              : 'لا يوجد رفع عاجل الآن',
        ),
        StudentQuickActionItem(
          type: StudentQuickActionType.openCourse,
          target: nextLecture != null
              ? _subjectTarget(nextLecture.subjectId)
              : dashboard.subjects.isEmpty
              ? null
              : _subjectTarget(dashboard.subjects.first.id),
          helperText:
              nextLecture?.subjectName ?? dashboard.subjects.firstOrNull?.name,
        ),
        const StudentQuickActionItem(
          type: StudentQuickActionType.latestAnnouncement,
          target: StudentActionTarget(routeName: RouteNames.notifications),
          helperText: 'آخر إعلان رسمي',
        ),
      ],
      requiredTodayItems: [
        StudentRequiredActionItem(
          title: 'المحاضرة التالية',
          subtitle: nextLecture == null
              ? 'لا توجد محاضرات قريبة'
              : '${nextLecture.title} - ${nextLecture.subjectName}',
          meta: nextLecture == null
              ? 'لا يوجد'
              : formatTimeUntilArabic(nextLecture.startsAt, reference: now),
          ctaLabel: 'دخول',
          target: nextLecture == null
              ? null
              : _subjectTarget(nextLecture.subjectId),
          priority: nextLecture == null
              ? StudentPriority.safe
              : StudentPriority.soon,
          icon: Icons.play_circle_outline_rounded,
        ),
        StudentRequiredActionItem(
          title: 'السكشن القادم',
          subtitle: nextSection == null
              ? 'لا يوجد سكشن قريب'
              : '${nextSection.title} - ${nextSection.subjectName}',
          meta: nextSection == null
              ? 'لا يوجد'
              : formatTimeUntilArabic(nextSection.startsAt, reference: now),
          ctaLabel: 'عرض',
          target: nextSection == null
              ? null
              : _subjectTarget(nextSection.subjectId),
          priority: nextSection == null
              ? StudentPriority.safe
              : StudentPriority.soon,
          icon: Icons.co_present_outlined,
        ),
        StudentRequiredActionItem(
          title: 'الكويز المفتوح',
          subtitle: openQuiz == null
              ? 'لا يوجد كويز مفتوح حاليًا'
              : '${openQuiz.title} - ${openQuiz.subjectName}',
          meta: openQuiz == null
              ? 'مغلق الآن'
              : 'يغلق ${formatTimeUntilArabic(openQuiz.closesAt, reference: now)}',
          ctaLabel: 'فتح',
          target: openQuiz == null
              ? const StudentActionTarget(routeName: RouteNames.quizzes)
              : _quizTarget(openQuiz),
          priority: openQuiz == null
              ? StudentPriority.safe
              : StudentPriority.urgent,
          icon: Icons.quiz_outlined,
        ),
        StudentRequiredActionItem(
          title: 'أقرب موعد تسليم',
          subtitle: nearestTaskDeadline == null
              ? 'لا يوجد تسليم قريب'
              : '${nearestTaskDeadline.title} - ${nearestTaskDeadline.subjectName}',
          meta: nearestTaskDeadline == null
              ? 'ممتاز'
              : formatTimeUntilArabic(
                  nearestTaskDeadline.dueAt,
                  reference: now,
                ),
          ctaLabel: 'رفع',
          target: nearestTaskDeadline == null
              ? null
              : _assignmentTarget(nearestTaskDeadline),
          priority: nearestTaskDeadline == null
              ? StudentPriority.safe
              : _priorityFromDate(nearestTaskDeadline.dueAt, now),
          icon: Icons.upload_file_outlined,
        ),
        StudentRequiredActionItem(
          title: 'مهام ناقصة',
          subtitle: missingTask == null
              ? 'لا يوجد تأخير حالي'
              : '${missingTask.title} تحتاج إلى رفع الآن',
          meta: missingTask == null ? 'مستقر' : 'متأخر',
          ctaLabel: 'عرض',
          target: missingTask == null ? null : _assignmentTarget(missingTask),
          priority: missingTask == null
              ? StudentPriority.safe
              : StudentPriority.urgent,
          icon: Icons.warning_amber_rounded,
        ),
      ],
      timelineGroups: _groupTimelineItems(timelineItems),
      academicSnapshot: StudentAcademicSnapshot(
        gpa: dashboard.profile.gpa,
        courseCount: dashboard.subjects.length,
        completedTasks: dashboard.studyInsights.completedTasks,
        pendingTasks: dashboard.studyInsights.pendingTasks,
        viewedLectures: dashboard.studyInsights.viewedLectures,
        engagementSummary: dashboard.studyInsights.engagementLabel,
        academicStatus: dashboard.profile.academicStatus,
      ),
      todayLecturesCount: todayLecturesCount,
      availableQuizzesCount: availableQuizzesCount,
      importantAnnouncementsCount: importantAnnouncementsCount,
      overallProgress: overallProgress,
      averageGrade: averageGrade.toDouble(),
      courseActivities: [...dashboard.courseActivities]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      upcomingQuizzes: quizzes
          .where(
            (quiz) =>
                !quiz.isSubmitted && (quiz.startsAt?.isAfter(now) ?? false),
          )
          .take(3)
          .map(
            (quiz) => StudentUpcomingItem(
              title: quiz.title,
              subtitle: quiz.subjectName ?? quiz.typeLabel,
              meta: quiz.startAtLabel,
              auxiliary: quiz.durationLabel,
              kind: StudentUpcomingKind.quiz,
              target: _quizTarget(quiz),
            ),
          )
          .toList(),
      nearbyTasks: tasks
          .where(
            (task) => !task.isCompleted && (task.dueAt?.isAfter(now) ?? false),
          )
          .take(3)
          .map(
            (task) => StudentUpcomingItem(
              title: task.title,
              subtitle: task.subjectName ?? task.status,
              meta: task.dueDateLabel,
              auxiliary: task.gradeLabel ?? task.status,
              kind: StudentUpcomingKind.task,
              target: _assignmentTarget(task),
            ),
          )
          .toList(),
      notificationsPreview: notifications.take(3).toList(),
      studyInsights: StudentStudyInsightsModel(
        headline: totalTasks == 0
            ? 'ابدئي أسبوعك بخطة واضحة'
            : 'أكملت ${dashboard.studyInsights.completedTasks} من $totalTasks مهام هذا الأسبوع',
        summary: delayedSubjects.isNotEmpty
            ? 'تحتاج ${delayedSubjects.first.name} إلى تركيز أكبر بسبب قرب التسليمات.'
            : 'أداؤك جيد، ووتيرة الإنجاز مستقرة هذا الأسبوع.',
        completedTasks: dashboard.studyInsights.completedTasks,
        pendingTasks: dashboard.studyInsights.pendingTasks,
        viewedLectures: dashboard.studyInsights.viewedLectures,
        engagementLabel: dashboard.studyInsights.engagementLabel,
        engagementScore: dashboard.studyInsights.engagementScore,
        tips: academicTips,
      ),
      dailyTip:
          academicTips.firstOrNull ??
          'رتّبي أولويتك بين الكويزات والتسليمات قبل بدء يومك الدراسي.',
    );
  }

  final StudentProfile profile;
  final int unreadCount;
  final List<StudentQuickActionItem> quickActions;
  final List<StudentRequiredActionItem> requiredTodayItems;
  final List<StudentTimelineGroup> timelineGroups;
  final StudentAcademicSnapshot academicSnapshot;
  final int todayLecturesCount;
  final int availableQuizzesCount;
  final int importantAnnouncementsCount;
  final double overallProgress;
  final double averageGrade;
  final List<CourseActivityItem> courseActivities;
  final List<StudentUpcomingItem> upcomingQuizzes;
  final List<StudentUpcomingItem> nearbyTasks;
  final List<AppNotificationItem> notificationsPreview;
  final StudentStudyInsightsModel studyInsights;
  final String dailyTip;
}

class StudentQuickActionItem {
  const StudentQuickActionItem({
    required this.type,
    required this.target,
    this.helperText,
  });

  final StudentQuickActionType type;
  final StudentActionTarget? target;
  final String? helperText;

  bool get isEnabled => target != null;
}

enum StudentQuickActionType {
  viewTimetable,
  openQuiz,
  uploadAssignment,
  openCourse,
  checkResults,
  latestAnnouncement,
}

class StudentRequiredActionItem {
  const StudentRequiredActionItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.ctaLabel,
    required this.target,
    required this.priority,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String ctaLabel;
  final StudentActionTarget? target;
  final StudentPriority priority;
  final IconData icon;
}

class StudentActionTarget {
  const StudentActionTarget({
    required this.routeName,
    this.pathParameters = const {},
  });

  final String routeName;
  final Map<String, String> pathParameters;
}

class StudentTimelineGroup {
  const StudentTimelineGroup({required this.title, required this.items});

  final String title;
  final List<StudentTimelineItem> items;
}

class StudentTimelineItem {
  const StudentTimelineItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.scheduledAt,
    required this.kind,
    required this.priority,
    this.target,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final DateTime? scheduledAt;
  final StudentTimelineKind kind;
  final StudentPriority priority;
  final StudentActionTarget? target;
}

enum StudentTimelineKind { lecture, section, quiz, task }

class StudentUpcomingItem {
  const StudentUpcomingItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.auxiliary,
    required this.kind,
    required this.target,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String auxiliary;
  final StudentUpcomingKind kind;
  final StudentActionTarget target;
}

enum StudentUpcomingKind { quiz, task }

class StudentAcademicSnapshot {
  const StudentAcademicSnapshot({
    required this.gpa,
    required this.courseCount,
    required this.completedTasks,
    required this.pendingTasks,
    required this.viewedLectures,
    required this.engagementSummary,
    required this.academicStatus,
  });

  final double gpa;
  final int courseCount;
  final int completedTasks;
  final int pendingTasks;
  final int viewedLectures;
  final String engagementSummary;
  final String academicStatus;
}

class StudentStudyInsightsModel {
  const StudentStudyInsightsModel({
    required this.headline,
    required this.summary,
    required this.completedTasks,
    required this.pendingTasks,
    required this.viewedLectures,
    required this.engagementLabel,
    required this.engagementScore,
    required this.tips,
  });

  final String headline;
  final String summary;
  final int completedTasks;
  final int pendingTasks;
  final int viewedLectures;
  final String engagementLabel;
  final double engagementScore;
  final List<String> tips;
}

enum StudentPriority { urgent, soon, safe }

List<StudentTimelineItem> _buildTimelineItems({
  required List<LectureItem> lectures,
  required List<SectionItem> sections,
  required List<QuizItem> quizzes,
  required List<TaskItem> tasks,
  required DateTime now,
}) {
  final items = <StudentTimelineItem>[
    ...lectures
        .where((lecture) => lecture.startsAt?.isAfter(now) ?? false)
        .map(
          (lecture) => StudentTimelineItem(
            title: lecture.title,
            subtitle: lecture.subjectName ?? 'محاضرة',
            timeLabel: lecture.scheduleLabel,
            scheduledAt: lecture.startsAt,
            kind: StudentTimelineKind.lecture,
            priority: _priorityFromDate(lecture.startsAt, now),
            target: _subjectTarget(lecture.subjectId),
          ),
        ),
    ...sections
        .where((section) => section.startsAt?.isAfter(now) ?? false)
        .map(
          (section) => StudentTimelineItem(
            title: section.title,
            subtitle: section.subjectName ?? section.assistantName,
            timeLabel: section.scheduleLabel,
            scheduledAt: section.startsAt,
            kind: StudentTimelineKind.section,
            priority: _priorityFromDate(section.startsAt, now),
            target: _subjectTarget(section.subjectId),
          ),
        ),
    ...quizzes
        .where(
          (quiz) =>
              (quiz.startsAt?.isAfter(now) ?? false) || _isQuizOpen(quiz, now),
        )
        .map(
          (quiz) => StudentTimelineItem(
            title: quiz.title,
            subtitle: quiz.subjectName ?? quiz.typeLabel,
            timeLabel: _isQuizOpen(quiz, now)
                ? 'مفتوح الآن'
                : quiz.startAtLabel,
            scheduledAt: quiz.startsAt,
            kind: StudentTimelineKind.quiz,
            priority: _isQuizOpen(quiz, now)
                ? StudentPriority.urgent
                : _priorityFromDate(quiz.startsAt, now),
            target: _quizTarget(quiz),
          ),
        ),
    ...tasks
        .where(
          (task) => !task.isCompleted && (task.dueAt?.isAfter(now) ?? false),
        )
        .map(
          (task) => StudentTimelineItem(
            title: task.title,
            subtitle: task.subjectName ?? task.status,
            timeLabel: task.dueDateLabel,
            scheduledAt: task.dueAt,
            kind: StudentTimelineKind.task,
            priority: _priorityFromDate(task.dueAt, now),
            target: _assignmentTarget(task),
          ),
        ),
  ];

  items.sort((a, b) => _compareDates(a.scheduledAt, b.scheduledAt));
  return items;
}

List<StudentTimelineGroup> _groupTimelineItems(
  List<StudentTimelineItem> items,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayItems = <StudentTimelineItem>[];
  final tomorrowItems = <StudentTimelineItem>[];
  final weekItems = <StudentTimelineItem>[];

  for (final item in items) {
    final referenceDate = item.scheduledAt;
    if (referenceDate == null) {
      weekItems.add(item);
      continue;
    }

    final targetDay = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final difference = targetDay.difference(today).inDays;

    if (difference <= 0) {
      todayItems.add(item);
    } else if (difference == 1) {
      tomorrowItems.add(item);
    } else {
      weekItems.add(item);
    }
  }

  return [
    if (todayItems.isNotEmpty)
      StudentTimelineGroup(title: 'اليوم', items: todayItems),
    if (tomorrowItems.isNotEmpty)
      StudentTimelineGroup(title: 'غدًا', items: tomorrowItems),
    if (weekItems.isNotEmpty)
      StudentTimelineGroup(title: 'هذا الأسبوع', items: weekItems),
  ];
}

StudentPriority _priorityFromDate(DateTime? date, DateTime now) {
  if (date == null) {
    return StudentPriority.safe;
  }

  final hours = date.difference(now).inHours;
  if (hours <= 12) {
    return StudentPriority.urgent;
  }
  if (hours <= 48) {
    return StudentPriority.soon;
  }
  return StudentPriority.safe;
}

List<String> _buildAcademicTips({
  required HomeDashboardData dashboard,
  required QuizItem? openQuiz,
  required TaskItem? missingTask,
}) {
  final weakestSubject = [...dashboard.subjects]
    ..sort((a, b) => a.progress.compareTo(b.progress));

  return [
    if (missingTask != null) 'لديك تأخر في تسليم "${missingTask.title}".',
    if (openQuiz != null) 'لديك كويز اليوم في ${openQuiz.subjectName}.',
    if (dashboard.studyInsights.engagementScore >= 0.8)
      'أداؤك جيد هذا الأسبوع واستمرارك ممتاز.',
    if (weakestSubject.isNotEmpty)
      'راجعي مادة ${weakestSubject.first.name} اليوم لأنها الأقل تقدمًا لديك.',
  ];
}

bool _isQuizOpen(QuizItem? quiz, DateTime now) {
  if (quiz?.startsAt == null || quiz?.closesAt == null || quiz!.isSubmitted) {
    return false;
  }

  return !quiz.startsAt!.isAfter(now) && quiz.closesAt!.isAfter(now);
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

StudentActionTarget _subjectTarget(String subjectId) {
  return StudentActionTarget(
    routeName: RouteNames.subjectDetails,
    pathParameters: {'subjectId': subjectId},
  );
}

StudentActionTarget _quizTarget(QuizItem quiz) {
  return StudentActionTarget(
    routeName: RouteNames.quizEntry,
    pathParameters: {'subjectId': quiz.subjectId, 'quizId': quiz.id},
  );
}

StudentActionTarget _assignmentTarget(TaskItem task) {
  return StudentActionTarget(
    routeName: RouteNames.assignmentUpload,
    pathParameters: {'subjectId': task.subjectId, 'taskId': task.id},
  );
}

int _compareDates(DateTime? first, DateTime? second) {
  if (first == null && second == null) {
    return 0;
  }
  if (first == null) {
    return 1;
  }
  if (second == null) {
    return -1;
  }
  return first.compareTo(second);
}

extension ListFirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
