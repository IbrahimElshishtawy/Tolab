import '../../../core/routing/route_paths.dart';
import '../models/dashboard_models.dart';

class DashboardSeedService {
  const DashboardSeedService();

  DashboardBundle buildBundle({required DashboardFilters filters}) {
    final trendPoints = switch (filters.timeRange) {
      DashboardTimeRange.last7Days => _last7DaysTrend,
      DashboardTimeRange.semester => _semesterTrend,
      DashboardTimeRange.last30Days => _last30DaysTrend,
    };

    return DashboardBundle(
      filters: filters,
      stats: const [
        DashboardStatCard(
          id: 'students',
          label: 'Total students',
          value: '12,480',
          deltaLabel: '+4.8% this cycle',
          deltaValue: 4.8,
          caption: 'Active students synced across departments.',
          tone: DashboardMetricTone.primary,
        ),
        DashboardStatCard(
          id: 'courses',
          label: 'Active courses',
          value: '146',
          deltaLabel: '+9 newly assigned',
          deltaValue: 9,
          caption: 'Published offerings currently visible to students.',
          tone: DashboardMetricTone.info,
        ),
        DashboardStatCard(
          id: 'approvals',
          label: 'Pending approvals',
          value: '27',
          deltaLabel: '-6 vs yesterday',
          deltaValue: -6,
          caption: 'Enrollment, content, and moderation approvals in queue.',
          tone: DashboardMetricTone.warning,
        ),
        DashboardStatCard(
          id: 'reviews',
          label: 'Review queue',
          value: '18',
          deltaLabel: '3 urgent escalations',
          deltaValue: 3,
          caption: 'Messages and comments needing senior moderation review.',
          tone: DashboardMetricTone.danger,
        ),
      ],
      trendPoints: trendPoints,
      departmentStats: const [
        DashboardDepartmentStat(
          department: 'Computer Science',
          enrollments: 2480,
          tone: DashboardMetricTone.primary,
        ),
        DashboardDepartmentStat(
          department: 'Artificial Intelligence',
          enrollments: 1960,
          tone: DashboardMetricTone.info,
        ),
        DashboardDepartmentStat(
          department: 'Information Systems',
          enrollments: 1815,
          tone: DashboardMetricTone.success,
        ),
        DashboardDepartmentStat(
          department: 'Engineering',
          enrollments: 1650,
          tone: DashboardMetricTone.warning,
        ),
        DashboardDepartmentStat(
          department: 'Business',
          enrollments: 1420,
          tone: DashboardMetricTone.primary,
        ),
        DashboardDepartmentStat(
          department: 'Design',
          enrollments: 970,
          tone: DashboardMetricTone.danger,
        ),
      ],
      taskBreakdown: const [
        DashboardTaskSlice(
          label: 'Enrollment approvals',
          value: 11,
          tone: DashboardMetricTone.primary,
        ),
        DashboardTaskSlice(
          label: 'Content validation',
          value: 7,
          tone: DashboardMetricTone.info,
        ),
        DashboardTaskSlice(
          label: 'Messages to review',
          value: 6,
          tone: DashboardMetricTone.warning,
        ),
        DashboardTaskSlice(
          label: 'System alerts',
          value: 3,
          tone: DashboardMetricTone.danger,
        ),
      ],
      directoryEntries: _directoryEntries,
      activityRows: _activityRows,
      alerts: const [
        DashboardAlertItem(
          id: 'alert-1',
          title: 'Approvals warming up',
          subtitle:
              'Eight student registrations are waiting on advisor sign-off.',
          counterLabel: '8 approvals',
          tone: DashboardMetricTone.warning,
        ),
        DashboardAlertItem(
          id: 'alert-2',
          title: 'Content moderation',
          subtitle:
              'Three uploads were flagged for copyright verification.',
          counterLabel: '3 uploads',
          tone: DashboardMetricTone.info,
        ),
        DashboardAlertItem(
          id: 'alert-3',
          title: 'Comment escalation',
          subtitle:
              'Two public threads need a senior admin decision in under 1 hour.',
          counterLabel: '2 urgent',
          tone: DashboardMetricTone.danger,
        ),
      ],
      quickActions: const [
        DashboardQuickAction(
          id: 'add-student',
          label: 'Add Student',
          subtitle: 'Create a new learner account and assign a section.',
          route: RoutePaths.students,
          tone: DashboardMetricTone.primary,
        ),
        DashboardQuickAction(
          id: 'assign-course',
          label: 'Assign Course',
          subtitle: 'Jump into offerings and connect staff to a course.',
          route: RoutePaths.courseOfferings,
          tone: DashboardMetricTone.info,
        ),
        DashboardQuickAction(
          id: 'upload-content',
          label: 'Upload Content',
          subtitle: 'Open the upload center for lectures and rich media.',
          route: RoutePaths.uploads,
          tone: DashboardMetricTone.success,
        ),
      ],
      sourceLabel: 'Local admin seed',
      refreshedAt: DateTime.now(),
      isFallback: true,
    );
  }

  List<DashboardDirectoryEntry> searchDirectory({
    required String query,
    required DashboardSearchScope scope,
    int limit = 8,
  }) {
    return _directoryEntries
        .where((entry) => entry.matchesScope(scope) && entry.matchesQuery(query))
        .take(limit)
        .toList(growable: false);
  }

  static final List<DashboardTrendPoint> _last7DaysTrend = const [
    DashboardTrendPoint(label: 'Mon', totalStudents: 11860, activeCourses: 132),
    DashboardTrendPoint(label: 'Tue', totalStudents: 11910, activeCourses: 134),
    DashboardTrendPoint(label: 'Wed', totalStudents: 11980, activeCourses: 137),
    DashboardTrendPoint(label: 'Thu', totalStudents: 12035, activeCourses: 139),
    DashboardTrendPoint(label: 'Fri', totalStudents: 12110, activeCourses: 140),
    DashboardTrendPoint(label: 'Sat', totalStudents: 12200, activeCourses: 143),
    DashboardTrendPoint(label: 'Sun', totalStudents: 12480, activeCourses: 146),
  ];

  static final List<DashboardTrendPoint> _last30DaysTrend = const [
    DashboardTrendPoint(label: 'Week 1', totalStudents: 11320, activeCourses: 126),
    DashboardTrendPoint(label: 'Week 2', totalStudents: 11510, activeCourses: 129),
    DashboardTrendPoint(label: 'Week 3', totalStudents: 11690, activeCourses: 132),
    DashboardTrendPoint(label: 'Week 4', totalStudents: 11840, activeCourses: 135),
    DashboardTrendPoint(label: 'Week 5', totalStudents: 12010, activeCourses: 138),
    DashboardTrendPoint(label: 'Week 6', totalStudents: 12160, activeCourses: 141),
    DashboardTrendPoint(label: 'Week 7', totalStudents: 12310, activeCourses: 144),
    DashboardTrendPoint(label: 'Week 8', totalStudents: 12480, activeCourses: 146),
  ];

  static final List<DashboardTrendPoint> _semesterTrend = const [
    DashboardTrendPoint(label: 'Oct', totalStudents: 10450, activeCourses: 118),
    DashboardTrendPoint(label: 'Nov', totalStudents: 10780, activeCourses: 121),
    DashboardTrendPoint(label: 'Dec', totalStudents: 11030, activeCourses: 124),
    DashboardTrendPoint(label: 'Jan', totalStudents: 11460, activeCourses: 129),
    DashboardTrendPoint(label: 'Feb', totalStudents: 11980, activeCourses: 137),
    DashboardTrendPoint(label: 'Mar', totalStudents: 12480, activeCourses: 146),
  ];

  static final List<DashboardDirectoryEntry> _directoryEntries = [
    DashboardDirectoryEntry(
      id: 'student-1',
      displayName: 'Mariam Adel',
      email: 'mariam.adel@tolab.edu',
      role: DashboardDirectoryRole.student,
      departmentLabel: 'Computer Science',
      statusLabel: 'Recently enrolled',
      lastSeenLabel: '2 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 30, 10, 18),
    ),
    DashboardDirectoryEntry(
      id: 'doctor-1',
      displayName: 'Dr. Hadeer Salah',
      email: 'hadeer.salah@tolab.edu',
      role: DashboardDirectoryRole.doctor,
      departmentLabel: 'Artificial Intelligence',
      statusLabel: 'Approver online',
      lastSeenLabel: '5 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 28, 9, 45),
    ),
    DashboardDirectoryEntry(
      id: 'assistant-1',
      displayName: 'Ahmed Samir',
      email: 'ahmed.samir.ta@tolab.edu',
      role: DashboardDirectoryRole.assistant,
      departmentLabel: 'Information Systems',
      statusLabel: 'Awaiting upload review',
      lastSeenLabel: '8 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 28, 11, 20),
    ),
    DashboardDirectoryEntry(
      id: 'student-2',
      displayName: 'Nouran Emad',
      email: 'nouran.emad@tolab.edu',
      role: DashboardDirectoryRole.student,
      departmentLabel: 'Business',
      statusLabel: 'Documents pending',
      lastSeenLabel: '12 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 29, 14, 8),
    ),
    DashboardDirectoryEntry(
      id: 'doctor-2',
      displayName: 'Dr. Mostafa Nader',
      email: 'mostafa.nader@tolab.edu',
      role: DashboardDirectoryRole.doctor,
      departmentLabel: 'Information Systems',
      statusLabel: 'Course owner',
      lastSeenLabel: '18 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 27, 10, 0),
    ),
    DashboardDirectoryEntry(
      id: 'assistant-2',
      displayName: 'Farah Tarek',
      email: 'farah.tarek.ta@tolab.edu',
      role: DashboardDirectoryRole.assistant,
      departmentLabel: 'Computer Science',
      statusLabel: 'Lab assistant active',
      lastSeenLabel: '24 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 27, 15, 11),
    ),
    DashboardDirectoryEntry(
      id: 'student-3',
      displayName: 'Youssef Omar',
      email: 'youssef.omar@tolab.edu',
      role: DashboardDirectoryRole.student,
      departmentLabel: 'Engineering',
      statusLabel: 'Requires advisor review',
      lastSeenLabel: '31 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 29, 8, 40),
    ),
    DashboardDirectoryEntry(
      id: 'doctor-3',
      displayName: 'Dr. Reem Fawzy',
      email: 'reem.fawzy@tolab.edu',
      role: DashboardDirectoryRole.doctor,
      departmentLabel: 'Engineering',
      statusLabel: 'Midterm approval pending',
      lastSeenLabel: '42 min ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 26, 12, 35),
    ),
    DashboardDirectoryEntry(
      id: 'assistant-3',
      displayName: 'Salma Ibrahim',
      email: 'salma.ibrahim.ta@tolab.edu',
      role: DashboardDirectoryRole.assistant,
      departmentLabel: 'Design',
      statusLabel: 'Comment queue owner',
      lastSeenLabel: '1 h ago',
      isActive: true,
      createdAt: DateTime(2026, 3, 25, 16, 2),
    ),
  ];

  static final List<DashboardActivityRow> _activityRows = [
    DashboardActivityRow(
      id: 'activity-1',
      type: DashboardActivityType.registration,
      title: 'New student registration approved',
      subtitle: 'Mariam Adel was approved for Spring 2026 intake.',
      actor: 'Admissions desk',
      department: 'Computer Science',
      statusLabel: 'Approved',
      createdAt: DateTime(2026, 3, 30, 10, 18),
      tone: DashboardMetricTone.success,
    ),
    DashboardActivityRow(
      id: 'activity-2',
      type: DashboardActivityType.upload,
      title: 'Lecture pack uploaded',
      subtitle: 'AI Ethics week 06 slides and notebook published.',
      actor: 'Dr. Hadeer Salah',
      department: 'Artificial Intelligence',
      statusLabel: 'Ready to publish',
      createdAt: DateTime(2026, 3, 30, 9, 55),
      tone: DashboardMetricTone.info,
    ),
    DashboardActivityRow(
      id: 'activity-3',
      type: DashboardActivityType.review,
      title: 'Message thread escalated',
      subtitle: 'Three comments in Group 4 need moderator review.',
      actor: 'Moderation bot',
      department: 'General',
      statusLabel: 'Urgent',
      createdAt: DateTime(2026, 3, 30, 9, 42),
      tone: DashboardMetricTone.danger,
    ),
    DashboardActivityRow(
      id: 'activity-4',
      type: DashboardActivityType.registration,
      title: 'Student documents received',
      subtitle: 'Nouran Emad uploaded identity verification files.',
      actor: 'Registrar',
      department: 'Business',
      statusLabel: 'Awaiting approval',
      createdAt: DateTime(2026, 3, 30, 8, 50),
      tone: DashboardMetricTone.warning,
    ),
    DashboardActivityRow(
      id: 'activity-5',
      type: DashboardActivityType.upload,
      title: 'Lab recording synced',
      subtitle: 'Control Systems lab session exported to course storage.',
      actor: 'Ahmed Samir',
      department: 'Engineering',
      statusLabel: 'Quality check',
      createdAt: DateTime(2026, 3, 30, 8, 14),
      tone: DashboardMetricTone.primary,
    ),
    DashboardActivityRow(
      id: 'activity-6',
      type: DashboardActivityType.review,
      title: 'Comment flagged for policy breach',
      subtitle: 'Potential harassment in a design critique thread.',
      actor: 'Community filters',
      department: 'Design',
      statusLabel: 'Needs review',
      createdAt: DateTime(2026, 3, 29, 17, 38),
      tone: DashboardMetricTone.danger,
    ),
    DashboardActivityRow(
      id: 'activity-7',
      type: DashboardActivityType.registration,
      title: 'Transfer student mapped to section',
      subtitle: 'Youssef Omar assigned to ENG-3B cohort.',
      actor: 'Student affairs',
      department: 'Engineering',
      statusLabel: 'Assigned',
      createdAt: DateTime(2026, 3, 29, 15, 12),
      tone: DashboardMetricTone.success,
    ),
    DashboardActivityRow(
      id: 'activity-8',
      type: DashboardActivityType.upload,
      title: 'Case study bundle submitted',
      subtitle: 'Business Intelligence course assets uploaded in bulk.',
      actor: 'Farah Tarek',
      department: 'Information Systems',
      statusLabel: 'Pending validation',
      createdAt: DateTime(2026, 3, 29, 13, 29),
      tone: DashboardMetricTone.warning,
    ),
    DashboardActivityRow(
      id: 'activity-9',
      type: DashboardActivityType.review,
      title: 'Support message reopened',
      subtitle: 'Student requested a second review for enrollment block.',
      actor: 'Support inbox',
      department: 'Computer Science',
      statusLabel: 'Open',
      createdAt: DateTime(2026, 3, 29, 11, 3),
      tone: DashboardMetricTone.info,
    ),
  ];
}
