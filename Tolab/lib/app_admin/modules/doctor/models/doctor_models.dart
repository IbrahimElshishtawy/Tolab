import 'package:flutter/material.dart';

import '../../academy_panel/models/academy_models.dart';

const List<RoleNavItem> doctorNavigationItems = [
  RoleNavItem(
    key: 'dashboard',
    title: 'Dashboard',
    route: '/doctor/dashboard',
    icon: Icons.dashboard_rounded,
    description: 'Teaching overview.',
  ),
  RoleNavItem(
    key: 'assigned-courses',
    title: 'Assigned Courses',
    route: '/doctor/assigned-courses',
    icon: Icons.school_rounded,
    description: 'Course ownership and sections.',
  ),
  RoleNavItem(
    key: 'lecture-uploads',
    title: 'Lecture Uploads',
    route: '/doctor/lecture-uploads',
    icon: Icons.cloud_upload_rounded,
    description: 'Course materials publishing.',
  ),
  RoleNavItem(
    key: 'tasks',
    title: 'Tasks',
    route: '/doctor/tasks',
    icon: Icons.assignment_rounded,
    description: 'Assignments and workflow.',
  ),
  RoleNavItem(
    key: 'exams',
    title: 'Exams',
    route: '/doctor/exams',
    icon: Icons.fact_check_rounded,
    description: 'Exam setup and monitoring.',
  ),
  RoleNavItem(
    key: 'student-performance',
    title: 'Performance',
    route: '/doctor/student-performance',
    icon: Icons.insights_rounded,
    description: 'Grades and student signals.',
  ),
  RoleNavItem(
    key: 'calendar',
    title: 'Calendar',
    route: '/doctor/calendar',
    icon: Icons.calendar_month_rounded,
    description: 'Teaching calendar and sessions.',
  ),
  RoleNavItem(
    key: 'notifications',
    title: 'Notifications',
    route: '/doctor/notifications',
    icon: Icons.notifications_rounded,
    description: 'Realtime staff updates.',
  ),
  RoleNavItem(
    key: 'profile',
    title: 'Profile',
    route: '/doctor/profile',
    icon: Icons.person_rounded,
    description: 'Teaching profile and preferences.',
  ),
];

class DoctorPageBlueprint {
  const DoctorPageBlueprint({
    required this.title,
    required this.subtitle,
    required this.endpoints,
    required this.actionLabel,
    this.columns = const [],
    this.sampleRows = const [],
    this.cards = const [],
    this.allowUploads = false,
  });

  final String title;
  final String subtitle;
  final List<String> endpoints;
  final String actionLabel;
  final List<PanelTableColumn> columns;
  final List<JsonMap> sampleRows;
  final List<PanelInfoCard> cards;
  final bool allowUploads;
}

const Map<String, DoctorPageBlueprint> _doctorBlueprints = {
  'assigned-courses': DoctorPageBlueprint(
    title: 'Assigned Courses',
    subtitle: 'Active teaching load across lectures, sections, and assistants.',
    endpoints: ['GET /admin/course-offerings'],
    actionLabel: 'Refresh Load',
    columns: [
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Section', key: 'section'),
      PanelTableColumn(label: 'Assistant', key: 'assistant'),
      PanelTableColumn(label: 'Status', key: 'status'),
    ],
    sampleRows: [
      {
        'course': 'Operating Systems',
        'section': 'CS-2A',
        'assistant': 'Sara Adel',
        'status': 'Live',
      },
      {
        'course': 'Computer Networks',
        'section': 'CS-3A',
        'assistant': 'Ola Gamal',
        'status': 'Live',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Weekly Contact Hours',
        value: '14 hrs',
        caption: 'Across lectures, labs, and office hours',
        icon: Icons.schedule_rounded,
      ),
      PanelInfoCard(
        title: 'Students Covered',
        value: '286',
        caption: 'Across two courses and three sections',
        icon: Icons.groups_rounded,
      ),
    ],
  ),
  'tasks': DoctorPageBlueprint(
    title: 'Tasks',
    subtitle: 'Assignment release, grading flow, and rubric readiness.',
    endpoints: ['POST /admin/courses/{courseOffering}/assessments'],
    actionLabel: 'Create Task',
    columns: [
      PanelTableColumn(label: 'Task', key: 'task'),
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Due', key: 'due'),
      PanelTableColumn(label: 'State', key: 'state'),
    ],
    sampleRows: [
      {
        'task': 'Scheduler design lab',
        'course': 'Operating Systems',
        'due': '02 Apr',
        'state': 'Published',
      },
      {
        'task': 'Routing worksheet',
        'course': 'Computer Networks',
        'due': '05 Apr',
        'state': 'Draft',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Submissions Pending',
        value: '61',
        caption: 'Need review within the next 48 hours',
        icon: Icons.pending_actions_rounded,
      ),
    ],
  ),
  'exams': DoctorPageBlueprint(
    title: 'Exams',
    subtitle: 'Exam blueprint, publication, and grading visibility.',
    endpoints: [
      'POST /admin/courses/{courseOffering}/exams',
      'GET /admin/courses/{courseOffering}/grades',
    ],
    actionLabel: 'Create Exam',
    columns: [
      PanelTableColumn(label: 'Exam', key: 'exam'),
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Window', key: 'window'),
      PanelTableColumn(label: 'State', key: 'state'),
    ],
    sampleRows: [
      {
        'exam': 'Midterm',
        'course': 'Operating Systems',
        'window': '14 Apr 11:00',
        'state': 'Published',
      },
      {
        'exam': 'Practical',
        'course': 'Computer Networks',
        'window': '18 Apr 09:00',
        'state': 'Draft',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Grading Velocity',
        value: '72%',
        caption: 'Midterm rubric is partially pre-configured',
        icon: Icons.auto_awesome_rounded,
      ),
    ],
  ),
  'student-performance': DoctorPageBlueprint(
    title: 'Student Performance',
    subtitle:
        'Grade visibility, at-risk cohorts, and intervention opportunities.',
    endpoints: ['GET /admin/courses/{courseOffering}/grades'],
    actionLabel: 'Open Gradebook',
    columns: [
      PanelTableColumn(label: 'Student', key: 'student'),
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Average', key: 'average'),
      PanelTableColumn(label: 'Risk', key: 'risk'),
    ],
    sampleRows: [
      {
        'student': 'Mariam Ehab',
        'course': 'Operating Systems',
        'average': '88',
        'risk': 'Low',
      },
      {
        'student': 'Youssef Ali',
        'course': 'Computer Networks',
        'average': '64',
        'risk': 'Medium',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'At-Risk Students',
        value: '7',
        caption: 'Attendance or grade signals are below threshold',
        icon: Icons.monitor_heart_rounded,
      ),
      PanelInfoCard(
        title: 'Class Average',
        value: '78.4',
        caption: 'Across active courses this semester',
        icon: Icons.bar_chart_rounded,
      ),
    ],
  ),
};

RolePageData buildDoctorPageData(
  String pageKey, {
  JsonMap payload = const {},
  List<AcademyNotificationItem> notifications = const [],
}) {
  final records = payload['records'] is List
      ? List<Map<String, dynamic>>.from(payload['records'] as List)
      : const <JsonMap>[];

  if (_doctorBlueprints.containsKey(pageKey)) {
    final blueprint = _doctorBlueprints[pageKey]!;
    return RolePageData(
      key: pageKey,
      title: blueprint.title,
      subtitle: blueprint.subtitle,
      breadcrumbs: ['Doctor', blueprint.title],
      quickJumps: const [
        QuickJumpItem(sectionId: 'summary', label: 'Summary'),
        QuickJumpItem(sectionId: 'table', label: 'Table'),
      ],
      sections: [
        PageSectionData(
          id: 'summary',
          title: '${blueprint.title} Snapshot',
          subtitle: 'Focused teaching analytics and operational context.',
          type: PageSectionType.cards,
          cards: blueprint.cards,
        ),
        PageSectionData(
          id: 'table',
          title: '${blueprint.title} Table',
          subtitle: 'Scrollable tables designed for larger faculty dashboards.',
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
          '${blueprint.title} will sync here after the doctor workspace API responds.',
    );
  }

  return switch (pageKey) {
    'dashboard' => const RolePageData(
      key: 'dashboard',
      title: 'Doctor Dashboard',
      subtitle:
          'Teaching load, publishing cadence, and learner signals in one premium workspace.',
      breadcrumbs: ['Doctor', 'Dashboard'],
      quickJumps: [
        QuickJumpItem(sectionId: 'overview', label: 'Overview'),
        QuickJumpItem(sectionId: 'today', label: 'Today'),
      ],
      sections: [
        PageSectionData(
          id: 'overview',
          title: 'Teaching Snapshot',
          subtitle: 'Key signals for the current teaching week.',
          type: PageSectionType.metrics,
          metrics: [
            PanelMetric(
              label: 'Live Courses',
              value: '2',
              delta: '3 sections',
              icon: Icons.cast_for_education_rounded,
            ),
            PanelMetric(
              label: 'Unread Student Issues',
              value: '6',
              delta: '-2 today',
              icon: Icons.mark_chat_unread_rounded,
            ),
            PanelMetric(
              label: 'Content Published',
              value: '81%',
              delta: '+1 week',
              icon: Icons.upload_file_rounded,
            ),
          ],
        ),
        PageSectionData(
          id: 'today',
          title: 'Today in Teaching',
          subtitle: 'Upcoming classes and review checkpoints.',
          type: PageSectionType.timeline,
          timeline: [
            PanelTimelineEntry(
              title: 'Operating Systems lecture',
              subtitle: 'Processes and deadlocks',
              timeLabel: '10:00',
              location: 'Hall 3',
            ),
            PanelTimelineEntry(
              title: 'Office hour',
              subtitle: 'Project consultation slot',
              timeLabel: '13:30',
              location: 'Faculty office',
            ),
            PanelTimelineEntry(
              title: 'Lab content upload',
              subtitle: 'Week 7 assets must be published before 18:00',
              timeLabel: '18:00',
              location: 'LMS',
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Upload Lecture',
      backendEndpoints: [
        'GET /admin/course-offerings',
        'POST /admin/courses/{courseOffering}/lectures',
      ],
      emptyStateMessage:
          'Teaching metrics will appear here after course data is connected.',
    ),
    'lecture-uploads' => const RolePageData(
      key: 'lecture-uploads',
      title: 'Lecture Uploads',
      subtitle:
          'Upload decks, notes, and lecture recordings with desktop drag-drop support.',
      breadcrumbs: ['Doctor', 'Lecture Uploads'],
      quickJumps: [
        QuickJumpItem(sectionId: 'dropzone', label: 'Dropzone'),
        QuickJumpItem(sectionId: 'history', label: 'History'),
      ],
      sections: [
        PageSectionData(
          id: 'dropzone',
          title: 'Course Material Upload',
          subtitle:
              'Desktop drag-drop and mobile picker tied to Laravel multipart uploads.',
          type: PageSectionType.uploads,
          uploads: [
            UploadItem(
              name: 'os_week_07_deck.pdf',
              status: 'Uploaded',
              sizeLabel: '7.9 MB',
            ),
            UploadItem(
              name: 'networks_lab_04.zip',
              status: 'Queued',
              sizeLabel: '22.1 MB',
            ),
          ],
          allowUploads: true,
        ),
        PageSectionData(
          id: 'history',
          title: 'Recent Publishing Jobs',
          subtitle: 'Quick visibility for content freshness and review.',
          type: PageSectionType.list,
          items: [
            PanelListItem(
              title: 'Operating Systems Week 06',
              subtitle: 'Lecture + summary published successfully',
              meta: 'Yesterday',
              status: 'Live',
              icon: Icons.file_present_rounded,
            ),
            PanelListItem(
              title: 'Networks Lab 03',
              subtitle: 'Still processing previews',
              meta: '1 hour ago',
              status: 'Processing',
              icon: Icons.cloud_sync_rounded,
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Upload Files',
      backendEndpoints: [
        'POST /files/upload',
        'POST /admin/courses/{courseOffering}/lectures',
      ],
      emptyStateMessage:
          'Upload history will show here after the first lecture asset is submitted.',
    ),
    'calendar' => const RolePageData(
      key: 'calendar',
      title: 'Calendar',
      subtitle: 'Teaching schedule, office hours, and assessment planning.',
      breadcrumbs: ['Doctor', 'Calendar'],
      quickJumps: [QuickJumpItem(sectionId: 'week', label: 'Week')],
      sections: [
        PageSectionData(
          id: 'week',
          title: 'Upcoming Schedule',
          subtitle: 'The next key faculty moments.',
          type: PageSectionType.timeline,
          timeline: [
            PanelTimelineEntry(
              title: 'OS lecture',
              subtitle: 'Hall 3',
              timeLabel: 'Mon 10:00',
              location: 'Building A',
            ),
            PanelTimelineEntry(
              title: 'Networks lab',
              subtitle: 'Configuration practice',
              timeLabel: 'Wed 14:00',
              location: 'Lab 4',
            ),
            PanelTimelineEntry(
              title: 'Grade review block',
              subtitle: 'Finalize rubric and publish feedback',
              timeLabel: 'Thu 17:00',
              location: 'LMS',
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Plan Session',
      backendEndpoints: [
        'POST /admin/courses/{courseOffering}/schedule-events',
      ],
      emptyStateMessage:
          'Calendar items appear here once teaching events are synced.',
    ),
    'notifications' => RolePageData(
      key: 'notifications',
      title: 'Notifications',
      subtitle: 'Student questions, admin reminders, and publishing alerts.',
      breadcrumbs: const ['Doctor', 'Notifications'],
      quickJumps: const [QuickJumpItem(sectionId: 'feed', label: 'Feed')],
      sections: [
        PageSectionData(
          id: 'feed',
          title: 'Faculty Feed',
          subtitle:
              'Realtime messages and reminders mirrored by toast notifications.',
          type: PageSectionType.list,
          items: notifications.isEmpty
              ? const [
                  PanelListItem(
                    title: 'Midterm policy update',
                    subtitle: 'New seating template is ready for review',
                    meta: '9 min ago',
                    status: 'Unread',
                    icon: Icons.campaign_rounded,
                  ),
                  PanelListItem(
                    title: 'Student asked a question',
                    subtitle: 'Discussion thread in Operating Systems group',
                    meta: '23 min ago',
                    status: 'Unread',
                    icon: Icons.forum_rounded,
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
      primaryActionLabel: 'Open Inbox',
      backendEndpoints: const ['GET /notifications'],
      emptyStateMessage:
          'Realtime faculty notifications will appear here once connected.',
    ),
    'profile' => const RolePageData(
      key: 'profile',
      title: 'Profile',
      subtitle: 'Teaching identity, department role, and workflow preferences.',
      breadcrumbs: ['Doctor', 'Profile'],
      quickJumps: [
        QuickJumpItem(sectionId: 'identity', label: 'Identity'),
        QuickJumpItem(sectionId: 'preferences', label: 'Preferences'),
      ],
      sections: [
        PageSectionData(
          id: 'identity',
          title: 'Teaching Identity',
          subtitle: 'Current department role and contact posture.',
          type: PageSectionType.cards,
          cards: [
            PanelInfoCard(
              title: 'Department',
              value: 'Engineering',
              caption: 'Senior lecturer and course owner',
              icon: Icons.apartment_rounded,
            ),
            PanelInfoCard(
              title: 'Office Hour',
              value: 'Mon 13:30',
              caption: 'Shared with assistants for student support',
              icon: Icons.meeting_room_rounded,
            ),
          ],
        ),
        PageSectionData(
          id: 'preferences',
          title: 'Workflow Preferences',
          subtitle: 'Defaults for uploads, alerts, and grading.',
          type: PageSectionType.list,
          items: [
            PanelListItem(
              title: 'Realtime notifications',
              subtitle: 'Enabled for student questions and exam changes',
              meta: 'Saved',
              status: 'On',
              icon: Icons.notifications_active_rounded,
            ),
            PanelListItem(
              title: 'Upload validation',
              subtitle: 'Require preview generation for lecture files',
              meta: 'Saved',
              status: 'Strict',
              icon: Icons.verified_rounded,
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Save Profile',
      backendEndpoints: ['GET /me/profile', 'PUT /me/profile'],
      emptyStateMessage:
          'Profile settings will appear here after the backend returns the staff profile.',
    ),
    _ => buildDoctorPageData('dashboard'),
  };
}
