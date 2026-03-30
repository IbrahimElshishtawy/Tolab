import 'package:flutter/material.dart';

import '../../academy_panel/models/academy_models.dart';

const List<RoleNavItem> adminNavigationItems = [
  RoleNavItem(
    key: 'dashboard',
    title: 'Dashboard',
    route: '/admin/dashboard',
    icon: Icons.space_dashboard_rounded,
    description: 'Overview and operational pulse.',
  ),
  RoleNavItem(
    key: 'students-management',
    title: 'Students',
    route: '/admin/students-management',
    icon: Icons.school_rounded,
    description: 'Admissions, status, and support.',
  ),
  RoleNavItem(
    key: 'staff-management',
    title: 'Staff',
    route: '/admin/staff-management',
    icon: Icons.groups_rounded,
    description: 'Faculty and assistants workspace.',
  ),
  RoleNavItem(
    key: 'departments',
    title: 'Departments',
    route: '/admin/departments',
    icon: Icons.apartment_rounded,
    description: 'Academic structure and ownership.',
  ),
  RoleNavItem(
    key: 'sections',
    title: 'Sections',
    route: '/admin/sections',
    icon: Icons.dashboard_customize_rounded,
    description: 'Section capacity and operations.',
  ),
  RoleNavItem(
    key: 'subjects',
    title: 'Subjects',
    route: '/admin/subjects',
    icon: Icons.menu_book_rounded,
    description: 'Subject catalog and publishing.',
  ),
  RoleNavItem(
    key: 'course-offerings',
    title: 'Offerings',
    route: '/admin/course-offerings',
    icon: Icons.auto_graph_rounded,
    description: 'Semester teaching matrix.',
  ),
  RoleNavItem(
    key: 'enrollments',
    title: 'Enrollments',
    route: '/admin/enrollments',
    icon: Icons.assignment_turned_in_rounded,
    description: 'Student-course enrollment pipeline.',
  ),
  RoleNavItem(
    key: 'content-management',
    title: 'Content',
    route: '/admin/content-management',
    icon: Icons.library_books_rounded,
    description: 'Lectures, summaries, exams, and files.',
  ),
  RoleNavItem(
    key: 'schedule-calendar',
    title: 'Schedule',
    route: '/admin/schedule-calendar',
    icon: Icons.calendar_month_rounded,
    description: 'Academic calendar and timetable.',
  ),
  RoleNavItem(
    key: 'notifications',
    title: 'Notifications',
    route: '/admin/notifications',
    icon: Icons.notifications_active_rounded,
    description: 'Broadcasts and delivery tracking.',
  ),
  RoleNavItem(
    key: 'moderation',
    title: 'Moderation',
    route: '/admin/moderation',
    icon: Icons.gpp_good_rounded,
    description: 'Risk review and intervention queue.',
  ),
  RoleNavItem(
    key: 'roles-permissions',
    title: 'Roles',
    route: '/admin/roles-permissions',
    icon: Icons.admin_panel_settings_rounded,
    description: 'Permission design and governance.',
  ),
  RoleNavItem(
    key: 'settings',
    title: 'Settings',
    route: '/admin/settings',
    icon: Icons.tune_rounded,
    description: 'System settings and preferences.',
  ),
  RoleNavItem(
    key: 'uploads',
    title: 'Uploads',
    route: '/admin/uploads',
    icon: Icons.cloud_upload_rounded,
    description: 'Desktop drag-drop and mobile file pickers.',
  ),
];

class AdminPageBlueprint {
  const AdminPageBlueprint({
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

const Map<String, AdminPageBlueprint> _adminBlueprints = {
  'students-management': AdminPageBlueprint(
    title: 'Students Management',
    subtitle: 'Admissions, status, risk flags, and lifecycle operations.',
    endpoints: [
      'GET /admin/users',
      'POST /admin/users',
      'PUT /admin/users/{id}',
    ],
    actionLabel: 'Add Student',
    columns: [
      PanelTableColumn(label: 'ID', key: 'id'),
      PanelTableColumn(label: 'Name', key: 'name'),
      PanelTableColumn(label: 'Email', key: 'email'),
      PanelTableColumn(label: 'Department', key: 'department'),
      PanelTableColumn(label: 'Status', key: 'status'),
    ],
    sampleRows: [
      {
        'id': 'ST-2401',
        'name': 'Mariam Ehab',
        'email': 'mariam@tolab.edu',
        'department': 'Computer Science',
        'status': 'Active',
      },
      {
        'id': 'ST-2402',
        'name': 'Youssef Ali',
        'email': 'youssef@tolab.edu',
        'department': 'Information Systems',
        'status': 'Probation',
      },
      {
        'id': 'ST-2403',
        'name': 'Lina Hatem',
        'email': 'lina@tolab.edu',
        'department': 'Engineering',
        'status': 'Active',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Registration Health',
        value: '97.2%',
        caption: 'Students with complete enrollment records',
        icon: Icons.assignment_turned_in_rounded,
      ),
      PanelInfoCard(
        title: 'Support Queue',
        value: '29 open',
        caption: 'Academic advising and clearance requests',
        icon: Icons.support_agent_rounded,
      ),
    ],
  ),
  'staff-management': AdminPageBlueprint(
    title: 'Staff Management',
    subtitle: 'Doctors, assistants, permissions, and teaching load balance.',
    endpoints: [
      'GET /admin/users',
      'POST /admin/users',
      'PATCH /admin/users/{id}/activate',
    ],
    actionLabel: 'Invite Staff',
    columns: [
      PanelTableColumn(label: 'ID', key: 'id'),
      PanelTableColumn(label: 'Name', key: 'name'),
      PanelTableColumn(label: 'Role', key: 'role'),
      PanelTableColumn(label: 'Department', key: 'department'),
      PanelTableColumn(label: 'Load', key: 'load'),
    ],
    sampleRows: [
      {
        'id': 'SF-102',
        'name': 'Dr. Karim Hassan',
        'role': 'Doctor',
        'department': 'Engineering',
        'load': '4 courses',
      },
      {
        'id': 'SF-155',
        'name': 'Sara Adel',
        'role': 'Assistant',
        'department': 'Computer Science',
        'load': '7 sections',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Coverage',
        value: '100%',
        caption: 'All published offerings have an assigned owner',
        icon: Icons.fact_check_rounded,
      ),
      PanelInfoCard(
        title: 'Pending Reviews',
        value: '12 contracts',
        caption: 'Awaiting HR and dean confirmation',
        icon: Icons.badge_rounded,
      ),
    ],
  ),
  'departments': AdminPageBlueprint(
    title: 'Departments',
    subtitle: 'Department hierarchy, student mix, and staffing coverage.',
    endpoints: ['GET /departments', 'POST /admin/departments'],
    actionLabel: 'Create Department',
    columns: [
      PanelTableColumn(label: 'Name', key: 'name'),
      PanelTableColumn(label: 'Head', key: 'head'),
      PanelTableColumn(label: 'Students', key: 'students'),
      PanelTableColumn(label: 'Staff', key: 'staff'),
      PanelTableColumn(label: 'Status', key: 'status'),
    ],
    sampleRows: [
      {
        'name': 'Computer Science',
        'head': 'Dr. Heba Samir',
        'students': '820',
        'staff': '41',
        'status': 'Healthy',
      },
      {
        'name': 'Engineering',
        'head': 'Dr. Ahmed Mostafa',
        'students': '670',
        'staff': '36',
        'status': 'Review',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Department Growth',
        value: '+8%',
        caption: 'Highest intake growth in Information Systems',
        icon: Icons.trending_up_rounded,
      ),
      PanelInfoCard(
        title: 'Subject Ownership',
        value: '99%',
        caption: 'All subjects mapped to a supervising department',
        icon: Icons.account_tree_rounded,
      ),
    ],
  ),
  'sections': AdminPageBlueprint(
    title: 'Sections',
    subtitle: 'Section capacity, room alignment, and session readiness.',
    endpoints: ['GET /sections', 'POST /admin/sections'],
    actionLabel: 'Create Section',
    columns: [
      PanelTableColumn(label: 'Section', key: 'name'),
      PanelTableColumn(label: 'Department', key: 'department'),
      PanelTableColumn(label: 'Capacity', key: 'capacity'),
      PanelTableColumn(label: 'Advisor', key: 'advisor'),
      PanelTableColumn(label: 'Status', key: 'status'),
    ],
    sampleRows: [
      {
        'name': 'CS-2A',
        'department': 'Computer Science',
        'capacity': '120',
        'advisor': 'Dr. Rana Adel',
        'status': 'Open',
      },
      {
        'name': 'ENG-3B',
        'department': 'Engineering',
        'capacity': '90',
        'advisor': 'Dr. Mona Samy',
        'status': 'Closed',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Capacity Utilization',
        value: '88%',
        caption: '14 sections are above the target load threshold',
        icon: Icons.groups_rounded,
      ),
    ],
  ),
  'subjects': AdminPageBlueprint(
    title: 'Subjects',
    subtitle: 'Catalog design, prerequisites, and semester readiness.',
    endpoints: [
      'GET /subjects',
      'POST /admin/subjects',
      'PUT /admin/subjects/{id}',
    ],
    actionLabel: 'Add Subject',
    columns: [
      PanelTableColumn(label: 'Code', key: 'code'),
      PanelTableColumn(label: 'Subject', key: 'name'),
      PanelTableColumn(label: 'Department', key: 'department'),
      PanelTableColumn(label: 'Credit Hours', key: 'hours'),
      PanelTableColumn(label: 'Status', key: 'status'),
    ],
    sampleRows: [
      {
        'code': 'CS301',
        'name': 'Operating Systems',
        'department': 'Computer Science',
        'hours': '3',
        'status': 'Published',
      },
      {
        'code': 'IS210',
        'name': 'Systems Analysis',
        'department': 'Information Systems',
        'hours': '3',
        'status': 'Draft',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Catalog Completeness',
        value: '91%',
        caption: 'Missing outline details in 14 subject shells',
        icon: Icons.task_alt_rounded,
      ),
    ],
  ),
  'course-offerings': AdminPageBlueprint(
    title: 'Course Offerings',
    subtitle: 'Semester offerings, staff assignment, and capacity mix.',
    endpoints: ['GET /admin/course-offerings', 'POST /admin/course-offerings'],
    actionLabel: 'Create Offering',
    columns: [
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Section', key: 'section'),
      PanelTableColumn(label: 'Doctor', key: 'doctor'),
      PanelTableColumn(label: 'Assistant', key: 'assistant'),
      PanelTableColumn(label: 'Status', key: 'status'),
    ],
    sampleRows: [
      {
        'course': 'Operating Systems',
        'section': 'CS-2A',
        'doctor': 'Dr. Karim Hassan',
        'assistant': 'Sara Adel',
        'status': 'Live',
      },
      {
        'course': 'Database Systems',
        'section': 'CS-3A',
        'doctor': 'Dr. Heba Samir',
        'assistant': 'Ola Gamal',
        'status': 'Planned',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Published Offerings',
        value: '184',
        caption: '23 still awaiting final staffing confirmation',
        icon: Icons.view_kanban_rounded,
      ),
    ],
  ),
  'enrollments': AdminPageBlueprint(
    title: 'Enrollments',
    subtitle: 'Enrollment requests, approvals, and bulk operations.',
    endpoints: [
      'GET /admin/enrollments',
      'POST /admin/enrollments',
      'POST /admin/enrollments/bulk-upload',
    ],
    actionLabel: 'New Enrollment',
    columns: [
      PanelTableColumn(label: 'Student', key: 'student'),
      PanelTableColumn(label: 'Course', key: 'course'),
      PanelTableColumn(label: 'Status', key: 'status'),
      PanelTableColumn(label: 'Requested', key: 'requested_at'),
      PanelTableColumn(label: 'By', key: 'approved_by'),
    ],
    sampleRows: [
      {
        'student': 'Mariam Ehab',
        'course': 'Operating Systems',
        'status': 'Approved',
        'requested_at': '29 Mar',
        'approved_by': 'Auto rule',
      },
      {
        'student': 'Youssef Ali',
        'course': 'Computer Networks',
        'status': 'Pending',
        'requested_at': '30 Mar',
        'approved_by': 'Advisor review',
      },
    ],
    cards: [
      PanelInfoCard(
        title: 'Bulk Uploads',
        value: '3 active batches',
        caption: 'Largest import includes 420 rows',
        icon: Icons.upload_file_rounded,
      ),
    ],
  ),
};

RolePageData buildAdminPageData(
  String pageKey, {
  JsonMap payload = const {},
  List<AcademyNotificationItem> notifications = const [],
}) {
  final records = payload['records'] is List
      ? List<Map<String, dynamic>>.from(payload['records'] as List)
      : const <JsonMap>[];

  if (_adminBlueprints.containsKey(pageKey)) {
    final blueprint = _adminBlueprints[pageKey]!;
    return RolePageData(
      key: pageKey,
      title: blueprint.title,
      subtitle: blueprint.subtitle,
      breadcrumbs: ['Admin', blueprint.title],
      quickJumps: const [
        QuickJumpItem(sectionId: 'summary', label: 'Summary'),
        QuickJumpItem(sectionId: 'table', label: 'Table'),
      ],
      sections: [
        PageSectionData(
          id: 'summary',
          title: '${blueprint.title} Snapshot',
          subtitle:
              'A premium overview with responsive cards and quick interpretation.',
          type: PageSectionType.cards,
          cards: blueprint.cards,
        ),
        PageSectionData(
          id: 'table',
          title: '${blueprint.title} Table',
          subtitle: 'Sticky headers and scrollable rows for larger datasets.',
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
          '${blueprint.title} will populate here after the page syncs with Laravel.',
    );
  }

  return switch (pageKey) {
    'dashboard' => _dashboardPage(records),
    'content-management' => _contentPage(records),
    'schedule-calendar' => _schedulePage(),
    'notifications' => _notificationsPage(notifications),
    'moderation' => _moderationPage(),
    'roles-permissions' => _rolesPage(),
    'settings' => _settingsPage(),
    'uploads' => _uploadsPage(),
    _ => _dashboardPage(records),
  };
}

RolePageData _dashboardPage(List<JsonMap> records) {
  return RolePageData(
    key: 'dashboard',
    title: 'Admin Dashboard',
    subtitle: 'Realtime academic health, workloads, and governance signals.',
    breadcrumbs: const ['Admin', 'Dashboard'],
    quickJumps: const [
      QuickJumpItem(sectionId: 'overview', label: 'Overview'),
      QuickJumpItem(sectionId: 'pipeline', label: 'Pipeline'),
      QuickJumpItem(sectionId: 'calendar', label: 'Calendar'),
    ],
    sections: const [
      PageSectionData(
        id: 'overview',
        title: 'Executive Metrics',
        subtitle: 'Campus-wide KPIs across learning, staffing, and quality.',
        type: PageSectionType.metrics,
        metrics: [
          PanelMetric(
            label: 'Active Students',
            value: '2418',
            delta: '+6.8%',
            icon: Icons.school_rounded,
          ),
          PanelMetric(
            label: 'Teaching Staff',
            value: '186',
            delta: '+11',
            icon: Icons.groups_rounded,
          ),
          PanelMetric(
            label: 'Open Alerts',
            value: '17',
            delta: '-3 today',
            icon: Icons.warning_amber_rounded,
          ),
          PanelMetric(
            label: 'Content SLA',
            value: '94%',
            delta: '+2.4%',
            icon: Icons.auto_stories_rounded,
          ),
        ],
      ),
      PageSectionData(
        id: 'pipeline',
        title: 'Operational Lenses',
        subtitle: 'High-signal breakdowns for action planning.',
        type: PageSectionType.cards,
        cards: [
          PanelInfoCard(
            title: 'Enrollment Throughput',
            value: '1,284 processed',
            caption: '92% auto-approved in the last 7 days',
            icon: Icons.account_tree_rounded,
          ),
          PanelInfoCard(
            title: 'Moderation Pressure',
            value: '4 urgent threads',
            caption: 'Two require dean review before 18:00',
            icon: Icons.shield_rounded,
          ),
          PanelInfoCard(
            title: 'Faculty Utilization',
            value: '82% target load',
            caption: 'Assistants absorbing 23 section sessions',
            icon: Icons.pie_chart_outline_rounded,
          ),
        ],
      ),
      PageSectionData(
        id: 'calendar',
        title: 'Today on the Academic Calendar',
        subtitle: 'Deadlines, windows, and operational moments.',
        type: PageSectionType.timeline,
        timeline: [
          PanelTimelineEntry(
            title: 'Course registration freeze',
            subtitle: 'Late-add requests switch to dean approval only',
            timeLabel: '09:00',
            location: 'Admissions',
          ),
          PanelTimelineEntry(
            title: 'Lecture upload checkpoint',
            subtitle: 'Week 7 teaching material completeness review',
            timeLabel: '13:00',
            location: 'Quality Office',
          ),
          PanelTimelineEntry(
            title: 'Notification broadcast',
            subtitle: 'Exam seating update for second-year sections',
            timeLabel: '16:30',
            location: 'Communications',
          ),
        ],
      ),
    ],
    primaryActionLabel: 'Broadcast Update',
    backendEndpoints: const [
      'GET /admin/users',
      'GET /admin/course-offerings',
      'GET /notifications',
    ],
    emptyStateMessage:
        'Dashboard data will appear here once the backend responds.',
  );
}

RolePageData _contentPage(List<JsonMap> records) => RolePageData(
  key: 'content-management',
  title: 'Content Management',
  subtitle: 'Course materials, assessments, and publishing completeness.',
  breadcrumbs: const ['Admin', 'Content'],
  quickJumps: const [
    QuickJumpItem(sectionId: 'quality', label: 'Quality'),
    QuickJumpItem(sectionId: 'library', label: 'Library'),
    QuickJumpItem(sectionId: 'uploads', label: 'Uploads'),
  ],
  sections: [
    const PageSectionData(
      id: 'quality',
      title: 'Content Readiness',
      subtitle: 'Lecture, summary, and exam completeness.',
      type: PageSectionType.cards,
      cards: [
        PanelInfoCard(
          title: 'Lecture Coverage',
          value: '87%',
          caption: 'Week 7 uploads missing in 9 offerings',
          icon: Icons.slideshow_rounded,
        ),
        PanelInfoCard(
          title: 'Assessment Mix',
          value: 'Balanced',
          caption: 'Quiz and assignment ratios on target',
          icon: Icons.rule_folder_rounded,
        ),
      ],
    ),
    PageSectionData(
      id: 'library',
      title: 'Publishing Queue',
      subtitle: 'Recent content items awaiting or completing review.',
      type: PageSectionType.table,
      table: PanelTableData(
        columns: const [
          PanelTableColumn(label: 'Course', key: 'course'),
          PanelTableColumn(label: 'Asset', key: 'asset'),
          PanelTableColumn(label: 'Owner', key: 'owner'),
          PanelTableColumn(label: 'State', key: 'state'),
        ],
        rows:
            (records.isEmpty
                    ? const [
                        {
                          'course': 'Operating Systems',
                          'asset': 'Week 7 lecture deck',
                          'owner': 'Dr. Karim Hassan',
                          'state': 'Awaiting QA',
                        },
                        {
                          'course': 'Database Systems',
                          'asset': 'Lab sheet 04',
                          'owner': 'Ola Gamal',
                          'state': 'Published',
                        },
                      ]
                    : records)
                .map(PanelTableRow.new)
                .toList(),
      ),
    ),
    const PageSectionData(
      id: 'uploads',
      title: 'File Ingestion',
      subtitle:
          'Desktop drag-drop and mobile picker support wired to Laravel upload endpoints.',
      type: PageSectionType.uploads,
      uploads: [
        UploadItem(
          name: 'lecture_week_07.pdf',
          status: 'Synced',
          sizeLabel: '8.2 MB',
        ),
        UploadItem(
          name: 'midterm_blueprint.xlsx',
          status: 'Queued',
          sizeLabel: '1.4 MB',
        ),
      ],
      allowUploads: true,
    ),
  ],
  primaryActionLabel: 'Publish Content',
  backendEndpoints: const [
    'POST /admin/courses/{courseOffering}/lectures',
    'POST /admin/courses/{courseOffering}/assessments',
    'POST /files/upload',
  ],
  emptyStateMessage:
      'Content publishing metrics will appear here once files are available.',
);

RolePageData _schedulePage() => const RolePageData(
  key: 'schedule-calendar',
  title: 'Schedule & Calendar',
  subtitle:
      'Cross-department scheduling, timeline collisions, and key academic windows.',
  breadcrumbs: ['Admin', 'Schedule'],
  quickJumps: [
    QuickJumpItem(sectionId: 'summary', label: 'Summary'),
    QuickJumpItem(sectionId: 'timeline', label: 'Timeline'),
  ],
  sections: [
    PageSectionData(
      id: 'summary',
      title: 'Schedule Health',
      subtitle: 'Conflict detection and room allocation coverage.',
      type: PageSectionType.metrics,
      metrics: [
        PanelMetric(
          label: 'Conflicts',
          value: '5',
          delta: '-7 this week',
          icon: Icons.event_busy_rounded,
        ),
        PanelMetric(
          label: 'Room Coverage',
          value: '98%',
          delta: '+3%',
          icon: Icons.meeting_room_rounded,
        ),
        PanelMetric(
          label: 'Exam Windows',
          value: '12',
          delta: '2 draft',
          icon: Icons.fact_check_rounded,
        ),
      ],
    ),
    PageSectionData(
      id: 'timeline',
      title: 'Next Major Events',
      subtitle: 'Windows that impact multiple departments.',
      type: PageSectionType.timeline,
      timeline: [
        PanelTimelineEntry(
          title: 'Midterm exam freeze',
          subtitle: 'Schedule edits require dean approval after this point',
          timeLabel: '02 Apr',
          location: 'Exam Office',
        ),
        PanelTimelineEntry(
          title: 'Holiday reschedule review',
          subtitle: 'Lab blocks reallocated for national holiday',
          timeLabel: '04 Apr',
          location: 'Campus Ops',
        ),
      ],
    ),
  ],
  primaryActionLabel: 'Plan Event',
  backendEndpoints: [
    'POST /admin/courses/{courseOffering}/schedule-events',
    'POST /admin/schedule-events/bulk',
  ],
  emptyStateMessage:
      'Calendar data will render here when schedule feeds are connected.',
);

RolePageData _notificationsPage(List<AcademyNotificationItem> notifications) =>
    RolePageData(
      key: 'notifications',
      title: 'Notifications',
      subtitle:
          'Realtime delivery queue, announcements, and audience targeting.',
      breadcrumbs: const ['Admin', 'Notifications'],
      quickJumps: const [
        QuickJumpItem(sectionId: 'feed', label: 'Feed'),
        QuickJumpItem(sectionId: 'delivery', label: 'Delivery'),
      ],
      sections: [
        PageSectionData(
          id: 'feed',
          title: 'Live Notification Feed',
          subtitle: 'First-in-first-out toasts are also mirrored here.',
          type: PageSectionType.list,
          items: notifications.isEmpty
              ? const [
                  PanelListItem(
                    title: 'Exam seating update',
                    subtitle: 'Sent to second-year students and assistants',
                    meta: '2 min ago',
                    status: 'Delivered',
                    icon: Icons.campaign_rounded,
                  ),
                  PanelListItem(
                    title: 'Content readiness reminder',
                    subtitle: 'Sent to staff with incomplete Week 7 materials',
                    meta: '18 min ago',
                    status: 'Queued',
                    icon: Icons.notifications_active_rounded,
                  ),
                ]
              : notifications
                    .map(
                      (item) => PanelListItem(
                        title: item.title,
                        subtitle: item.body,
                        meta: item.relativeLabel,
                        status: item.isRead ? 'Read' : 'Unread',
                        icon: Icons.notifications_active_rounded,
                      ),
                    )
                    .toList(),
        ),
        const PageSectionData(
          id: 'delivery',
          title: 'Audience Health',
          subtitle: 'Delivery efficiency across segments.',
          type: PageSectionType.cards,
          cards: [
            PanelInfoCard(
              title: 'Delivery Success',
              value: '98.7%',
              caption: 'Push + socket + local notification chain stable',
              icon: Icons.wifi_tethering_rounded,
            ),
            PanelInfoCard(
              title: 'Unread Broadcasts',
              value: '143',
              caption: 'Mainly among first-year students',
              icon: Icons.mark_email_unread_rounded,
            ),
          ],
        ),
      ],
      primaryActionLabel: 'Send Broadcast',
      backendEndpoints: const [
        'GET /notifications',
        'POST /admin/notifications/broadcast',
      ],
      emptyStateMessage:
          'Notifications will appear after the realtime channel starts.',
    );

RolePageData _moderationPage() => const RolePageData(
  key: 'moderation',
  title: 'Moderation',
  subtitle: 'Reported activity, escalation paths, and governance decisions.',
  breadcrumbs: ['Admin', 'Moderation'],
  quickJumps: [
    QuickJumpItem(sectionId: 'risk', label: 'Risk'),
    QuickJumpItem(sectionId: 'queue', label: 'Queue'),
  ],
  sections: [
    PageSectionData(
      id: 'risk',
      title: 'Policy Risk Snapshot',
      subtitle: 'Current moderation exposure.',
      type: PageSectionType.cards,
      cards: [
        PanelInfoCard(
          title: 'Critical Reports',
          value: '4',
          caption: 'Two discussion threads, one DM chain, one comment',
          icon: Icons.report_gmailerrorred_rounded,
        ),
        PanelInfoCard(
          title: 'Mean Resolution',
          value: '2.6 hrs',
          caption: 'Down from 3.9 hrs last week',
          icon: Icons.timer_outlined,
        ),
      ],
    ),
    PageSectionData(
      id: 'queue',
      title: 'Review Queue',
      subtitle: 'Cases requiring direct action.',
      type: PageSectionType.table,
      table: PanelTableData(
        columns: [
          PanelTableColumn(label: 'Type', key: 'type'),
          PanelTableColumn(label: 'Reporter', key: 'reporter'),
          PanelTableColumn(label: 'Channel', key: 'channel'),
          PanelTableColumn(label: 'Status', key: 'status'),
        ],
        rows: [
          PanelTableRow({
            'type': 'Post',
            'reporter': 'Student #2401',
            'channel': 'Course group',
            'status': 'Urgent',
          }),
          PanelTableRow({
            'type': 'Message',
            'reporter': 'Assistant #15',
            'channel': 'Direct messages',
            'status': 'Review',
          }),
        ],
      ),
    ),
  ],
  primaryActionLabel: 'Escalate Case',
  backendEndpoints: [
    'DELETE /admin/posts/{id}',
    'DELETE /admin/comments/{id}',
    'DELETE /admin/messages/{id}',
  ],
  emptyStateMessage: 'Moderation cases will populate when reports are filed.',
);

RolePageData _rolesPage() => const RolePageData(
  key: 'roles-permissions',
  title: 'Roles & Permissions',
  subtitle:
      'Access control matrix across admin, doctors, assistants, and students.',
  breadcrumbs: ['Admin', 'Roles & Permissions'],
  quickJumps: [
    QuickJumpItem(sectionId: 'matrix', label: 'Matrix'),
    QuickJumpItem(sectionId: 'review', label: 'Review'),
  ],
  sections: [
    PageSectionData(
      id: 'matrix',
      title: 'Permission Overview',
      subtitle: 'Key permission clusters for operational safety.',
      type: PageSectionType.cards,
      cards: [
        PanelInfoCard(
          title: 'Admin policies',
          value: '42 rules',
          caption: 'Cover user management, moderation, and audit actions',
          icon: Icons.policy_rounded,
        ),
        PanelInfoCard(
          title: 'Custom assistants',
          value: '18',
          caption: 'Course-scoped overrides active this semester',
          icon: Icons.verified_user_rounded,
        ),
      ],
    ),
    PageSectionData(
      id: 'review',
      title: 'Review Requests',
      subtitle: 'Permission changes awaiting approval.',
      type: PageSectionType.table,
      table: PanelTableData(
        columns: [
          PanelTableColumn(label: 'User', key: 'user'),
          PanelTableColumn(label: 'Requested Access', key: 'access'),
          PanelTableColumn(label: 'Scope', key: 'scope'),
          PanelTableColumn(label: 'State', key: 'state'),
        ],
        rows: [
          PanelTableRow({
            'user': 'Sara Adel',
            'access': 'Exam publishing',
            'scope': 'CS301',
            'state': 'Pending',
          }),
          PanelTableRow({
            'user': 'Dr. Mona Samy',
            'access': 'Bulk grading',
            'scope': 'Department',
            'state': 'Approved',
          }),
        ],
      ),
    ),
  ],
  primaryActionLabel: 'Create Role',
  backendEndpoints: ['LOCAL permission matrix state'],
  emptyStateMessage:
      'Role governance will appear here once permission services are connected.',
);

RolePageData _settingsPage() => const RolePageData(
  key: 'settings',
  title: 'Settings',
  subtitle:
      'Institution defaults, notifications, security posture, and presentation controls.',
  breadcrumbs: ['Admin', 'Settings'],
  quickJumps: [
    QuickJumpItem(sectionId: 'workspace', label: 'Workspace'),
    QuickJumpItem(sectionId: 'security', label: 'Security'),
  ],
  sections: [
    PageSectionData(
      id: 'workspace',
      title: 'Workspace Presets',
      subtitle: 'Visual and operational defaults for the control center.',
      type: PageSectionType.cards,
      cards: [
        PanelInfoCard(
          title: 'Theme Mode',
          value: 'Adaptive',
          caption: 'System-aware with manual override in the top bar',
          icon: Icons.contrast_rounded,
        ),
        PanelInfoCard(
          title: 'Toast Queue',
          value: 'FIFO',
          caption: 'Realtime alerts surface in chronological order',
          icon: Icons.view_stream_rounded,
        ),
      ],
    ),
    PageSectionData(
      id: 'security',
      title: 'Security Controls',
      subtitle: 'Key posture settings and token hygiene.',
      type: PageSectionType.list,
      items: [
        PanelListItem(
          title: 'API target',
          subtitle: 'http://127.0.0.1:8000/api',
          meta: 'Configured',
          status: 'Healthy',
          icon: Icons.cloud_done_rounded,
        ),
        PanelListItem(
          title: 'Realtime socket',
          subtitle: 'ws://127.0.0.1:8000/ws/admin/notifications',
          meta: 'Fallback polling available',
          status: 'Active',
          icon: Icons.wifi_rounded,
        ),
      ],
    ),
  ],
  primaryActionLabel: 'Save Settings',
  backendEndpoints: ['GET /me/profile', 'PUT /me/profile'],
  emptyStateMessage:
      'Settings are ready to sync once the backend profile is available.',
);

RolePageData _uploadsPage() => const RolePageData(
  key: 'uploads',
  title: 'Uploads',
  subtitle:
      'Secure upload center for spreadsheets, lectures, summaries, and exam assets.',
  breadcrumbs: ['Admin', 'Uploads'],
  quickJumps: [
    QuickJumpItem(sectionId: 'dropzone', label: 'Dropzone'),
    QuickJumpItem(sectionId: 'history', label: 'History'),
  ],
  sections: [
    PageSectionData(
      id: 'dropzone',
      title: 'Smart Intake',
      subtitle: 'Drag files on desktop or pick files on mobile and tablet.',
      type: PageSectionType.uploads,
      uploads: [
        UploadItem(
          name: 'students_import_march.csv',
          status: 'Processed',
          sizeLabel: '640 KB',
        ),
        UploadItem(
          name: 'networking_week_07.pptx',
          status: 'Uploaded',
          sizeLabel: '14.8 MB',
        ),
      ],
      allowUploads: true,
    ),
    PageSectionData(
      id: 'history',
      title: 'Recent Upload Jobs',
      subtitle: 'Validation results and sync feedback.',
      type: PageSectionType.list,
      items: [
        PanelListItem(
          title: 'Users import batch',
          subtitle: '408 rows validated successfully',
          meta: '12 min ago',
          status: 'Completed',
          icon: Icons.file_upload_outlined,
        ),
        PanelListItem(
          title: 'Lecture assets pack',
          subtitle: '2 files still processing OCR and preview generation',
          meta: '41 min ago',
          status: 'Processing',
          icon: Icons.cloud_sync_rounded,
        ),
      ],
    ),
  ],
  primaryActionLabel: 'Upload Files',
  backendEndpoints: [
    'POST /files/upload',
    'POST /admin/enrollments/bulk-upload',
  ],
  emptyStateMessage:
      'Upload activity appears here after the first file batch is submitted.',
);
