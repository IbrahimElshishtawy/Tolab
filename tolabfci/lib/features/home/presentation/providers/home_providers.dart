import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/models/student_profile.dart';
import '../../../../core/models/subject_models.dart';
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
    required this.courseCount,
    required this.quickActions,
    required this.todayFocus,
    required this.timelineGroups,
    required this.upcomingLectures,
    required this.upcomingQuizzes,
    required this.deadlines,
    required this.courseActivities,
    required this.notificationsPreview,
    required this.studyInsights,
  });

  factory StudentHomeViewModel.fromDashboard(
    HomeDashboardData dashboard, {
    required List<AppNotificationItem> notifications,
    required int unreadCount,
  }) {
    final now = DateTime.now();
    final lectures = [...dashboard.upcomingLectures]
      ..sort((a, b) => _compareDates(a.startsAt, b.startsAt));
    final quizzes = [...dashboard.upcomingQuizzes]
      ..sort((a, b) => _compareDates(a.startsAt, b.startsAt));
    final tasks = [...dashboard.tasks]
      ..sort((a, b) => _compareDates(a.dueAt, b.dueAt));

    final nextLecture = lectures.cast<LectureItem?>().firstWhere(
      (lecture) => lecture?.startsAt?.isAfter(now) ?? false,
      orElse: () => null,
    );
    final openQuiz = quizzes.cast<QuizItem?>().firstWhere(
      (quiz) => _isQuizOpen(quiz, now),
      orElse: () => null,
    );
    final nextQuiz = quizzes.cast<QuizItem?>().firstWhere(
      (quiz) =>
          (quiz?.startsAt?.isAfter(now) ?? false) && !_isQuizOpen(quiz, now),
      orElse: () => null,
    );
    final nearestTaskDeadline = tasks.cast<TaskItem?>().firstWhere(
      (task) =>
          task?.isCompleted == false &&
          task?.dueAt != null &&
          task!.dueAt!.isAfter(now),
      orElse: () => null,
    );

    final timelineItems = _buildTimelineItems(
      lectures: lectures,
      quizzes: quizzes,
      tasks: tasks,
      now: now,
    );

    final deadlineItems = _buildDeadlineItems(
      quizzes: quizzes,
      tasks: tasks,
      now: now,
    );

    final studySummary =
        'You completed ${dashboard.studyInsights.completedTasks}/${dashboard.studyInsights.completedTasks + dashboard.studyInsights.pendingTasks} tasks this week';

    return StudentHomeViewModel(
      profile: dashboard.profile,
      unreadCount: unreadCount,
      courseCount: dashboard.subjects.length,
      quickActions: [
        StudentQuickActionItem(
          type: StudentQuickActionType.joinLecture,
          target: nextLecture == null
              ? null
              : _subjectTarget(nextLecture.subjectId),
          helperText: nextLecture == null
              ? 'No lecture queued'
              : _timeUntil(nextLecture.startsAt, now),
        ),
        StudentQuickActionItem(
          type: StudentQuickActionType.openQuiz,
          target: openQuiz != null
              ? _quizTarget(openQuiz)
              : nextQuiz == null
              ? null
              : _quizTarget(nextQuiz),
          helperText: openQuiz != null
              ? 'Open now'
              : nextQuiz == null
              ? 'No active quiz'
              : 'Next up',
        ),
        const StudentQuickActionItem(
          type: StudentQuickActionType.viewSchedule,
          target: StudentActionTarget(routeName: RouteNames.subjects),
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
          type: StudentQuickActionType.checkResults,
          target: StudentActionTarget(routeName: RouteNames.results),
        ),
      ],
      todayFocus: _buildTodayFocus(
        now: now,
        openQuiz: openQuiz,
        nextLecture: nextLecture,
        nearestTaskDeadline: nearestTaskDeadline,
      ),
      timelineGroups: _groupTimelineItems(timelineItems),
      upcomingLectures: lectures
          .map(
            (lecture) => StudentLectureCardModel(
              lecture: lecture,
              isNext: nextLecture?.id == lecture.id,
              statusLabel: lecture.isOnline ? 'Online' : 'On campus',
              timeLabel: lecture.scheduleLabel,
              target: _subjectTarget(lecture.subjectId),
            ),
          )
          .toList(),
      upcomingQuizzes: quizzes
          .map(
            (quiz) => StudentQuizCardModel(
              quiz: quiz,
              isOpen: _isQuizOpen(quiz, now),
              statusLabel: _isQuizOpen(quiz, now) ? 'Open' : 'Upcoming',
              timeLabel: quiz.startAtLabel,
              target: _quizTarget(quiz),
            ),
          )
          .toList(),
      deadlines: deadlineItems,
      courseActivities: [...dashboard.courseActivities]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      notificationsPreview: notifications.take(3).toList(),
      studyInsights: StudentStudyInsightsModel(
        summary: studySummary,
        completedTasks: dashboard.studyInsights.completedTasks,
        pendingTasks: dashboard.studyInsights.pendingTasks,
        viewedLectures: dashboard.studyInsights.viewedLectures,
        engagementLabel: dashboard.studyInsights.engagementLabel,
        engagementScore: dashboard.studyInsights.engagementScore,
      ),
    );
  }

  final StudentProfile profile;
  final int unreadCount;
  final int courseCount;
  final List<StudentQuickActionItem> quickActions;
  final StudentTodayFocusModel todayFocus;
  final List<StudentTimelineGroup> timelineGroups;
  final List<StudentLectureCardModel> upcomingLectures;
  final List<StudentQuizCardModel> upcomingQuizzes;
  final List<StudentDeadlineItem> deadlines;
  final List<CourseActivityItem> courseActivities;
  final List<AppNotificationItem> notificationsPreview;
  final StudentStudyInsightsModel studyInsights;
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
  joinLecture,
  openQuiz,
  viewSchedule,
  openCourse,
  checkResults,
}

class StudentTodayFocusModel {
  const StudentTodayFocusModel({
    required this.state,
    required this.title,
    required this.message,
    required this.highlights,
    this.primaryCta,
    this.secondaryCta,
  });

  final StudentTodayFocusState state;
  final String title;
  final String message;
  final List<StudentTodayHighlight> highlights;
  final StudentActionCta? primaryCta;
  final StudentActionCta? secondaryCta;
}

enum StudentTodayFocusState { urgent, busy, empty }

class StudentTodayHighlight {
  const StudentTodayHighlight({
    required this.label,
    required this.value,
    required this.priority,
  });

  final String label;
  final String value;
  final StudentPriority priority;
}

class StudentActionCta {
  const StudentActionCta({required this.label, required this.target});

  final String label;
  final StudentActionTarget target;
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

enum StudentTimelineKind { lecture, quiz, task }

class StudentLectureCardModel {
  const StudentLectureCardModel({
    required this.lecture,
    required this.isNext,
    required this.statusLabel,
    required this.timeLabel,
    required this.target,
  });

  final LectureItem lecture;
  final bool isNext;
  final String statusLabel;
  final String timeLabel;
  final StudentActionTarget target;
}

class StudentQuizCardModel {
  const StudentQuizCardModel({
    required this.quiz,
    required this.isOpen,
    required this.statusLabel,
    required this.timeLabel,
    required this.target,
  });

  final QuizItem quiz;
  final bool isOpen;
  final String statusLabel;
  final String timeLabel;
  final StudentActionTarget target;
}

class StudentDeadlineItem {
  const StudentDeadlineItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.priority,
    this.target,
  });

  final String title;
  final String subtitle;
  final String meta;
  final StudentPriority priority;
  final StudentActionTarget? target;
}

class StudentStudyInsightsModel {
  const StudentStudyInsightsModel({
    required this.summary,
    required this.completedTasks,
    required this.pendingTasks,
    required this.viewedLectures,
    required this.engagementLabel,
    required this.engagementScore,
  });

  final String summary;
  final int completedTasks;
  final int pendingTasks;
  final int viewedLectures;
  final String engagementLabel;
  final double engagementScore;
}

enum StudentPriority { urgent, soon, safe }

StudentTodayFocusModel _buildTodayFocus({
  required DateTime now,
  required QuizItem? openQuiz,
  required LectureItem? nextLecture,
  required TaskItem? nearestTaskDeadline,
}) {
  final highlights = <StudentTodayHighlight>[
    StudentTodayHighlight(
      label: 'Next lecture',
      value: nextLecture == null
          ? 'No lecture scheduled'
          : _timeUntil(nextLecture.startsAt, now),
      priority: nextLecture == null
          ? StudentPriority.safe
          : StudentPriority.soon,
    ),
    StudentTodayHighlight(
      label: 'Quiz status',
      value: openQuiz == null
          ? 'No quiz open now'
          : 'Open for ${_timeUntil(openQuiz.closesAt, now)}',
      priority: openQuiz == null
          ? StudentPriority.safe
          : StudentPriority.urgent,
    ),
    StudentTodayHighlight(
      label: 'Nearest deadline',
      value: nearestTaskDeadline == null
          ? 'Nothing urgent'
          : _timeUntil(nearestTaskDeadline.dueAt, now),
      priority: nearestTaskDeadline == null
          ? StudentPriority.safe
          : _priorityFromDate(nearestTaskDeadline.dueAt, now),
    ),
  ];

  if (openQuiz != null) {
    return StudentTodayFocusModel(
      state: StudentTodayFocusState.urgent,
      title: '${openQuiz.title} is open right now',
      message:
          '${openQuiz.subjectName ?? 'Your course'} closes ${_timeUntil(openQuiz.closesAt, now)}. This is the most time-sensitive task on your dashboard.',
      highlights: highlights,
      primaryCta: StudentActionCta(
        label: 'Open Quiz',
        target: _quizTarget(openQuiz),
      ),
      secondaryCta: StudentActionCta(
        label: 'Open Course',
        target: _subjectTarget(openQuiz.subjectId),
      ),
    );
  }

  if (nearestTaskDeadline != null &&
      _priorityFromDate(nearestTaskDeadline.dueAt, now) ==
          StudentPriority.urgent) {
    return StudentTodayFocusModel(
      state: StudentTodayFocusState.urgent,
      title: '${nearestTaskDeadline.title} needs attention today',
      message:
          '${nearestTaskDeadline.subjectName ?? 'Course task'} is due ${_timeUntil(nearestTaskDeadline.dueAt, now)}. Wrap this up before you move on to lower-priority work.',
      highlights: highlights,
      primaryCta: StudentActionCta(
        label: 'Open Course',
        target: _subjectTarget(nearestTaskDeadline.subjectId),
      ),
      secondaryCta: const StudentActionCta(
        label: 'View Schedule',
        target: StudentActionTarget(routeName: RouteNames.subjects),
      ),
    );
  }

  if (nextLecture != null) {
    return StudentTodayFocusModel(
      state: StudentTodayFocusState.busy,
      title:
          '${nextLecture.title} starts ${_timeUntil(nextLecture.startsAt, now)}',
      message:
          '${nextLecture.subjectName ?? 'Your lecture'} is the next live event on your calendar. Join from the course space and review materials before it begins.',
      highlights: highlights,
      primaryCta: StudentActionCta(
        label: 'Join Lecture',
        target: _subjectTarget(nextLecture.subjectId),
      ),
      secondaryCta: const StudentActionCta(
        label: 'View Schedule',
        target: StudentActionTarget(routeName: RouteNames.subjects),
      ),
    );
  }

  return const StudentTodayFocusModel(
    state: StudentTodayFocusState.empty,
    title: 'You are clear for now',
    message:
        'No urgent quizzes, lectures, or deadlines are competing for attention. This is a good moment to review course updates.',
    highlights: [
      StudentTodayHighlight(
        label: 'Focus',
        value: 'Catch up on recent activity',
        priority: StudentPriority.safe,
      ),
      StudentTodayHighlight(
        label: 'Next step',
        value: 'Review your course stream',
        priority: StudentPriority.safe,
      ),
      StudentTodayHighlight(
        label: 'Status',
        value: 'Calendar is under control',
        priority: StudentPriority.safe,
      ),
    ],
    primaryCta: StudentActionCta(
      label: 'Open Course',
      target: StudentActionTarget(routeName: RouteNames.subjects),
    ),
    secondaryCta: StudentActionCta(
      label: 'Check Results',
      target: StudentActionTarget(routeName: RouteNames.results),
    ),
  );
}

List<StudentTimelineItem> _buildTimelineItems({
  required List<LectureItem> lectures,
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
            subtitle: lecture.subjectName ?? 'Lecture',
            timeLabel: lecture.scheduleLabel,
            scheduledAt: lecture.startsAt,
            kind: StudentTimelineKind.lecture,
            priority: _priorityFromDate(lecture.startsAt, now),
            target: _subjectTarget(lecture.subjectId),
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
            timeLabel: _isQuizOpen(quiz, now) ? 'Open now' : quiz.startAtLabel,
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
            target: _subjectTarget(task.subjectId),
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
  final laterItems = <StudentTimelineItem>[];

  for (final item in items) {
    final referenceDate = item.scheduledAt;
    if (referenceDate == null) {
      laterItems.add(item);
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
      laterItems.add(item);
    }
  }

  return [
    if (todayItems.isNotEmpty)
      StudentTimelineGroup(title: 'Today', items: todayItems),
    if (tomorrowItems.isNotEmpty)
      StudentTimelineGroup(title: 'Tomorrow', items: tomorrowItems),
    if (laterItems.isNotEmpty)
      StudentTimelineGroup(title: 'Later', items: laterItems),
  ];
}

List<StudentDeadlineItem> _buildDeadlineItems({
  required List<QuizItem> quizzes,
  required List<TaskItem> tasks,
  required DateTime now,
}) {
  final items = <StudentDeadlineItem>[
    ...tasks
        .where(
          (task) => !task.isCompleted && (task.dueAt?.isAfter(now) ?? false),
        )
        .map(
          (task) => StudentDeadlineItem(
            title: task.title,
            subtitle: task.subjectName ?? task.status,
            meta: task.isMissingSubmission
                ? 'Missing submission'
                : task.dueDateLabel,
            priority: _priorityFromDate(task.dueAt, now),
            target: _subjectTarget(task.subjectId),
          ),
        ),
    ...quizzes
        .where((quiz) => quiz.closesAt?.isAfter(now) ?? false)
        .map(
          (quiz) => StudentDeadlineItem(
            title: quiz.title,
            subtitle: quiz.subjectName ?? quiz.typeLabel,
            meta: _isQuizOpen(quiz, now)
                ? 'Closes ${_timeUntil(quiz.closesAt, now)}'
                : 'Starts ${_timeUntil(quiz.startsAt, now)}',
            priority: _isQuizOpen(quiz, now)
                ? StudentPriority.urgent
                : _priorityFromDate(quiz.startsAt, now),
            target: _quizTarget(quiz),
          ),
        ),
  ];

  items.sort((a, b) {
    final priorityOrder = a.priority.index.compareTo(b.priority.index);
    if (priorityOrder != 0) {
      return priorityOrder;
    }
    return a.title.compareTo(b.title);
  });

  return items.take(4).toList();
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

String _timeUntil(DateTime? date, DateTime now) {
  if (date == null) {
    return 'soon';
  }

  final difference = date.difference(now);
  if (difference.inMinutes <= 59) {
    return 'in ${difference.inMinutes.clamp(1, 59)} min';
  }
  if (difference.inHours <= 23) {
    return 'in ${difference.inHours}h';
  }
  if (difference.inDays == 1) {
    return 'tomorrow';
  }
  return 'in ${difference.inDays} days';
}

bool _isQuizOpen(QuizItem? quiz, DateTime now) {
  if (quiz?.startsAt == null || quiz?.closesAt == null) {
    return false;
  }

  return !quiz!.startsAt!.isAfter(now) && quiz.closesAt!.isAfter(now);
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
