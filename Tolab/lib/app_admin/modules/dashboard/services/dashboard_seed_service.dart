import '../../../core/routing/route_paths.dart';
import '../models/dashboard_models.dart';

class DashboardSeedService {
  const DashboardSeedService();

  DashboardBundle buildBundle({required DashboardFilters filters}) {
    final records = _records
        .where((record) {
          final matchesSemester =
              filters.semesterId == null ||
              record.semesterId == filters.semesterId;
          final matchesDepartment =
              filters.departmentId == null ||
              record.departmentId == filters.departmentId;
          final matchesCourse =
              filters.courseId == null || record.courseId == filters.courseId;
          final matchesInstructor =
              filters.instructorId == null ||
              record.instructorId == filters.instructorId;
          return matchesSemester &&
              matchesDepartment &&
              matchesCourse &&
              matchesInstructor;
        })
        .toList(growable: false);

    final lookups = DashboardLookups(
      semesters: _semesters,
      departments: _departments,
      courses: _coursesFor(filters.departmentId),
      instructors: _instructorsFor(
        departmentId: filters.departmentId,
        courseId: filters.courseId,
      ),
    );

    if (records.isEmpty) {
      return DashboardBundle(
        filters: filters,
        lookups: lookups,
        kpis: const <DashboardKpiMetric>[],
        enrollmentTrend: const <DashboardLinePoint>[],
        studentDistribution: const <DashboardPieSlice>[],
        attendanceOverview: const <DashboardBarPoint>[],
        staffPerformance: const <DashboardBarPoint>[],
        recentActivity: const <DashboardActivityItem>[],
        moderationAlerts: const <DashboardModerationAlert>[],
        scheduleSummary: const <DashboardScheduleItem>[],
        quickActions: _quickActions,
        isFallback: true,
        sourceLabel: 'Local dashboard seed',
        refreshedAt: DateTime.now(),
      );
    }

    final students = records.fold<int>(0, (sum, item) => sum + item.students);
    final departmentsCount = records
        .map((item) => item.departmentId)
        .toSet()
        .length;
    final staffCount = records.map((item) => item.instructorId).toSet().length;
    final tasksCount = records.fold<int>(
      0,
      (sum, item) => sum + item.upcomingTasks,
    );
    final attendanceAverage =
        records.fold<double>(0, (sum, item) => sum + item.attendanceRate) /
        records.length;
    final staffAverage =
        records.fold<double>(0, (sum, item) => sum + item.staffPerformance) /
        records.length;

    return DashboardBundle(
      filters: filters,
      lookups: lookups,
      kpis: [
        DashboardKpiMetric(
          id: 'students',
          label: 'Students',
          value: students,
          deltaLabel: '+6.8% intake momentum',
          deltaValue: 6.8,
          progress: (students / 8000).clamp(0.18, 1),
          tone: DashboardMetricTone.primary,
          direction: DashboardTrendDirection.up,
          caption: 'Across the visible academic scope',
        ),
        DashboardKpiMetric(
          id: 'staff',
          label: 'Staff',
          value: staffCount,
          deltaLabel: '92.4% active roster',
          deltaValue: 2.4,
          progress: (staffCount / 40).clamp(0.18, 1),
          tone: DashboardMetricTone.secondary,
          direction: DashboardTrendDirection.up,
          caption: 'Doctors and assistants in the current filter',
        ),
        DashboardKpiMetric(
          id: 'departments',
          label: 'Departments',
          value: departmentsCount,
          deltaLabel: '${records.length} live course clusters',
          deltaValue: records.length.toDouble(),
          progress: (departmentsCount / _departments.length).clamp(0.18, 1),
          tone: DashboardMetricTone.info,
          direction: DashboardTrendDirection.neutral,
          caption: 'Departments represented in the visible workload',
        ),
        DashboardKpiMetric(
          id: 'tasks',
          label: 'Upcoming tasks',
          value: tasksCount,
          deltaLabel: '${attendanceAverage.toStringAsFixed(1)}% attendance',
          deltaValue: attendanceAverage,
          progress: (tasksCount / 50).clamp(0.18, 1),
          tone: DashboardMetricTone.warning,
          direction: DashboardTrendDirection.up,
          caption: '${staffAverage.toStringAsFixed(0)} average staff score',
        ),
      ],
      enrollmentTrend: _aggregateTrend(records),
      studentDistribution: _aggregateDistribution(records),
      attendanceOverview: _aggregateAttendance(records),
      staffPerformance: _aggregateStaffPerformance(records),
      recentActivity: _activityFor(records),
      moderationAlerts: _alertsFor(records),
      scheduleSummary: _scheduleFor(records),
      quickActions: _quickActions,
      isFallback: true,
      sourceLabel: 'Local dashboard seed',
      refreshedAt: DateTime.now(),
    );
  }

  List<DashboardLinePoint> _aggregateTrend(List<_DashboardRecord> records) {
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return List<DashboardLinePoint>.generate(labels.length, (index) {
      final total = records.fold<double>(
        0,
        (sum, item) => sum + item.enrollmentTrend[index],
      );
      return DashboardLinePoint(label: labels[index], value: total);
    }, growable: false);
  }

  List<DashboardPieSlice> _aggregateDistribution(
    List<_DashboardRecord> records,
  ) {
    final yearOne = records.fold<double>(
      0,
      (sum, item) => sum + item.studentDistribution[0],
    );
    final yearTwo = records.fold<double>(
      0,
      (sum, item) => sum + item.studentDistribution[1],
    );
    final yearThree = records.fold<double>(
      0,
      (sum, item) => sum + item.studentDistribution[2],
    );
    final yearFour = records.fold<double>(
      0,
      (sum, item) => sum + item.studentDistribution[3],
    );

    return [
      DashboardPieSlice(
        label: 'Year 1',
        value: yearOne,
        tone: DashboardMetricTone.primary,
      ),
      DashboardPieSlice(
        label: 'Year 2',
        value: yearTwo,
        tone: DashboardMetricTone.info,
      ),
      DashboardPieSlice(
        label: 'Year 3',
        value: yearThree,
        tone: DashboardMetricTone.secondary,
      ),
      DashboardPieSlice(
        label: 'Year 4',
        value: yearFour,
        tone: DashboardMetricTone.warning,
      ),
    ];
  }

  List<DashboardBarPoint> _aggregateAttendance(List<_DashboardRecord> records) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return List<DashboardBarPoint>.generate(labels.length, (index) {
      final total = records.fold<double>(
        0,
        (sum, item) => sum + item.attendanceSeries[index],
      );
      return DashboardBarPoint(
        label: labels[index],
        value: total / records.length,
        target: 90,
      );
    }, growable: false);
  }

  List<DashboardBarPoint> _aggregateStaffPerformance(
    List<_DashboardRecord> records,
  ) {
    return records
        .map(
          (record) => DashboardBarPoint(
            label: record.instructorShortLabel,
            value: record.staffPerformance,
            target: 92,
          ),
        )
        .toList(growable: false);
  }

  List<DashboardActivityItem> _activityFor(List<_DashboardRecord> records) {
    final items = records.expand((record) => record.activities).toList();
    items.sort((a, b) => a.order.compareTo(b.order));
    return items
        .take(6)
        .map(
          (item) => DashboardActivityItem(
            id: item.id,
            title: item.title,
            subtitle: item.subtitle,
            actorName: item.actorName,
            timeLabel: item.timeLabel,
            type: item.type,
            highlighted: item.highlighted,
          ),
        )
        .toList(growable: false);
  }

  List<DashboardModerationAlert> _alertsFor(List<_DashboardRecord> records) {
    final items = records.expand((record) => record.alerts).toList();
    items.sort((a, b) => b.flaggedCount.compareTo(a.flaggedCount));
    return items.take(4).toList(growable: false);
  }

  List<DashboardScheduleItem> _scheduleFor(List<_DashboardRecord> records) {
    final items = records.expand((record) => record.schedule).toList();
    items.sort((a, b) => a.dayLabel.compareTo(b.dayLabel));
    return items.take(5).toList(growable: false);
  }

  List<DashboardLookupOption> _coursesFor(String? departmentId) {
    final filtered = departmentId == null
        ? _courseOptions
        : _courseOptions
              .where((option) => option.subtitle?.toLowerCase() == departmentId)
              .toList(growable: false);
    return filtered
        .map(
          (option) => DashboardLookupOption(
            id: option.id,
            label: option.label,
            subtitle: option.subtitle == null
                ? null
                : _departmentLabel(option.subtitle!),
          ),
        )
        .toList(growable: false);
  }

  List<DashboardLookupOption> _instructorsFor({
    String? departmentId,
    String? courseId,
  }) {
    return _instructorOptions
        .where((option) {
          final matchesDepartment =
              departmentId == null || option.departmentId == departmentId;
          final matchesCourse =
              courseId == null || option.courseIds.contains(courseId);
          return matchesDepartment && matchesCourse;
        })
        .map(
          (option) => DashboardLookupOption(
            id: option.id,
            label: option.label,
            subtitle: option.subtitle,
          ),
        )
        .toList(growable: false);
  }

  String _departmentLabel(String departmentId) {
    return _departments
        .firstWhere(
          (option) => option.id == departmentId,
          orElse: () =>
              DashboardLookupOption(id: departmentId, label: departmentId),
        )
        .label;
  }

  static const List<DashboardLookupOption> _semesters = [
    DashboardLookupOption(id: 'spring_2026', label: 'Spring 2026'),
    DashboardLookupOption(id: 'fall_2025', label: 'Fall 2025'),
    DashboardLookupOption(id: 'summer_2025', label: 'Summer 2025'),
  ];

  static const List<DashboardLookupOption> _departments = [
    DashboardLookupOption(id: 'computer_science', label: 'Computer Science'),
    DashboardLookupOption(
      id: 'information_systems',
      label: 'Information Systems',
    ),
    DashboardLookupOption(id: 'engineering', label: 'Engineering'),
  ];

  static const List<DashboardLookupOption> _courseOptions = [
    DashboardLookupOption(
      id: 'advanced_algorithms',
      label: 'Advanced Algorithms',
      subtitle: 'computer_science',
    ),
    DashboardLookupOption(
      id: 'applied_ai',
      label: 'Applied AI',
      subtitle: 'computer_science',
    ),
    DashboardLookupOption(
      id: 'enterprise_systems',
      label: 'Enterprise Systems',
      subtitle: 'information_systems',
    ),
    DashboardLookupOption(
      id: 'business_intelligence',
      label: 'Business Intelligence',
      subtitle: 'information_systems',
    ),
    DashboardLookupOption(
      id: 'control_systems',
      label: 'Control Systems',
      subtitle: 'engineering',
    ),
  ];

  static const List<_InstructorOption> _instructorOptions = [
    _InstructorOption(
      id: 'dr_hadeer_salah',
      label: 'Dr. Hadeer Salah',
      subtitle: 'Computer Science',
      departmentId: 'computer_science',
      courseIds: ['advanced_algorithms'],
    ),
    _InstructorOption(
      id: 'dr_salma_adel',
      label: 'Dr. Salma Adel',
      subtitle: 'Computer Science',
      departmentId: 'computer_science',
      courseIds: ['applied_ai'],
    ),
    _InstructorOption(
      id: 'dr_mostafa_nader',
      label: 'Dr. Mostafa Nader',
      subtitle: 'Information Systems',
      departmentId: 'information_systems',
      courseIds: ['enterprise_systems'],
    ),
    _InstructorOption(
      id: 'eng_ahmed_samir',
      label: 'Eng. Ahmed Samir',
      subtitle: 'Information Systems',
      departmentId: 'information_systems',
      courseIds: ['business_intelligence', 'enterprise_systems'],
    ),
    _InstructorOption(
      id: 'dr_reem_fawzy',
      label: 'Dr. Reem Fawzy',
      subtitle: 'Engineering',
      departmentId: 'engineering',
      courseIds: ['control_systems'],
    ),
  ];

  static const List<DashboardQuickAction> _quickActions = [
    DashboardQuickAction(
      id: 'add_student',
      label: 'Add student',
      subtitle: 'Jump to the student workspace and create a new profile.',
      route: RoutePaths.students,
    ),
    DashboardQuickAction(
      id: 'add_staff',
      label: 'Add staff',
      subtitle: 'Open staff management for a new doctor or assistant.',
      route: RoutePaths.staff,
    ),
    DashboardQuickAction(
      id: 'add_course',
      label: 'Add course',
      subtitle: 'Go to course offerings and configure a fresh class.',
      route: RoutePaths.courseOfferings,
    ),
    DashboardQuickAction(
      id: 'send_notification',
      label: 'Send notification',
      subtitle: 'Navigate to notifications and launch a new campaign.',
      route: RoutePaths.notifications,
    ),
  ];

  static final List<_DashboardRecord> _records = [
    _DashboardRecord(
      semesterId: 'spring_2026',
      departmentId: 'computer_science',
      courseId: 'advanced_algorithms',
      instructorId: 'dr_hadeer_salah',
      instructorShortLabel: 'Hadeer',
      students: 1380,
      attendanceRate: 93,
      upcomingTasks: 14,
      staffPerformance: 96,
      enrollmentTrend: [180, 205, 230, 255, 268, 290],
      studentDistribution: [24, 31, 29, 16],
      attendanceSeries: [92, 94, 95, 93, 91],
      activities: [
        _ActivitySeed(
          id: 'act_algorithms_1',
          title: 'Bulk registration batch approved',
          subtitle: 'Advanced Algorithms added 126 students after review.',
          actorName: 'Admissions desk',
          timeLabel: '12 min ago',
          type: DashboardActivityType.enrollment,
          order: 1,
          highlighted: true,
        ),
        _ActivitySeed(
          id: 'act_algorithms_2',
          title: 'Lecture pack refreshed',
          subtitle: 'Week 7 materials published with lab guidance.',
          actorName: 'Dr. Hadeer Salah',
          timeLabel: '38 min ago',
          type: DashboardActivityType.subject,
          order: 4,
          highlighted: false,
        ),
      ],
      alerts: [
        DashboardModerationAlert(
          id: 'alert_algorithms_1',
          title: 'Flagged discussion replies',
          subtitle: 'Three student replies need moderator validation.',
          scopeLabel: 'Advanced Algorithms',
          flaggedCount: 3,
          severity: DashboardAlertSeverity.medium,
        ),
      ],
      schedule: [
        DashboardScheduleItem(
          id: 'sched_algorithms_1',
          title: 'Lecture 08',
          dayLabel: 'Mon',
          timeLabel: '09:00 - 11:00',
          location: 'Hall B12',
          owner: 'Dr. Hadeer Salah',
          type: DashboardScheduleType.lecture,
          statusLabel: 'Starts soon',
        ),
      ],
    ),
    _DashboardRecord(
      semesterId: 'spring_2026',
      departmentId: 'computer_science',
      courseId: 'applied_ai',
      instructorId: 'dr_salma_adel',
      instructorShortLabel: 'Salma',
      students: 1120,
      attendanceRate: 88,
      upcomingTasks: 11,
      staffPerformance: 90,
      enrollmentTrend: [144, 160, 184, 196, 224, 240],
      studentDistribution: [20, 26, 34, 20],
      attendanceSeries: [86, 88, 89, 90, 87],
      activities: [
        _ActivitySeed(
          id: 'act_ai_1',
          title: 'AI lab roster synced',
          subtitle: 'Assistant assignments finished for blended sessions.',
          actorName: 'Scheduling office',
          timeLabel: '22 min ago',
          type: DashboardActivityType.staff,
          order: 2,
          highlighted: true,
        ),
        _ActivitySeed(
          id: 'act_ai_2',
          title: 'Student advisory sent',
          subtitle:
              'Attendance watchlist notices were delivered to 42 students.',
          actorName: 'Student affairs',
          timeLabel: '1 h ago',
          type: DashboardActivityType.student,
          order: 5,
          highlighted: false,
        ),
      ],
      alerts: [
        DashboardModerationAlert(
          id: 'alert_ai_1',
          title: 'Unreviewed file attachment',
          subtitle: 'One large media upload is waiting for manual clearance.',
          scopeLabel: 'Applied AI',
          flaggedCount: 1,
          severity: DashboardAlertSeverity.low,
        ),
      ],
      schedule: [
        DashboardScheduleItem(
          id: 'sched_ai_1',
          title: 'Project milestone review',
          dayLabel: 'Tue',
          timeLabel: '12:30 - 13:30',
          location: 'Studio C4',
          owner: 'Dr. Salma Adel',
          type: DashboardScheduleType.review,
          statusLabel: 'Pending confirmations',
        ),
      ],
    ),
    _DashboardRecord(
      semesterId: 'spring_2026',
      departmentId: 'information_systems',
      courseId: 'enterprise_systems',
      instructorId: 'dr_mostafa_nader',
      instructorShortLabel: 'Mostafa',
      students: 980,
      attendanceRate: 91,
      upcomingTasks: 9,
      staffPerformance: 87,
      enrollmentTrend: [118, 140, 155, 176, 192, 205],
      studentDistribution: [18, 34, 28, 20],
      attendanceSeries: [90, 92, 91, 90, 89],
      activities: [
        _ActivitySeed(
          id: 'act_enterprise_1',
          title: 'Staff availability updated',
          subtitle: 'Office hours moved after timetable optimization.',
          actorName: 'Dr. Mostafa Nader',
          timeLabel: '18 min ago',
          type: DashboardActivityType.schedule,
          order: 3,
          highlighted: false,
        ),
      ],
      alerts: [
        DashboardModerationAlert(
          id: 'alert_enterprise_1',
          title: 'Flagged peer feedback',
          subtitle: 'Potentially abusive wording detected in one thread.',
          scopeLabel: 'Enterprise Systems',
          flaggedCount: 5,
          severity: DashboardAlertSeverity.high,
        ),
      ],
      schedule: [
        DashboardScheduleItem(
          id: 'sched_enterprise_1',
          title: 'Systems architecture lecture',
          dayLabel: 'Wed',
          timeLabel: '10:00 - 12:00',
          location: 'Lab A3',
          owner: 'Dr. Mostafa Nader',
          type: DashboardScheduleType.lecture,
          statusLabel: 'On track',
        ),
      ],
    ),
    _DashboardRecord(
      semesterId: 'spring_2026',
      departmentId: 'information_systems',
      courseId: 'business_intelligence',
      instructorId: 'eng_ahmed_samir',
      instructorShortLabel: 'Ahmed',
      students: 760,
      attendanceRate: 86,
      upcomingTasks: 7,
      staffPerformance: 84,
      enrollmentTrend: [102, 116, 122, 135, 148, 162],
      studentDistribution: [28, 30, 24, 18],
      attendanceSeries: [84, 85, 87, 88, 86],
      activities: [
        _ActivitySeed(
          id: 'act_bi_1',
          title: 'Attendance follow-up triggered',
          subtitle: 'Late students moved into the recovery workflow.',
          actorName: 'Eng. Ahmed Samir',
          timeLabel: '1 h ago',
          type: DashboardActivityType.student,
          order: 6,
          highlighted: false,
        ),
      ],
      alerts: [
        DashboardModerationAlert(
          id: 'alert_bi_1',
          title: 'Escalated plagiarism review',
          subtitle: 'Two reports need academic moderation approval.',
          scopeLabel: 'Business Intelligence',
          flaggedCount: 2,
          severity: DashboardAlertSeverity.medium,
        ),
      ],
      schedule: [
        DashboardScheduleItem(
          id: 'sched_bi_1',
          title: 'Dashboard lab',
          dayLabel: 'Thu',
          timeLabel: '11:00 - 13:00',
          location: 'Innovation Lab',
          owner: 'Eng. Ahmed Samir',
          type: DashboardScheduleType.task,
          statusLabel: 'Room confirmed',
        ),
      ],
    ),
    _DashboardRecord(
      semesterId: 'spring_2026',
      departmentId: 'engineering',
      courseId: 'control_systems',
      instructorId: 'dr_reem_fawzy',
      instructorShortLabel: 'Reem',
      students: 840,
      attendanceRate: 82,
      upcomingTasks: 6,
      staffPerformance: 78,
      enrollmentTrend: [90, 104, 112, 126, 134, 150],
      studentDistribution: [14, 26, 32, 28],
      attendanceSeries: [80, 82, 83, 84, 81],
      activities: [
        _ActivitySeed(
          id: 'act_control_1',
          title: 'Exam venue revised',
          subtitle: 'Midterm moved after hall conflict resolution.',
          actorName: 'Engineering operations',
          timeLabel: '2 h ago',
          type: DashboardActivityType.schedule,
          order: 7,
          highlighted: false,
        ),
      ],
      alerts: [
        DashboardModerationAlert(
          id: 'alert_control_1',
          title: 'Critical review queue',
          subtitle: 'Six reports are blocked awaiting senior approval.',
          scopeLabel: 'Control Systems',
          flaggedCount: 6,
          severity: DashboardAlertSeverity.critical,
        ),
      ],
      schedule: [
        DashboardScheduleItem(
          id: 'sched_control_1',
          title: 'Midterm exam',
          dayLabel: 'Fri',
          timeLabel: '14:00 - 16:00',
          location: 'Main Auditorium',
          owner: 'Dr. Reem Fawzy',
          type: DashboardScheduleType.exam,
          statusLabel: 'Needs invigilator',
        ),
      ],
    ),
  ];
}

class _InstructorOption {
  const _InstructorOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.departmentId,
    required this.courseIds,
  });

  final String id;
  final String label;
  final String subtitle;
  final String departmentId;
  final List<String> courseIds;
}

class _DashboardRecord {
  const _DashboardRecord({
    required this.semesterId,
    required this.departmentId,
    required this.courseId,
    required this.instructorId,
    required this.instructorShortLabel,
    required this.students,
    required this.attendanceRate,
    required this.upcomingTasks,
    required this.staffPerformance,
    required this.enrollmentTrend,
    required this.studentDistribution,
    required this.attendanceSeries,
    required this.activities,
    required this.alerts,
    required this.schedule,
  });

  final String semesterId;
  final String departmentId;
  final String courseId;
  final String instructorId;
  final String instructorShortLabel;
  final int students;
  final double attendanceRate;
  final int upcomingTasks;
  final double staffPerformance;
  final List<double> enrollmentTrend;
  final List<double> studentDistribution;
  final List<double> attendanceSeries;
  final List<_ActivitySeed> activities;
  final List<DashboardModerationAlert> alerts;
  final List<DashboardScheduleItem> schedule;
}

class _ActivitySeed {
  const _ActivitySeed({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actorName,
    required this.timeLabel,
    required this.type,
    required this.order,
    required this.highlighted,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actorName;
  final String timeLabel;
  final DashboardActivityType type;
  final int order;
  final bool highlighted;
}
