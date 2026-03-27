import 'package:collection/collection.dart';

import '../models/department_models.dart';

class DepartmentsSeedService {
  const DepartmentsSeedService();

  List<DepartmentRecord> build() {
    return [
      _computerScience(),
      _informationSystems(),
      _engineering(),
      _businessAnalytics(),
    ];
  }

  DepartmentRecord? match({
    required Iterable<DepartmentRecord> departments,
    String? id,
    String? code,
    String? name,
  }) {
    final normalizedCode = _normalize(code);
    final normalizedName = _normalize(name);
    final normalizedId = _normalize(id);
    return departments.firstWhereOrNull(
      (department) =>
          _normalize(department.id) == normalizedId ||
          _normalize(department.code) == normalizedCode ||
          _normalize(department.name) == normalizedName,
    );
  }

  DepartmentRecord createRecord({
    required String id,
    required DepartmentUpsertPayload payload,
    DepartmentRecord? template,
  }) {
    final seed = template ?? build().first;
    final now = DateTime.now();
    return seed.copyWith(
      id: id,
      name: payload.name,
      code: payload.code,
      description: payload.description,
      faculty: payload.faculty ?? template?.faculty ?? seed.faculty,
      headName: template?.headName ?? 'Department Leadership Team',
      coverImageUrl: template?.coverImageUrl ?? seed.coverImageUrl,
      isActive: payload.isActive,
      isArchived: false,
      studentsCount: template?.studentsCount ?? seed.studentsCount,
      staffCount: template?.staffCount ?? seed.staffCount,
      subjectsCount: template?.subjectsCount ?? seed.subjectsCount,
      sectionsCount: template?.sectionsCount ?? seed.sectionsCount,
      activeCoursesCount:
          template?.activeCoursesCount ?? seed.activeCoursesCount,
      successRate: template?.successRate ?? seed.successRate,
      createdAt: now,
      updatedAt: now,
      activityFeed: [
        DepartmentActivityItem(
          title: payload.name == template?.name
              ? 'Department configuration updated'
              : 'Department created',
          subtitle: payload.description,
          timestampLabel: 'Just now',
          tone: 'strong',
        ),
        ...(template?.activityFeed ?? seed.activityFeed).take(3),
      ],
      schedulePreview: template?.schedulePreview ?? seed.schedulePreview,
      studentDistribution:
          template?.studentDistribution ?? seed.studentDistribution,
      subjectLoad: template?.subjectLoad ?? seed.subjectLoad,
      staffUtilization: template?.staffUtilization ?? seed.staffUtilization,
      performanceMetrics:
          template?.performanceMetrics ?? seed.performanceMetrics,
      successTrend: template?.successTrend ?? seed.successTrend,
      years: template?.years ?? seed.years,
      students: template?.students ?? seed.students,
      staff: template?.staff ?? seed.staff,
      subjects: template?.subjects ?? seed.subjects,
      courseOfferings: template?.courseOfferings ?? seed.courseOfferings,
      permissions: template?.permissions ?? seed.permissions,
    );
  }

  String _normalize(String? value) =>
      value?.trim().toLowerCase().replaceAll(' ', '') ?? '';

  DepartmentRecord _computerScience() {
    final now = DateTime.now();
    return DepartmentRecord(
      id: 'DEP-CS',
      name: 'Computer Science',
      code: 'CS',
      description:
          'Delivers core software engineering, AI foundations, systems design, and research-oriented computing pathways for undergraduate cohorts.',
      faculty: 'Faculty of Computer Science & AI',
      headName: 'Prof. Eman Adel',
      coverImageUrl: 'https://picsum.photos/seed/tolab-cs/1280/720',
      isActive: true,
      isArchived: false,
      studentsCount: 2840,
      staffCount: 138,
      subjectsCount: 64,
      sectionsCount: 18,
      activeCoursesCount: 41,
      successRate: 92.4,
      createdAt: now.subtract(const Duration(days: 420)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      activityFeed: const [
        DepartmentActivityItem(
          title: 'Distributed Systems load rebalanced',
          subtitle: 'Two new section blocks were opened for Level 4 students.',
          timestampLabel: '18 min ago',
          tone: 'strong',
        ),
        DepartmentActivityItem(
          title: 'Doctor assignment approved',
          subtitle: 'Applied AI received one additional external faculty lead.',
          timestampLabel: '1 hour ago',
          tone: 'good',
        ),
        DepartmentActivityItem(
          title: 'Course seats released',
          subtitle: 'Registration office synced Spring 2026 elective capacity.',
          timestampLabel: 'Yesterday',
          tone: 'neutral',
        ),
        DepartmentActivityItem(
          title: 'Schedule review completed',
          subtitle: 'No timetable conflicts remained in Level 3 morning slots.',
          timestampLabel: '2 days ago',
          tone: 'good',
        ),
      ],
      schedulePreview: const [
        DepartmentScheduleItem(
          dayLabel: 'Mon',
          slotLabel: '09:00 - 11:00',
          title: 'Advanced Algorithms',
          location: 'Hall B12',
          type: 'Lecture',
          staffName: 'Dr. Hadeer Salah',
        ),
        DepartmentScheduleItem(
          dayLabel: 'Tue',
          slotLabel: '11:30 - 13:00',
          title: 'Compiler Design',
          location: 'Lab C4',
          type: 'Section',
          staffName: 'Eng. Menna Wael',
        ),
        DepartmentScheduleItem(
          dayLabel: 'Wed',
          slotLabel: '14:00 - 16:00',
          title: 'Applied AI',
          location: 'Hall A7',
          type: 'Lecture',
          staffName: 'Dr. Salma Adel',
        ),
      ],
      studentDistribution: const [
        DepartmentChartPoint(label: 'Year 1', value: 740),
        DepartmentChartPoint(label: 'Year 2', value: 710),
        DepartmentChartPoint(label: 'Year 3', value: 688),
        DepartmentChartPoint(label: 'Year 4', value: 702),
      ],
      subjectLoad: const [
        DepartmentChartPoint(label: 'Algorithms', value: 92),
        DepartmentChartPoint(label: 'Systems', value: 81),
        DepartmentChartPoint(label: 'AI', value: 88),
        DepartmentChartPoint(label: 'Theory', value: 67),
      ],
      staffUtilization: const [
        DepartmentChartPoint(label: 'Doctors', value: 84),
        DepartmentChartPoint(label: 'Assistants', value: 79),
        DepartmentChartPoint(label: 'Delegated', value: 72),
      ],
      performanceMetrics: const [
        DepartmentPerformanceMetric(
          label: 'Attendance stability',
          valueLabel: '94.1%',
          deltaLabel: '+1.4%',
          tone: 'good',
        ),
        DepartmentPerformanceMetric(
          label: 'Graduation readiness',
          valueLabel: '82%',
          deltaLabel: '+3.2%',
          tone: 'strong',
        ),
        DepartmentPerformanceMetric(
          label: 'Overloaded subjects',
          valueLabel: '6',
          deltaLabel: '-2',
          tone: 'attention',
        ),
        DepartmentPerformanceMetric(
          label: 'Schedule conflicts',
          valueLabel: '1',
          deltaLabel: '-4',
          tone: 'good',
        ),
      ],
      successTrend: const [
        DepartmentChartPoint(label: 'Jan', value: 89),
        DepartmentChartPoint(label: 'Feb', value: 90),
        DepartmentChartPoint(label: 'Mar', value: 91),
        DepartmentChartPoint(label: 'Apr', value: 92),
        DepartmentChartPoint(label: 'May', value: 92.4),
        DepartmentChartPoint(label: 'Jun', value: 93),
      ],
      years: [
        _year('Year 1', 4, 740, const [
          ('CS101', 'Programming Fundamentals', 3, false),
          ('CS103', 'Discrete Mathematics', 3, false),
          ('CS107', 'Computer Skills Lab', 2, false),
        ]),
        _year('Year 2', 5, 710, const [
          ('CS205', 'Object-Oriented Programming', 3, false),
          ('CS221', 'Computer Organization', 4, true),
          ('CS219', 'Discrete Structures', 3, false),
        ]),
        _year('Year 3', 4, 688, const [
          ('CS309', 'Mobile Development', 3, false),
          ('CS315', 'Compiler Design', 4, true),
          ('CS330', 'Operating Systems', 4, true),
        ]),
        _year('Year 4', 5, 702, const [
          ('CS401', 'Advanced Algorithms', 3, false),
          ('CS470', 'Applied AI', 4, true),
          ('CS475', 'Cloud Platforms', 3, false),
        ]),
      ],
      students: const [
        DepartmentStudentRecord(
          id: 'ST-2401',
          name: 'Omar Adel',
          yearLabel: 'Year 4',
          sectionLabel: 'CS-4A',
          status: 'Active',
          gpa: 3.82,
        ),
        DepartmentStudentRecord(
          id: 'ST-2420',
          name: 'Salma Nabil',
          yearLabel: 'Year 3',
          sectionLabel: 'CS-3C',
          status: 'Active',
          gpa: 3.48,
        ),
        DepartmentStudentRecord(
          id: 'ST-2429',
          name: 'Karim Essam',
          yearLabel: 'Year 2',
          sectionLabel: 'CS-2D',
          status: 'Probation',
          gpa: 2.27,
        ),
        DepartmentStudentRecord(
          id: 'ST-2441',
          name: 'Aya Khaled',
          yearLabel: 'Year 1',
          sectionLabel: 'CS-1B',
          status: 'Active',
          gpa: 3.61,
        ),
      ],
      staff: const [
        DepartmentStaffRecord(
          id: 'DOC-401',
          name: 'Dr. Hadeer Salah',
          role: 'Doctor',
          status: 'Active',
          utilization: 88,
          avatarUrl: 'https://i.pravatar.cc/160?img=32',
          activeSubjects: 3,
        ),
        DepartmentStaffRecord(
          id: 'DOC-437',
          name: 'Dr. Salma Adel',
          role: 'Doctor',
          status: 'Active',
          utilization: 76,
          avatarUrl: 'https://i.pravatar.cc/160?img=11',
          activeSubjects: 2,
        ),
        DepartmentStaffRecord(
          id: 'TA-512',
          name: 'Eng. Menna Wael',
          role: 'Assistant',
          status: 'Active',
          utilization: 83,
          avatarUrl: 'https://i.pravatar.cc/160?img=47',
          activeSubjects: 2,
        ),
      ],
      subjects: const [
        DepartmentSubjectRecord(
          id: 'SUB-CS401',
          code: 'CS401',
          name: 'Advanced Algorithms',
          yearLabel: 'Year 4',
          semesterLabel: 'Spring 2026',
          enrolledStudents: 168,
          weeklyHours: 3,
          status: 'Live',
        ),
        DepartmentSubjectRecord(
          id: 'SUB-CS315',
          code: 'CS315',
          name: 'Compiler Design',
          yearLabel: 'Year 3',
          semesterLabel: 'Spring 2026',
          enrolledStudents: 182,
          weeklyHours: 5,
          status: 'Overloaded',
        ),
        DepartmentSubjectRecord(
          id: 'SUB-CS470',
          code: 'CS470',
          name: 'Applied AI',
          yearLabel: 'Year 4',
          semesterLabel: 'Spring 2026',
          enrolledStudents: 194,
          weeklyHours: 4,
          status: 'High Demand',
        ),
      ],
      courseOfferings: const [
        DepartmentCourseOfferingRecord(
          id: 'OFF-CS-1',
          subjectCode: 'CS401',
          sectionLabel: 'CS-4A',
          instructor: 'Dr. Hadeer Salah',
          scheduleLabel: 'Mon / 09:00',
          enrolled: 88,
          capacity: 100,
          status: 'Active',
        ),
        DepartmentCourseOfferingRecord(
          id: 'OFF-CS-2',
          subjectCode: 'CS315',
          sectionLabel: 'CS-3C',
          instructor: 'Dr. Mona Hassan',
          scheduleLabel: 'Tue / 11:30',
          enrolled: 96,
          capacity: 100,
          status: 'Active',
        ),
        DepartmentCourseOfferingRecord(
          id: 'OFF-CS-3',
          subjectCode: 'CS470',
          sectionLabel: 'CS-4B',
          instructor: 'Dr. Salma Adel',
          scheduleLabel: 'Wed / 14:00',
          enrolled: 102,
          capacity: 104,
          status: 'Near capacity',
        ),
      ],
      permissions: _permissions(
        create: true,
        edit: true,
        delete: true,
        assignStaff: true,
        manageSchedule: true,
      ),
    );
  }

  DepartmentRecord _informationSystems() {
    final now = DateTime.now();
    return DepartmentRecord(
      id: 'DEP-IS',
      name: 'Information Systems',
      code: 'IS',
      description:
          'Combines enterprise systems, data platforms, and digital product operations with practical delivery for business-focused cohorts.',
      faculty: 'Faculty of Computer Science & AI',
      headName: 'Prof. Nader Mostafa',
      coverImageUrl: 'https://picsum.photos/seed/tolab-is/1280/720',
      isActive: true,
      isArchived: false,
      studentsCount: 1986,
      staffCount: 96,
      subjectsCount: 49,
      sectionsCount: 14,
      activeCoursesCount: 29,
      successRate: 90.8,
      createdAt: now.subtract(const Duration(days: 560)),
      updatedAt: now.subtract(const Duration(hours: 9)),
      activityFeed: const [
        DepartmentActivityItem(
          title: 'BI subject capacity raised',
          subtitle: 'Section B3 received 24 additional seats.',
          timestampLabel: '34 min ago',
          tone: 'good',
        ),
        DepartmentActivityItem(
          title: 'Lab rota updated',
          subtitle: 'Three assistant allocations were shifted for ERP labs.',
          timestampLabel: 'Today',
          tone: 'neutral',
        ),
        DepartmentActivityItem(
          title: 'Advising campaign launched',
          subtitle: 'Graduation audit reminders were sent to Year 4 students.',
          timestampLabel: 'Yesterday',
          tone: 'strong',
        ),
      ],
      schedulePreview: const [
        DepartmentScheduleItem(
          dayLabel: 'Sun',
          slotLabel: '10:00 - 12:00',
          title: 'Enterprise Systems',
          location: 'Hall D3',
          type: 'Lecture',
          staffName: 'Dr. Mostafa Nader',
        ),
        DepartmentScheduleItem(
          dayLabel: 'Tue',
          slotLabel: '12:00 - 13:30',
          title: 'Business Intelligence',
          location: 'Lab A5',
          type: 'Section',
          staffName: 'Eng. Ahmed Samir',
        ),
      ],
      studentDistribution: const [
        DepartmentChartPoint(label: 'Year 1', value: 480),
        DepartmentChartPoint(label: 'Year 2', value: 495),
        DepartmentChartPoint(label: 'Year 3', value: 510),
        DepartmentChartPoint(label: 'Year 4', value: 501),
      ],
      subjectLoad: const [
        DepartmentChartPoint(label: 'ERP', value: 78),
        DepartmentChartPoint(label: 'BI', value: 88),
        DepartmentChartPoint(label: 'Gov.', value: 63),
        DepartmentChartPoint(label: 'Ops', value: 70),
      ],
      staffUtilization: const [
        DepartmentChartPoint(label: 'Doctors', value: 79),
        DepartmentChartPoint(label: 'Assistants', value: 82),
        DepartmentChartPoint(label: 'Delegated', value: 68),
      ],
      performanceMetrics: const [
        DepartmentPerformanceMetric(
          label: 'Attendance stability',
          valueLabel: '91.4%',
          deltaLabel: '+0.9%',
          tone: 'good',
        ),
        DepartmentPerformanceMetric(
          label: 'Practical engagement',
          valueLabel: '87%',
          deltaLabel: '+4.1%',
          tone: 'strong',
        ),
        DepartmentPerformanceMetric(
          label: 'Overloaded subjects',
          valueLabel: '4',
          deltaLabel: '-1',
          tone: 'good',
        ),
      ],
      successTrend: const [
        DepartmentChartPoint(label: 'Jan', value: 87),
        DepartmentChartPoint(label: 'Feb', value: 88),
        DepartmentChartPoint(label: 'Mar', value: 89),
        DepartmentChartPoint(label: 'Apr', value: 89.6),
        DepartmentChartPoint(label: 'May', value: 90.1),
        DepartmentChartPoint(label: 'Jun', value: 90.8),
      ],
      years: [
        _year('Year 1', 3, 480, const [
          ('IS101', 'Business Computing', 3, false),
          ('IS103', 'Accounting Basics', 2, false),
          ('IS105', 'Spreadsheet Analytics', 2, false),
        ]),
        _year('Year 2', 4, 495, const [
          ('IS204', 'Database Systems', 3, false),
          ('IS210', 'Data Warehousing', 4, true),
          ('IS212', 'Networks for Business', 3, false),
        ]),
        _year('Year 3', 4, 510, const [
          ('IS305', 'Enterprise Systems', 3, false),
          ('IS307', 'Business Intelligence', 4, true),
          ('IS311', 'Systems Analysis', 3, false),
        ]),
        _year('Year 4', 3, 501, const [
          ('IS401', 'ERP Systems', 3, false),
          ('IS402', 'IT Governance', 3, false),
          ('IS430', 'Digital Transformation', 3, false),
        ]),
      ],
      students: const [
        DepartmentStudentRecord(
          id: 'ST-2408',
          name: 'Mariam Tarek',
          yearLabel: 'Year 3',
          sectionLabel: 'IS-3B',
          status: 'Active',
          gpa: 3.89,
        ),
        DepartmentStudentRecord(
          id: 'ST-2435',
          name: 'Farah Mohamed',
          yearLabel: 'Year 4',
          sectionLabel: 'IS-4A',
          status: 'Active',
          gpa: 3.36,
        ),
      ],
      staff: const [
        DepartmentStaffRecord(
          id: 'DOC-412',
          name: 'Dr. Mostafa Nader',
          role: 'Doctor',
          status: 'Active',
          utilization: 81,
          avatarUrl: 'https://i.pravatar.cc/160?img=22',
          activeSubjects: 2,
        ),
        DepartmentStaffRecord(
          id: 'TA-501',
          name: 'Eng. Ahmed Samir',
          role: 'Assistant',
          status: 'Active',
          utilization: 89,
          avatarUrl: 'https://i.pravatar.cc/160?img=15',
          activeSubjects: 2,
        ),
      ],
      subjects: const [
        DepartmentSubjectRecord(
          id: 'SUB-IS305',
          code: 'IS305',
          name: 'Enterprise Systems',
          yearLabel: 'Year 3',
          semesterLabel: 'Spring 2026',
          enrolledStudents: 146,
          weeklyHours: 3,
          status: 'Live',
        ),
        DepartmentSubjectRecord(
          id: 'SUB-IS307',
          code: 'IS307',
          name: 'Business Intelligence',
          yearLabel: 'Year 3',
          semesterLabel: 'Spring 2026',
          enrolledStudents: 173,
          weeklyHours: 5,
          status: 'Overloaded',
        ),
      ],
      courseOfferings: const [
        DepartmentCourseOfferingRecord(
          id: 'OFF-IS-1',
          subjectCode: 'IS305',
          sectionLabel: 'IS-3B',
          instructor: 'Dr. Mostafa Nader',
          scheduleLabel: 'Sun / 10:00',
          enrolled: 76,
          capacity: 80,
          status: 'Active',
        ),
        DepartmentCourseOfferingRecord(
          id: 'OFF-IS-2',
          subjectCode: 'IS307',
          sectionLabel: 'IS-3C',
          instructor: 'Dr. Rania Farid',
          scheduleLabel: 'Tue / 12:00',
          enrolled: 92,
          capacity: 95,
          status: 'Near capacity',
        ),
      ],
      permissions: _permissions(
        create: true,
        edit: true,
        delete: false,
        assignStaff: true,
        manageSchedule: true,
      ),
    );
  }

  DepartmentRecord _engineering() {
    final now = DateTime.now();
    return DepartmentRecord(
      id: 'DEP-ENG',
      name: 'Engineering Systems',
      code: 'ENG',
      description:
          'Coordinates engineering core delivery, lab-heavy schedules, and section planning across mechanical and industrial pathways.',
      faculty: 'Faculty of Engineering',
      headName: 'Prof. Reem Fawzy',
      coverImageUrl: 'https://picsum.photos/seed/tolab-eng/1280/720',
      isActive: false,
      isArchived: false,
      studentsCount: 1644,
      staffCount: 82,
      subjectsCount: 42,
      sectionsCount: 16,
      activeCoursesCount: 21,
      successRate: 84.6,
      createdAt: now.subtract(const Duration(days: 670)),
      updatedAt: now.subtract(const Duration(days: 1)),
      activityFeed: const [
        DepartmentActivityItem(
          title: 'Risk review escalated',
          subtitle: 'Two year-two sections remain below attendance target.',
          timestampLabel: 'Today',
          tone: 'critical',
        ),
        DepartmentActivityItem(
          title: 'Lab maintenance blackout',
          subtitle: 'Control Systems sessions were re-routed for 48 hours.',
          timestampLabel: 'Yesterday',
          tone: 'attention',
        ),
      ],
      schedulePreview: const [
        DepartmentScheduleItem(
          dayLabel: 'Mon',
          slotLabel: '08:00 - 10:00',
          title: 'Thermodynamics',
          location: 'Lab E2',
          type: 'Lecture',
          staffName: 'Dr. Reem Fawzy',
        ),
      ],
      studentDistribution: const [
        DepartmentChartPoint(label: 'Year 1', value: 408),
        DepartmentChartPoint(label: 'Year 2', value: 442),
        DepartmentChartPoint(label: 'Year 3', value: 401),
        DepartmentChartPoint(label: 'Year 4', value: 393),
      ],
      subjectLoad: const [
        DepartmentChartPoint(label: 'Thermo', value: 94),
        DepartmentChartPoint(label: 'Mechanics', value: 89),
        DepartmentChartPoint(label: 'Control', value: 83),
      ],
      staffUtilization: const [
        DepartmentChartPoint(label: 'Doctors', value: 72),
        DepartmentChartPoint(label: 'Assistants', value: 68),
      ],
      performanceMetrics: const [
        DepartmentPerformanceMetric(
          label: 'Attendance stability',
          valueLabel: '78.2%',
          deltaLabel: '-3.1%',
          tone: 'critical',
        ),
        DepartmentPerformanceMetric(
          label: 'Lab throughput',
          valueLabel: '64%',
          deltaLabel: '-5.4%',
          tone: 'attention',
        ),
      ],
      successTrend: const [
        DepartmentChartPoint(label: 'Jan', value: 87),
        DepartmentChartPoint(label: 'Feb', value: 86),
        DepartmentChartPoint(label: 'Mar', value: 85.4),
        DepartmentChartPoint(label: 'Apr', value: 85),
        DepartmentChartPoint(label: 'May', value: 84.8),
        DepartmentChartPoint(label: 'Jun', value: 84.6),
      ],
      years: [
        _year('Year 1', 4, 408, const [
          ('ENG101', 'Engineering Drawing', 2, false),
          ('ENG110', 'Applied Physics', 3, false),
          ('ENG120', 'Calculus for Engineers', 3, false),
        ]),
        _year('Year 2', 4, 442, const [
          ('ENG211', 'Thermodynamics', 4, true),
          ('ENG214', 'Mechanics II', 4, true),
          ('ENG220', 'Applied Mathematics', 3, false),
        ]),
      ],
      students: const [
        DepartmentStudentRecord(
          id: 'ST-2414',
          name: 'Youssef Ali',
          yearLabel: 'Year 2',
          sectionLabel: 'ENG-2A',
          status: 'Watchlist',
          gpa: 2.48,
        ),
      ],
      staff: const [
        DepartmentStaffRecord(
          id: 'DOC-425',
          name: 'Dr. Reem Fawzy',
          role: 'Doctor',
          status: 'Inactive',
          utilization: 58,
          avatarUrl: 'https://i.pravatar.cc/160?img=9',
          activeSubjects: 2,
        ),
      ],
      subjects: const [
        DepartmentSubjectRecord(
          id: 'SUB-ENG211',
          code: 'ENG211',
          name: 'Thermodynamics',
          yearLabel: 'Year 2',
          semesterLabel: 'Spring 2026',
          enrolledStudents: 186,
          weeklyHours: 5,
          status: 'Overloaded',
        ),
      ],
      courseOfferings: const [
        DepartmentCourseOfferingRecord(
          id: 'OFF-ENG-1',
          subjectCode: 'ENG211',
          sectionLabel: 'ENG-2A',
          instructor: 'Dr. Reem Fawzy',
          scheduleLabel: 'Mon / 08:00',
          enrolled: 54,
          capacity: 70,
          status: 'At risk',
        ),
      ],
      permissions: _permissions(
        create: false,
        edit: true,
        delete: false,
        assignStaff: true,
        manageSchedule: false,
      ),
    );
  }

  DepartmentRecord _businessAnalytics() {
    final now = DateTime.now();
    return DepartmentRecord(
      id: 'DEP-BA',
      name: 'Business Analytics',
      code: 'BA',
      description:
          'Supports data-driven business programs with compact analytics-focused sections, blended schedules, and strong employment readiness.',
      faculty: 'Faculty of Business',
      headName: 'Prof. Dina Magdy',
      coverImageUrl: 'https://picsum.photos/seed/tolab-ba/1280/720',
      isActive: true,
      isArchived: false,
      studentsCount: 932,
      staffCount: 44,
      subjectsCount: 28,
      sectionsCount: 8,
      activeCoursesCount: 17,
      successRate: 95.1,
      createdAt: now.subtract(const Duration(days: 300)),
      updatedAt: now.subtract(const Duration(hours: 14)),
      activityFeed: const [
        DepartmentActivityItem(
          title: 'Internship week opened',
          subtitle: 'Year 4 students received updated employer slots.',
          timestampLabel: '2 hours ago',
          tone: 'strong',
        ),
      ],
      schedulePreview: const [
        DepartmentScheduleItem(
          dayLabel: 'Thu',
          slotLabel: '13:00 - 15:00',
          title: 'Marketing Analytics',
          location: 'Hall M1',
          type: 'Lecture',
          staffName: 'Dr. Dina Magdy',
        ),
      ],
      studentDistribution: const [
        DepartmentChartPoint(label: 'Year 1', value: 220),
        DepartmentChartPoint(label: 'Year 2', value: 228),
        DepartmentChartPoint(label: 'Year 3', value: 240),
        DepartmentChartPoint(label: 'Year 4', value: 244),
      ],
      subjectLoad: const [
        DepartmentChartPoint(label: 'Marketing', value: 62),
        DepartmentChartPoint(label: 'Finance', value: 58),
        DepartmentChartPoint(label: 'Ops', value: 54),
      ],
      staffUtilization: const [
        DepartmentChartPoint(label: 'Doctors', value: 86),
        DepartmentChartPoint(label: 'Assistants', value: 78),
      ],
      performanceMetrics: const [
        DepartmentPerformanceMetric(
          label: 'Attendance stability',
          valueLabel: '96.2%',
          deltaLabel: '+1.2%',
          tone: 'strong',
        ),
        DepartmentPerformanceMetric(
          label: 'Placement readiness',
          valueLabel: '91%',
          deltaLabel: '+2.5%',
          tone: 'good',
        ),
      ],
      successTrend: const [
        DepartmentChartPoint(label: 'Jan', value: 92),
        DepartmentChartPoint(label: 'Feb', value: 93),
        DepartmentChartPoint(label: 'Mar', value: 94),
        DepartmentChartPoint(label: 'Apr', value: 94.2),
        DepartmentChartPoint(label: 'May', value: 94.7),
        DepartmentChartPoint(label: 'Jun', value: 95.1),
      ],
      years: [
        _year('Year 1', 2, 220, const [
          ('BA101', 'Intro to Analytics', 3, false),
          ('BA104', 'Business Statistics', 3, false),
        ]),
        _year('Year 4', 2, 244, const [
          ('BA402', 'Marketing Analytics', 3, false),
          ('BA430', 'Capstone Consulting', 3, false),
        ]),
      ],
      students: const [
        DepartmentStudentRecord(
          id: 'ST-BA-402',
          name: 'Nada Fares',
          yearLabel: 'Year 4',
          sectionLabel: 'BA-4A',
          status: 'Active',
          gpa: 3.91,
        ),
      ],
      staff: const [
        DepartmentStaffRecord(
          id: 'DOC-BA-11',
          name: 'Dr. Dina Magdy',
          role: 'Doctor',
          status: 'Active',
          utilization: 87,
          avatarUrl: 'https://i.pravatar.cc/160?img=40',
          activeSubjects: 2,
        ),
      ],
      subjects: const [
        DepartmentSubjectRecord(
          id: 'SUB-BA402',
          code: 'BA402',
          name: 'Marketing Analytics',
          yearLabel: 'Year 4',
          semesterLabel: 'Spring 2026',
          enrolledStudents: 88,
          weeklyHours: 3,
          status: 'Live',
        ),
      ],
      courseOfferings: const [
        DepartmentCourseOfferingRecord(
          id: 'OFF-BA-1',
          subjectCode: 'BA402',
          sectionLabel: 'BA-4A',
          instructor: 'Dr. Dina Magdy',
          scheduleLabel: 'Thu / 13:00',
          enrolled: 42,
          capacity: 48,
          status: 'Active',
        ),
      ],
      permissions: _permissions(
        create: true,
        edit: true,
        delete: true,
        assignStaff: true,
        manageSchedule: true,
      ),
    );
  }

  DepartmentYearPlan _year(
    String label,
    int sectionsCount,
    int studentsCount,
    List<(String, String, int, bool)> subjects,
  ) {
    return DepartmentYearPlan(
      yearLabel: label,
      sectionsCount: sectionsCount,
      studentsCount: studentsCount,
      subjects: subjects
          .map(
            (subject) => DepartmentYearSubject(
              code: subject.$1,
              name: subject.$2,
              creditHours: subject.$3,
              overloaded: subject.$4,
            ),
          )
          .toList(growable: false),
    );
  }

  static List<DepartmentPermissionRule> _permissions({
    required bool create,
    required bool edit,
    required bool delete,
    required bool assignStaff,
    required bool manageSchedule,
  }) {
    return [
      DepartmentPermissionRule(
        code: 'create_department',
        title: 'Create department',
        description: 'Open new administrative department entities.',
        granted: create,
      ),
      DepartmentPermissionRule(
        code: 'edit_department',
        title: 'Edit department',
        description:
            'Update department identity, metadata, and academic setup.',
        granted: edit,
      ),
      DepartmentPermissionRule(
        code: 'delete_department',
        title: 'Delete department',
        description: 'Archive or disable department records.',
        granted: delete,
      ),
      DepartmentPermissionRule(
        code: 'assign_staff',
        title: 'Assign staff',
        description: 'Link doctors and assistants to department operations.',
        granted: assignStaff,
      ),
      DepartmentPermissionRule(
        code: 'manage_schedule',
        title: 'Manage schedule',
        description: 'Adjust section and course schedule allocations.',
        granted: manageSchedule,
      ),
    ];
  }
}
