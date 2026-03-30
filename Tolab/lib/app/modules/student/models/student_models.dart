import 'package:flutter/material.dart';

import '../../academy_panel/models/academy_models.dart';

const List<RoleNavItem> studentNavigationItems = [
  RoleNavItem(
    key: 'dashboard',
    title: 'Dashboard',
    route: '/student/dashboard',
    icon: Icons.dashboard_rounded,
    description: 'Student overview.',
  ),
  RoleNavItem(
    key: 'enrolled-courses',
    title: 'Courses',
    route: '/student/enrolled-courses',
    icon: Icons.school_rounded,
    description: 'Current course list.',
  ),
  RoleNavItem(
    key: 'lectures',
    title: 'Lectures',
    route: '/student/lectures',
    icon: Icons.slideshow_rounded,
    description: 'Lecture materials and summaries.',
  ),
  RoleNavItem(
    key: 'tasks',
    title: 'Tasks',
    route: '/student/tasks',
    icon: Icons.task_alt_rounded,
    description: 'Assignments and due dates.',
  ),
  RoleNavItem(
    key: 'quizzes',
    title: 'Quizzes',
    route: '/student/quizzes',
    icon: Icons.quiz_rounded,
    description: 'Quiz preparation and windows.',
  ),
  RoleNavItem(
    key: 'exams',
    title: 'Exams',
    route: '/student/exams',
    icon: Icons.fact_check_rounded,
    description: 'Exam schedule and readiness.',
  ),
  RoleNavItem(
    key: 'calendar',
    title: 'Calendar',
    route: '/student/calendar',
    icon: Icons.calendar_month_rounded,
    description: 'Timetable and deadlines.',
  ),
  RoleNavItem(
    key: 'notifications',
    title: 'Notifications',
    route: '/student/notifications',
    icon: Icons.notifications_rounded,
    description: 'Realtime learner updates.',
  ),
  RoleNavItem(
    key: 'profile',
    title: 'Profile',
    route: '/student/profile',
    icon: Icons.person_rounded,
    description: 'Student identity and preferences.',
  ),
];

class StudentPageBlueprint {
  const StudentPageBlueprint({
    required this.title,
    required this.subtitle,
    required this.endpoints,
    required this.actionLabel,
    this.columns = const [],
    this.sampleRows = const [],
    this.cards = const [],
  });

  final String title;
  final String subtitle;
  final List<String> endpoints;
  final String actionLabel;
  final List<PanelTableColumn> columns;
  final List<JsonMap> sampleRows;
  final List<PanelInfoCard> cards;
}

const Map<String, StudentPageBlueprint> _studentBlueprints = {
  'enrolled-courses': StudentPageBlueprint(
    title: 'Enrolled Courses',
    subtitle: 'Semester courses, instructors, and progress visibility.',
    endpoints: ['GET /student/courses'],
    actionLabel: 'Refresh Courses',
    columns: [
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Instructor', key: 'instructor'),
      PanelTableColumn(label: 'Section', key: 'section'),
      PanelTableColumn(label: 'Progress', key: 'progress'),
    ],
    sampleRows: [
      {
        'course': 'Operating Systems',
        'instructor': 'Dr. Karim Hassan',
        'section': 'CS-2A',
        'progress': '74%',
      },
      {
        'course': 'Computer Networks',
        'instructor': 'Dr. Mona Samy',
        'section': 'CS-2A',
        'progress': '61%',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Semester GPA Target',
        value: '3.45',
        caption: 'You are tracking above target right now',
        icon: Icons.trending_up_rounded,
      ),
      PanelInfoCard(
        title: 'Credits In Progress',
        value: '18 hrs',
        caption: 'All registered courses are confirmed',
        icon: Icons.workspace_premium_rounded,
      ),
    ],
  ),
  'lectures': StudentPageBlueprint(
    title: 'Lectures',
    subtitle: 'Latest lecture packs, summaries, and section materials.',
    endpoints: ['GET /student/courses/{courseOffering}/content'],
    actionLabel: 'Sync Content',
    columns: [
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Asset', key: 'asset'),
      PanelTableColumn(label: 'Week', key: 'week'),
      PanelTableColumn(label: 'State', key: 'state'),
    ],
    sampleRows: [
      {
        'course': 'Operating Systems',
        'asset': 'Lecture Week 07',
        'week': '7',
        'state': 'Available',
      },
      {
        'course': 'Computer Networks',
        'asset': 'Lab Summary 04',
        'week': '4',
        'state': 'Available',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Unread Materials',
        value: '5',
        caption: 'New files posted in the last 48 hours',
        icon: Icons.mark_email_unread_rounded,
      ),
    ],
  ),
  'tasks': StudentPageBlueprint(
    title: 'Tasks',
    subtitle: 'Assignments, deadlines, and submission readiness.',
    endpoints: ['GET /student/courses/{courseOffering}/content'],
    actionLabel: 'Review Tasks',
    columns: [
      PanelTableColumn(label: 'Task', key: 'task'),
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Due', key: 'due'),
      PanelTableColumn(label: 'State', key: 'state'),
    ],
    sampleRows: [
      {
        'task': 'Scheduler analysis',
        'course': 'Operating Systems',
        'due': '02 Apr',
        'state': 'In progress',
      },
      {
        'task': 'LAN design worksheet',
        'course': 'Computer Networks',
        'due': '04 Apr',
        'state': 'Not started',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Due This Week',
        value: '4 tasks',
        caption: 'Two tasks due within the next 72 hours',
        icon: Icons.pending_actions_rounded,
      ),
    ],
  ),
  'quizzes': StudentPageBlueprint(
    title: 'Quizzes',
    subtitle: 'Quiz preparation, windows, and attempt status.',
    endpoints: ['GET /student/courses/{courseOffering}/content'],
    actionLabel: 'Review Quizzes',
    columns: [
      PanelTableColumn(label: 'Quiz', key: 'quiz'),
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Window', key: 'window'),
      PanelTableColumn(label: 'State', key: 'state'),
    ],
    sampleRows: [
      {
        'quiz': 'Processes and threads',
        'course': 'Operating Systems',
        'window': '31 Mar 09:00-12:00',
        'state': 'Open soon',
      },
      {
        'quiz': 'OSI layers',
        'course': 'Computer Networks',
        'window': '03 Apr 10:00-12:00',
        'state': 'Scheduled',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Upcoming Quizzes',
        value: '2',
        caption: 'Both quizzes open this week',
        icon: Icons.timer_rounded,
      ),
    ],
  ),
  'exams': StudentPageBlueprint(
    title: 'Exams',
    subtitle: 'Exam schedule, seating, and revision checkpoints.',
    endpoints: ['GET /student/timetable'],
    actionLabel: 'View Exam Plan',
    columns: [
      PanelTableColumn(label: 'Exam', key: 'exam'),
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Date', key: 'date'),
      PanelTableColumn(label: 'Seat', key: 'seat'),
    ],
    sampleRows: [
      {
        'exam': 'Midterm',
        'course': 'Operating Systems',
        'date': '14 Apr 11:00',
        'seat': 'Hall B-12',
      },
      {
        'exam': 'Practical',
        'course': 'Computer Networks',
        'date': '18 Apr 09:00',
        'seat': 'Lab 4',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Exam Readiness',
        value: '83%',
        caption: 'Revision plan is on track against the calendar',
        icon: Icons.psychology_alt_rounded,
      ),
    ],
  ),
};

RolePageData buildStudentPageData(
  String pageKey, {
  JsonMap payload = const {},
  List<AcademyNotificationItem> notifications = const [],
}) {
  final records = payload['records'] is List
      ? List<Map<String, dynamic>>.from(payload['records'] as List)
      : const <JsonMap>[];

  if (_studentBlueprints.containsKey(pageKey)) {
    final blueprint = _studentBlueprints[pageKey]!;
    return RolePageData(
      key: pageKey,
      title: blueprint.title,
      subtitle: blueprint.subtitle,
      breadcrumbs: ['Student', blueprint.title],
      quickJumps: const [
        QuickJumpItem(sectionId: 'summary', label: 'Summary'),
        QuickJumpItem(sectionId: 'table', label: 'Table'),
      ],
      sections: [
        PageSectionData(
          id: 'summary',
          title: '${blueprint.title} Snapshot',
          subtitle: 'A compact student-friendly view for the current semester.',
          type: PageSectionType.cards,
          cards: blueprint.cards,
        ),
        PageSectionData(
          id: 'table',
          title: '${blueprint.title} Table',
          subtitle: 'Scrollable content with large-screen sticky headers.',
          type: PageSectionType.table,
          table: PanelTableData(
            columns: blueprint.columns,
            rows: (records.isEmpty ? blueprint.sampleRows : records)
                .map(PanelTableRow.new)
                .toList(),
          ),
        ),
      ],
      primaryActionLabel: blueprint.actionLabel,
      backendEndpoints: blueprint.endpoints,
      emptyStateMessage:
          '${blueprint.title} will sync here after the student API responds.',
    );
  }

  return switch (pageKey) {
    'dashboard' => const RolePageData(
      key: 'dashboard',
      title: 'Student Dashboard',
      subtitle:
          'Course momentum, upcoming deadlines, and academic wellbeing in one place.',
      breadcrumbs: ['Student', 'Dashboard'],
      quickJumps: [
        QuickJumpItem(sectionId: 'overview', label: 'Overview'),
        QuickJumpItem(sectionId: 'calendar', label: 'Calendar'),
      ],
      sections: [
        PageSectionData(
          id: 'overview',
          title: 'This Week',
          subtitle: 'Fast-moving signals for focus and planning.',
          type: PageSectionType.metrics,
          metrics: [
            PanelMetric(
              label: 'Attendance',
              value: '92%',
              delta: '+4%',
              icon: Icons.how_to_reg_rounded,
            ),
            PanelMetric(
              label: 'Assignments Due',
              value: '4',
              delta: '2 urgent',
              icon: Icons.assignment_rounded,
            ),
            PanelMetric(
              label: 'Quiz Windows',
              value: '2',
              delta: 'Starts tomorrow',
              icon: Icons.quiz_rounded,
            ),
          ],
        ),
        PageSectionData(
          id: 'calendar',
          title: 'Upcoming Moments',
          subtitle: 'Classes, due dates, and checkpoints.',
          type: PageSectionType.timeline,
          timeline: [
            PanelTimelineEntry(
              title: 'Operating Systems lecture',
              subtitle: 'Processes and scheduling',
              timeLabel: 'Mon 10:00',
              location: 'Hall 3',
            ),
            PanelTimelineEntry(
              title: 'Networks worksheet due',
              subtitle: 'Upload before midnight',
              timeLabel: 'Wed 23:59',
              location: 'LMS',
            ),
            PanelTimelineEntry(
              title: 'OS quiz window',
              subtitle: 'Opens for 3 hours',
              timeLabel: 'Thu 09:00',
              location: 'Online',
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Open Calendar',
      backendEndpoints: ['GET /student/courses', 'GET /student/timetable'],
      emptyStateMessage:
          'Your learner dashboard will appear here after the student endpoints sync.',
    ),
    'calendar' => const RolePageData(
      key: 'calendar',
      title: 'Calendar',
      subtitle: 'Weekly timetable, study blocks, and assessment milestones.',
      breadcrumbs: ['Student', 'Calendar'],
      quickJumps: [
        QuickJumpItem(sectionId: 'week', label: 'Week'),
        QuickJumpItem(sectionId: 'milestones', label: 'Milestones'),
      ],
      sections: [
        PageSectionData(
          id: 'week',
          title: 'Weekly Rhythm',
          subtitle: 'The next key events in your learning week.',
          type: PageSectionType.timeline,
          timeline: [
            PanelTimelineEntry(
              title: 'Database lecture',
              subtitle: 'Normalization workshop',
              timeLabel: 'Tue 12:00',
              location: 'Hall 2',
            ),
            PanelTimelineEntry(
              title: 'Networks practical',
              subtitle: 'Switch configuration lab',
              timeLabel: 'Wed 14:00',
              location: 'Lab 4',
            ),
            PanelTimelineEntry(
              title: 'Study block',
              subtitle: 'Reserved focus session',
              timeLabel: 'Fri 17:00',
              location: 'Personal plan',
            ),
          ],
        ),
        PageSectionData(
          id: 'milestones',
          title: 'Semester Milestones',
          subtitle: 'Major academic checkpoints.',
          type: PageSectionType.cards,
          cards: [
            PanelInfoCard(
              title: 'Midterm Week',
              value: '14 Apr',
              caption: 'Exam seating announcements are already published',
              icon: Icons.event_note_rounded,
            ),
            PanelInfoCard(
              title: 'Project Demo',
              value: '28 Apr',
              caption: 'Operating Systems team showcase',
              icon: Icons.present_to_all_rounded,
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Sync Timetable',
      backendEndpoints: ['GET /student/timetable'],
      emptyStateMessage:
          'Calendar data appears here as soon as timetable events are available.',
    ),
    'notifications' => RolePageData(
      key: 'notifications',
      title: 'Notifications',
      subtitle:
          'Realtime course updates, reminders, and instructor announcements.',
      breadcrumbs: const ['Student', 'Notifications'],
      quickJumps: const [QuickJumpItem(sectionId: 'feed', label: 'Feed')],
      sections: [
        PageSectionData(
          id: 'feed',
          title: 'Notification Feed',
          subtitle: 'Delivered in FIFO order with toast mirroring.',
          type: PageSectionType.list,
          items: notifications.isEmpty
              ? const [
                  PanelListItem(
                    title: 'Quiz opens tomorrow',
                    subtitle: 'Operating Systems quiz window starts at 09:00',
                    meta: '6 min ago',
                    status: 'Unread',
                    icon: Icons.quiz_rounded,
                  ),
                  PanelListItem(
                    title: 'Lecture slides added',
                    subtitle: 'Database Systems Week 7 deck is now available',
                    meta: '24 min ago',
                    status: 'Unread',
                    icon: Icons.file_present_rounded,
                  ),
                ]
              : notifications
                    .map(
                      (item) => PanelListItem(
                        title: item.title,
                        subtitle: item.body,
                        meta: item.relativeLabel,
                        status: item.isRead ? 'Read' : 'Unread',
                        icon: Icons.notifications_rounded,
                      ),
                    )
                    .toList(),
        ),
      ],
      primaryActionLabel: 'Mark All Read',
      backendEndpoints: const [
        'GET /notifications',
        'PATCH /notifications/{notification}/read',
      ],
      emptyStateMessage:
          'Notifications appear here once the realtime channel is active.',
    ),
    'profile' => const RolePageData(
      key: 'profile',
      title: 'Profile',
      subtitle: 'Identity, department details, and personal preferences.',
      breadcrumbs: ['Student', 'Profile'],
      quickJumps: [
        QuickJumpItem(sectionId: 'identity', label: 'Identity'),
        QuickJumpItem(sectionId: 'preferences', label: 'Preferences'),
      ],
      sections: [
        PageSectionData(
          id: 'identity',
          title: 'Identity Snapshot',
          subtitle: 'Academic context and contact information.',
          type: PageSectionType.cards,
          cards: [
            PanelInfoCard(
              title: 'Department',
              value: 'Computer Science',
              caption: 'Section CS-2A',
              icon: Icons.apartment_rounded,
            ),
            PanelInfoCard(
              title: 'Advisor',
              value: 'Dr. Rana Adel',
              caption: 'Weekly office hour on Monday',
              icon: Icons.person_pin_circle_rounded,
            ),
          ],
        ),
        PageSectionData(
          id: 'preferences',
          title: 'Personal Preferences',
          subtitle: 'Notification style and study workflow defaults.',
          type: PageSectionType.list,
          items: [
            PanelListItem(
              title: 'Realtime alerts',
              subtitle: 'Enabled for assignment and quiz updates',
              meta: 'Saved',
              status: 'On',
              icon: Icons.notifications_active_rounded,
            ),
            PanelListItem(
              title: 'Theme mode',
              subtitle: 'System adaptive with premium light aesthetics',
              meta: 'Saved',
              status: 'Adaptive',
              icon: Icons.palette_outlined,
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Save Profile',
      backendEndpoints: ['GET /me/profile', 'PUT /me/profile'],
      emptyStateMessage:
          'Profile details will sync here after the backend profile endpoint responds.',
    ),
    _ => buildStudentPageData('dashboard'),
  };
}
