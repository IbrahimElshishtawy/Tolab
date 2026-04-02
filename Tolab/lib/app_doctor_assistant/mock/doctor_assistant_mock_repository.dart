import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_admin/core/colors/app_colors.dart';
import '../../app_admin/modules/schedule/models/schedule_models.dart';
import '../core/models/session_user.dart';
import '../core/navigation/app_routes.dart';
import '../models/doctor_assistant_models.dart';

class DoctorAssistantMockRepository {
  const DoctorAssistantMockRepository._();

  static const DoctorAssistantMockRepository instance =
      DoctorAssistantMockRepository._();

  List<TeachingSubject> subjectsFor(SessionUser user) => _subjects;

  TeachingSubject subjectById(int subjectId) {
    return _subjects.firstWhere(
      (subject) => subject.id == subjectId,
      orElse: () => _subjects.first,
    );
  }

  WorkspaceHomeSnapshot homeFor(SessionUser user) {
    final subjects = subjectsFor(user);
    final lectureCount = subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.lectures.length,
    );
    final sectionCount = subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.sections.length,
    );
    final quizCount = subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.quizzes.length,
    );
    final taskCount = subjects.fold<int>(
      0,
      (sum, subject) => sum + subject.tasks.length,
    );

    return WorkspaceHomeSnapshot(
      dateLabel: DateFormat('EEEE, d MMMM yyyy').format(DateTime(2026, 4, 3)),
      metrics: [
        WorkspaceOverviewMetric(
          label: 'Upcoming Lectures',
          value: '$lectureCount',
          caption: user.isDoctor
              ? 'Lectures ready for this teaching cycle'
              : 'Lecture handoff items to support this week',
          icon: Icons.co_present_rounded,
          color: AppColors.primary,
        ),
        WorkspaceOverviewMetric(
          label: 'Sections',
          value: '$sectionCount',
          caption: 'Scheduled lab and tutorial touchpoints',
          icon: Icons.view_module_rounded,
          color: AppColors.info,
        ),
        WorkspaceOverviewMetric(
          label: 'Quizzes',
          value: '$quizCount',
          caption: 'Assessment windows currently planned',
          icon: Icons.quiz_rounded,
          color: AppColors.secondary,
        ),
        WorkspaceOverviewMetric(
          label: 'Tasks',
          value: '$taskCount',
          caption: 'Deadlines requiring follow-up this week',
          icon: Icons.assignment_turned_in_rounded,
          color: AppColors.warning,
        ),
      ],
      upcoming: const [
        WorkspaceUpcomingItem(
          title: 'Algorithms Lecture 07',
          subtitle: 'Hall B2 • Level 3',
          timeLabel: 'Sun • 09:00 - 11:00',
          statusLabel: 'Scheduled',
          icon: Icons.co_present_rounded,
        ),
        WorkspaceUpcomingItem(
          title: 'Data Structures Section A3',
          subtitle: 'Lab C1 • Assistant support',
          timeLabel: 'Mon • 12:00 - 13:30',
          statusLabel: 'Live',
          icon: Icons.groups_rounded,
        ),
        WorkspaceUpcomingItem(
          title: 'Software Engineering Quiz',
          subtitle: 'Opens for 90 minutes',
          timeLabel: 'Tue • 10:30',
          statusLabel: 'Published',
          icon: Icons.fact_check_rounded,
        ),
      ],
      quickActions: user.isDoctor
          ? const [
              WorkspaceQuickAction(
                title: 'Add Lecture',
                subtitle: 'Create next lecture brief and timing',
                route: AppRoutes.lectures,
                icon: Icons.add_chart_rounded,
              ),
              WorkspaceQuickAction(
                title: 'Add Quiz',
                subtitle: 'Prepare a graded quiz window',
                route: AppRoutes.quizzes,
                icon: Icons.playlist_add_check_circle_rounded,
              ),
              WorkspaceQuickAction(
                title: 'Add Section',
                subtitle: 'Coordinate tutorial or lab support',
                route: AppRoutes.sectionContent,
                icon: Icons.post_add_rounded,
              ),
              WorkspaceQuickAction(
                title: 'Add Task',
                subtitle: 'Publish an assignment milestone',
                route: AppRoutes.tasks,
                icon: Icons.task_alt_rounded,
              ),
            ]
          : const [
              WorkspaceQuickAction(
                title: 'Add Section',
                subtitle: 'Create the next support section',
                route: AppRoutes.sectionContent,
                icon: Icons.post_add_rounded,
              ),
              WorkspaceQuickAction(
                title: 'Add Task',
                subtitle: 'Push practice work to students',
                route: AppRoutes.tasks,
                icon: Icons.task_alt_rounded,
              ),
              WorkspaceQuickAction(
                title: 'Add Lecture',
                subtitle: 'Prepare a lecture support note',
                route: AppRoutes.lectures,
                icon: Icons.add_chart_rounded,
              ),
              WorkspaceQuickAction(
                title: 'Add Quiz',
                subtitle: 'Draft a quick assessment window',
                route: AppRoutes.quizzes,
                icon: Icons.playlist_add_check_circle_rounded,
              ),
            ],
    );
  }

  List<WorkspaceNotificationItem> notificationsFor(SessionUser user) =>
      _notifications;

  int unreadNotificationsFor(SessionUser user) =>
      _notifications.where((notification) => !notification.isRead).length;

  List<ScheduleEventItem> scheduleFor(SessionUser user) => _schedule;

  Map<String, List<String>> scheduleConflictsFor(SessionUser user) => const {
    'evt-quiz-se': ['Assessment overlaps with section A2 availability.'],
  };

  WorkspaceProfileSnapshot profileFor(SessionUser user) {
    final stats = user.isDoctor
        ? const [
            WorkspaceOverviewMetric(
              label: 'Active Subjects',
              value: '4',
              caption: 'Core courses under direct supervision',
              icon: Icons.menu_book_rounded,
              color: AppColors.primary,
            ),
            WorkspaceOverviewMetric(
              label: 'Weekly Hours',
              value: '18',
              caption: 'Lectures, office hours, and reviews',
              icon: Icons.schedule_rounded,
              color: AppColors.info,
            ),
            WorkspaceOverviewMetric(
              label: 'Advisees',
              value: '62',
              caption: 'Students currently assigned to you',
              icon: Icons.groups_rounded,
              color: AppColors.secondary,
            ),
          ]
        : const [
            WorkspaceOverviewMetric(
              label: 'Supported Sections',
              value: '7',
              caption: 'Labs and tutorials under coordination',
              icon: Icons.view_module_rounded,
              color: AppColors.primary,
            ),
            WorkspaceOverviewMetric(
              label: 'Weekly Hours',
              value: '16',
              caption: 'Tutorial delivery and grading support',
              icon: Icons.schedule_rounded,
              color: AppColors.info,
            ),
            WorkspaceOverviewMetric(
              label: 'Open Tasks',
              value: '9',
              caption: 'Student follow-ups and content actions',
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
            ),
          ];

    return WorkspaceProfileSnapshot(
      roleHeadline: user.isDoctor
          ? 'Lead academic delivery across core subjects.'
          : 'Coordinate sections, support delivery, and keep weekly execution tight.',
      roleSummary: user.isDoctor
          ? 'Your workspace is tuned for lecture publishing, assessment cadence, and subject-level oversight.'
          : 'Your workspace is tuned for section readiness, task follow-up, and assistant-level execution.',
      focusAreas: user.isDoctor
          ? const ['Algorithms', 'Software Engineering', 'Assessment Design']
          : const ['Lab Supervision', 'Student Follow-up', 'Weekly Coordination'],
      officeHours: user.isDoctor
          ? 'Sun & Tue • 13:00 - 15:00'
          : 'Mon & Wed • 11:00 - 13:00',
      locationLabel: user.isDoctor
          ? 'Faculty Building • Room 403'
          : 'Tutorial Center • Room 118',
      phoneLabel: user.phone ?? '+20 100 555 0101',
      primaryStats: stats,
    );
  }

  static final List<TeachingSubject> _subjects = [
    TeachingSubject(
      id: 101,
      code: 'CS301',
      name: 'Algorithms',
      department: 'Computer Science',
      academicTerm: 'Spring 2026 • Level 3',
      description:
          'Design, analysis, and optimization of classic algorithmic techniques.',
      studentCount: 146,
      sectionCount: 3,
      progress: 0.72,
      accentColor: AppColors.primary,
      lectures: const [
        TeachingLecture(
          id: 'alg-lec-07',
          title: 'Greedy Strategies and Proof Patterns',
          audience: 'Lecture Group A',
          dayLabel: 'Sunday',
          timeLabel: '09:00 - 11:00',
          room: 'Hall B2',
          statusLabel: 'Scheduled',
          weekLabel: 'Week 7',
        ),
        TeachingLecture(
          id: 'alg-lec-08',
          title: 'Minimum Spanning Trees',
          audience: 'Lecture Group A',
          dayLabel: 'Thursday',
          timeLabel: '11:00 - 13:00',
          room: 'Hall B2',
          statusLabel: 'Draft',
          weekLabel: 'Week 8',
        ),
      ],
      sections: const [
        TeachingSection(
          id: 'alg-sec-a1',
          title: 'Complexity Lab',
          assistantName: 'Eng. Mariam Hany',
          dayLabel: 'Monday',
          timeLabel: '12:00 - 13:30',
          room: 'Lab C1',
          statusLabel: 'Live',
          groupLabel: 'A1',
        ),
        TeachingSection(
          id: 'alg-sec-a2',
          title: 'Problem Solving Drill',
          assistantName: 'Eng. Omar Khaled',
          dayLabel: 'Wednesday',
          timeLabel: '10:00 - 11:30',
          room: 'Lab C2',
          statusLabel: 'Scheduled',
          groupLabel: 'A2',
        ),
      ],
      quizzes: const [
        TeachingQuiz(
          id: 'alg-quiz-02',
          title: 'Recurrence Relations Quiz',
          windowLabel: 'Tue 10:30 • 90 min',
          statusLabel: 'Published',
          attemptsLabel: '91/146 attempts',
          scopeLabel: 'Level 3 cohort',
        ),
      ],
      tasks: const [
        TeachingTask(
          id: 'alg-task-03',
          title: 'Graph Traversal Assignment',
          deadlineLabel: 'Due Thu 17 Apr',
          statusLabel: 'Pending',
          progressLabel: '58% submitted',
          scopeLabel: 'All lecture groups',
        ),
      ],
    ),
    TeachingSubject(
      id: 102,
      code: 'CS241',
      name: 'Data Structures',
      department: 'Computer Science',
      academicTerm: 'Spring 2026 • Level 2',
      description:
          'Implementation trade-offs for linear, non-linear, and indexed collections.',
      studentCount: 184,
      sectionCount: 4,
      progress: 0.65,
      accentColor: AppColors.info,
      lectures: const [
        TeachingLecture(
          id: 'ds-lec-06',
          title: 'Balanced Trees in Practice',
          audience: 'Lecture Group B',
          dayLabel: 'Monday',
          timeLabel: '08:30 - 10:30',
          room: 'Hall A4',
          statusLabel: 'Scheduled',
          weekLabel: 'Week 6',
        ),
      ],
      sections: const [
        TeachingSection(
          id: 'ds-sec-b1',
          title: 'BST Implementation Workshop',
          assistantName: 'Eng. Reem Tarek',
          dayLabel: 'Tuesday',
          timeLabel: '14:00 - 15:30',
          room: 'Lab D2',
          statusLabel: 'Scheduled',
          groupLabel: 'B1',
        ),
      ],
      quizzes: const [
        TeachingQuiz(
          id: 'ds-quiz-03',
          title: 'Hash Tables Checkpoint',
          windowLabel: 'Wed 09:00 • 45 min',
          statusLabel: 'Scheduled',
          attemptsLabel: 'Opens in 2 days',
          scopeLabel: 'Section groups B1-B4',
        ),
      ],
      tasks: const [
        TeachingTask(
          id: 'ds-task-02',
          title: 'Heap Visualizer Submission',
          deadlineLabel: 'Due Mon 14 Apr',
          statusLabel: 'Published',
          progressLabel: '74% submitted',
          scopeLabel: 'Level 2 cohort',
        ),
      ],
    ),
    TeachingSubject(
      id: 103,
      code: 'SE402',
      name: 'Software Engineering',
      department: 'Information Systems',
      academicTerm: 'Spring 2026 • Level 4',
      description:
          'Team delivery, software process, quality practices, and product planning.',
      studentCount: 118,
      sectionCount: 2,
      progress: 0.81,
      accentColor: AppColors.secondary,
      lectures: const [
        TeachingLecture(
          id: 'se-lec-09',
          title: 'Sprint Planning and Estimation',
          audience: 'Lecture Group C',
          dayLabel: 'Tuesday',
          timeLabel: '10:30 - 12:30',
          room: 'Hall C3',
          statusLabel: 'Published',
          weekLabel: 'Week 9',
        ),
      ],
      sections: const [
        TeachingSection(
          id: 'se-sec-c1',
          title: 'User Story Refinement',
          assistantName: 'Eng. Ahmed Nabil',
          dayLabel: 'Thursday',
          timeLabel: '09:30 - 11:00',
          room: 'Studio 5',
          statusLabel: 'Scheduled',
          groupLabel: 'C1',
        ),
      ],
      quizzes: const [
        TeachingQuiz(
          id: 'se-quiz-01',
          title: 'Requirements Workshop Quiz',
          windowLabel: 'Thu 12:00 • 30 min',
          statusLabel: 'Draft',
          attemptsLabel: 'Awaiting publish',
          scopeLabel: 'Project track C',
        ),
      ],
      tasks: const [
        TeachingTask(
          id: 'se-task-04',
          title: 'Sprint Retrospective Report',
          deadlineLabel: 'Due Sun 20 Apr',
          statusLabel: 'Scheduled',
          progressLabel: 'Review opens next week',
          scopeLabel: 'Project teams',
        ),
      ],
    ),
    TeachingSubject(
      id: 104,
      code: 'AI410',
      name: 'Introduction to AI',
      department: 'Artificial Intelligence',
      academicTerm: 'Spring 2026 • Level 4',
      description:
          'Foundations of search, reasoning, and model-based problem solving.',
      studentCount: 96,
      sectionCount: 2,
      progress: 0.58,
      accentColor: AppColors.purple,
      lectures: const [
        TeachingLecture(
          id: 'ai-lec-05',
          title: 'Informed Search Heuristics',
          audience: 'Lecture Group D',
          dayLabel: 'Wednesday',
          timeLabel: '13:00 - 15:00',
          room: 'Hall D1',
          statusLabel: 'Scheduled',
          weekLabel: 'Week 5',
        ),
      ],
      sections: const [
        TeachingSection(
          id: 'ai-sec-d1',
          title: 'A* Search Lab',
          assistantName: 'Eng. Farah Ali',
          dayLabel: 'Sunday',
          timeLabel: '11:30 - 13:00',
          room: 'Lab AI-2',
          statusLabel: 'Scheduled',
          groupLabel: 'D1',
        ),
      ],
      quizzes: const [
        TeachingQuiz(
          id: 'ai-quiz-01',
          title: 'State Space Models',
          windowLabel: 'Sun 15:00 • 40 min',
          statusLabel: 'Scheduled',
          attemptsLabel: 'Opens after lecture',
          scopeLabel: 'AI track cohort',
        ),
      ],
      tasks: const [
        TeachingTask(
          id: 'ai-task-01',
          title: 'Heuristic Comparison Brief',
          deadlineLabel: 'Due Wed 23 Apr',
          statusLabel: 'Draft',
          progressLabel: 'Not yet published',
          scopeLabel: 'Research mini-groups',
        ),
      ],
    ),
  ];

  static const List<WorkspaceNotificationItem> _notifications = [
    WorkspaceNotificationItem(
      id: 'notif-1',
      title: 'Room B2 updated for Algorithms lecture',
      body: 'The lecture has moved from Hall B1 to Hall B2 after capacity review.',
      timeLabel: '15 min ago',
      statusLabel: 'Live',
      courseLabel: 'CS301',
      isRead: false,
      icon: Icons.meeting_room_rounded,
    ),
    WorkspaceNotificationItem(
      id: 'notif-2',
      title: 'Quiz review window opens tomorrow',
      body: 'Software Engineering quiz feedback will unlock automatically at 09:00.',
      timeLabel: '1 hr ago',
      statusLabel: 'Scheduled',
      courseLabel: 'SE402',
      isRead: false,
      icon: Icons.quiz_rounded,
    ),
    WorkspaceNotificationItem(
      id: 'notif-3',
      title: 'Section attendance synced successfully',
      body: 'Attendance from Lab C1 has been synced to the academic ledger.',
      timeLabel: 'Today • 09:20',
      statusLabel: 'Completed',
      courseLabel: 'CS241',
      isRead: true,
      icon: Icons.check_circle_outline_rounded,
    ),
    WorkspaceNotificationItem(
      id: 'notif-4',
      title: 'Task deadline reminder',
      body: 'Graph Traversal Assignment closes in 48 hours for all lecture groups.',
      timeLabel: 'Yesterday',
      statusLabel: 'Pending',
      courseLabel: 'CS301',
      isRead: true,
      icon: Icons.assignment_late_rounded,
    ),
  ];

  static final List<ScheduleEventItem> _schedule = [
    ScheduleEventItem(
      id: 'evt-alg-lecture',
      title: 'Algorithms Lecture',
      section: 'Lecture Group A',
      subject: 'Algorithms',
      instructor: 'Dr. Salma Hassan',
      location: 'Hall B2',
      status: ScheduleEventStatus.planned,
      type: ScheduleEventType.lecture,
      startAt: DateTime(2026, 4, 5, 9, 0),
      endAt: DateTime(2026, 4, 5, 11, 0),
      department: 'Computer Science',
      yearLabel: 'Level 3',
    ),
    ScheduleEventItem(
      id: 'evt-ds-section',
      title: 'Data Structures Section',
      section: 'B1',
      subject: 'Data Structures',
      instructor: 'Eng. Reem Tarek',
      location: 'Lab D2',
      status: ScheduleEventStatus.planned,
      type: ScheduleEventType.lecture,
      startAt: DateTime(2026, 4, 6, 14, 0),
      endAt: DateTime(2026, 4, 6, 15, 30),
      department: 'Computer Science',
      yearLabel: 'Level 2',
    ),
    ScheduleEventItem(
      id: 'evt-quiz-se',
      title: 'Software Engineering Quiz',
      section: 'Project Track C',
      subject: 'Software Engineering',
      instructor: 'Dr. Khaled Mostafa',
      location: 'Online',
      status: ScheduleEventStatus.planned,
      type: ScheduleEventType.quiz,
      startAt: DateTime(2026, 4, 7, 10, 30),
      endAt: DateTime(2026, 4, 7, 12, 0),
      department: 'Information Systems',
      yearLabel: 'Level 4',
    ),
    ScheduleEventItem(
      id: 'evt-task-ai',
      title: 'AI Task Review',
      section: 'Research Groups',
      subject: 'Introduction to AI',
      instructor: 'Dr. Hala Ezz',
      location: 'Office 2A',
      status: ScheduleEventStatus.planned,
      type: ScheduleEventType.task,
      startAt: DateTime(2026, 4, 8, 13, 0),
      endAt: DateTime(2026, 4, 8, 14, 0),
      department: 'Artificial Intelligence',
      yearLabel: 'Level 4',
    ),
  ];
}
