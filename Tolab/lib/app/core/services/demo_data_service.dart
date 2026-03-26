import 'package:flutter/material.dart';

import '../../shared/models/academic_models.dart';
import '../../shared/models/auth_models.dart';
import '../../shared/models/content_models.dart';
import '../../shared/models/dashboard_models.dart';
import '../../shared/models/moderation_models.dart';
import '../../shared/models/notification_models.dart';
import '../../shared/models/schedule_models.dart';
import '../../shared/models/settings_models.dart';
import '../../shared/models/staff_member.dart';
import '../../shared/models/student.dart';
import '../colors/app_colors.dart';

class DemoDataService {
  const DemoDataService();

  UserProfile adminProfile() => const UserProfile(
    id: '1',
    name: 'Dr. Laila Hassan',
    email: 'admin@tolab.edu',
    role: 'super_admin',
    status: 'active',
    department: 'Engineering',
  );

  DashboardBundle dashboardBundle() => DashboardBundle(
    metrics: const [
      KpiMetric(
        label: 'Active students',
        value: '12,480',
        delta: '+8.4% vs last month',
        color: AppColors.primary,
        icon: Icons.school_rounded,
      ),
      KpiMetric(
        label: 'Academic staff',
        value: '684',
        delta: '+21 new assignments',
        color: AppColors.secondary,
        icon: Icons.groups_rounded,
      ),
      KpiMetric(
        label: 'Schedule events',
        value: '1,246',
        delta: '92 awaiting review',
        color: AppColors.purple,
        icon: Icons.calendar_month_rounded,
      ),
      KpiMetric(
        label: 'Moderation alerts',
        value: '18',
        delta: '-11 resolved today',
        color: AppColors.warning,
        icon: Icons.shield_moon_rounded,
      ),
    ],
    trends: const [
      TrendPoint('Jan', 420),
      TrendPoint('Feb', 510),
      TrendPoint('Mar', 560),
      TrendPoint('Apr', 610),
      TrendPoint('May', 700),
      TrendPoint('Jun', 820),
    ],
    distribution: const [
      DistributionSlice(label: 'Lectures', value: 42, color: AppColors.primary),
      DistributionSlice(
        label: 'Sections',
        value: 28,
        color: AppColors.secondary,
      ),
      DistributionSlice(label: 'Exams', value: 18, color: AppColors.warning),
      DistributionSlice(label: 'Tasks', value: 12, color: AppColors.purple),
    ],
    activities: const [
      ActivityItem(
        title: 'New staff assignment approved',
        subtitle: 'Computer Science / Data Structures',
        timestamp: '12 min ago',
        type: 'staff',
      ),
      ActivityItem(
        title: 'Bulk enrollment imported',
        subtitle: '312 students added to Spring 2026 offerings',
        timestamp: '48 min ago',
        type: 'enrollment',
      ),
      ActivityItem(
        title: 'Reported message removed',
        subtitle: 'Group: CS-4B collaborative channel',
        timestamp: '1h ago',
        type: 'moderation',
      ),
    ],
    alerts: const [
      '2 course offerings exceeded room capacity',
      '6 notification campaigns are queued for the evening',
      '4 uploaded files need manual virus review',
    ],
  );

  List<Student> students() => const [
    Student(
      id: 'ST-1001',
      name: 'Omar Adel',
      email: 'omar.adel@tolab.edu',
      department: 'Computer Science',
      level: 'Level 4',
      section: 'CS-4A',
      status: 'active',
      gpa: 3.72,
      enrolledSubjects: 6,
    ),
    Student(
      id: 'ST-1002',
      name: 'Mariam Tarek',
      email: 'mariam.tarek@tolab.edu',
      department: 'Information Systems',
      level: 'Level 3',
      section: 'IS-3B',
      status: 'active',
      gpa: 3.88,
      enrolledSubjects: 5,
    ),
    Student(
      id: 'ST-1003',
      name: 'Youssef Ali',
      email: 'youssef.ali@tolab.edu',
      department: 'Engineering',
      level: 'Level 2',
      section: 'ENG-2A',
      status: 'inactive',
      gpa: 2.94,
      enrolledSubjects: 4,
    ),
  ];

  List<StaffMember> staff() => const [
    StaffMember(
      id: 'SF-201',
      name: 'Dr. Hadeer Salah',
      email: 'hadeer.salah@tolab.edu',
      title: 'Doctor',
      department: 'Computer Science',
      subjects: 3,
      status: 'active',
    ),
    StaffMember(
      id: 'SF-202',
      name: 'Eng. Ahmed Samir',
      email: 'ahmed.samir@tolab.edu',
      title: 'Assistant',
      department: 'Information Systems',
      subjects: 4,
      status: 'active',
    ),
    StaffMember(
      id: 'SF-203',
      name: 'Dr. Reem Fawzy',
      email: 'reem.fawzy@tolab.edu',
      title: 'Doctor',
      department: 'Engineering',
      subjects: 2,
      status: 'blocked',
    ),
  ];

  List<DepartmentModel> departments() => const [
    DepartmentModel(
      id: 'DEP-1',
      name: 'Computer Science',
      code: 'CS',
      head: 'Dr. Eman Adel',
      status: 'active',
      studentsCount: 3120,
    ),
    DepartmentModel(
      id: 'DEP-2',
      name: 'Information Systems',
      code: 'IS',
      head: 'Dr. Nader Mostafa',
      status: 'active',
      studentsCount: 2540,
    ),
  ];

  List<SectionModel> sections() => const [
    SectionModel(
      id: 'SEC-1',
      name: 'CS-4A',
      department: 'Computer Science',
      year: '2025/2026',
      semester: 'Spring',
      status: 'active',
    ),
    SectionModel(
      id: 'SEC-2',
      name: 'IS-3B',
      department: 'Information Systems',
      year: '2025/2026',
      semester: 'Spring',
      status: 'active',
    ),
  ];

  List<SubjectModel> subjects() => const [
    SubjectModel(
      id: 'SUB-1',
      code: 'CS401',
      name: 'Advanced Algorithms',
      department: 'Computer Science',
      credits: 3,
      status: 'active',
    ),
    SubjectModel(
      id: 'SUB-2',
      code: 'IS305',
      name: 'Enterprise Systems',
      department: 'Information Systems',
      credits: 2,
      status: 'active',
    ),
  ];

  List<CourseOfferingModel> courseOfferings() => const [
    CourseOfferingModel(
      id: 'OFF-1',
      subjectCode: 'CS401',
      subjectName: 'Advanced Algorithms',
      sectionName: 'CS-4A',
      doctorName: 'Dr. Hadeer Salah',
      assistantName: 'Eng. Ahmed Samir',
      semester: 'Spring 2026',
      enrolled: 88,
      capacity: 100,
      status: 'active',
    ),
    CourseOfferingModel(
      id: 'OFF-2',
      subjectCode: 'IS305',
      subjectName: 'Enterprise Systems',
      sectionName: 'IS-3B',
      doctorName: 'Dr. Reem Fawzy',
      assistantName: 'Eng. Ahmed Samir',
      semester: 'Spring 2026',
      enrolled: 76,
      capacity: 80,
      status: 'pending',
    ),
  ];

  List<EnrollmentRecord> enrollments() => const [
    EnrollmentRecord(
      id: 'ENR-1',
      studentName: 'Omar Adel',
      subjectName: 'Advanced Algorithms',
      department: 'Computer Science',
      level: 'Level 4',
      status: 'active',
    ),
    EnrollmentRecord(
      id: 'ENR-2',
      studentName: 'Mariam Tarek',
      subjectName: 'Enterprise Systems',
      department: 'Information Systems',
      level: 'Level 3',
      status: 'active',
    ),
  ];

  List<ContentItem> contentItems() => const [
    ContentItem(
      id: 'CNT-1',
      courseTitle: 'Advanced Algorithms',
      type: 'Lecture',
      title: 'Greedy Optimization Patterns',
      status: 'published',
      attachments: 3,
      dueDateLabel: 'Apr 14, 2026',
    ),
    ContentItem(
      id: 'CNT-2',
      courseTitle: 'Enterprise Systems',
      type: 'Quiz',
      title: 'Week 5 Assessment',
      status: 'scheduled',
      attachments: 1,
      dueDateLabel: 'Apr 20, 2026',
    ),
  ];

  List<UploadItem> uploads() => const [
    UploadItem(
      id: 'UP-1',
      name: 'semester-schedule.xlsx',
      sizeLabel: '2.8 MB',
      progress: 1,
      status: 'completed',
      mimeType: 'application/vnd.ms-excel',
    ),
    UploadItem(
      id: 'UP-2',
      name: 'lecture-assets.zip',
      sizeLabel: '84 MB',
      progress: .54,
      status: 'uploading',
      mimeType: 'application/zip',
    ),
  ];

  List<ScheduleEventModel> scheduleEvents() {
    final now = DateTime.now();
    return [
      ScheduleEventModel(
        id: 'EV-1',
        title: 'Lecture 08',
        course: 'Advanced Algorithms',
        instructor: 'Dr. Hadeer Salah',
        location: 'Hall B12',
        type: 'lecture',
        status: 'planned',
        start: DateTime(now.year, now.month, now.day, 9),
        end: DateTime(now.year, now.month, now.day, 11),
        color: AppColors.primary,
      ),
      ScheduleEventModel(
        id: 'EV-2',
        title: 'Section Review',
        course: 'Enterprise Systems',
        instructor: 'Eng. Ahmed Samir',
        location: 'Lab C3',
        type: 'section',
        status: 'completed',
        start: DateTime(now.year, now.month, now.day + 1, 12),
        end: DateTime(now.year, now.month, now.day + 1, 14),
        color: AppColors.secondary,
      ),
      ScheduleEventModel(
        id: 'EV-3',
        title: 'Midterm Exam',
        course: 'Operating Systems',
        instructor: 'Dr. Reem Fawzy',
        location: 'Main Auditorium',
        type: 'exam',
        status: 'planned',
        start: DateTime(now.year, now.month, now.day + 3, 10),
        end: DateTime(now.year, now.month, now.day + 3, 12),
        color: AppColors.warning,
      ),
    ];
  }

  List<AdminNotification> notifications() => const [
    AdminNotification(
      id: 'NT-1',
      title: 'Semester registration deadline',
      body: 'Broadcast scheduled for all level 3 students.',
      category: 'broadcast',
      createdAtLabel: 'Today, 09:20',
      isRead: false,
    ),
    AdminNotification(
      id: 'NT-2',
      title: 'Upload policy updated',
      body: 'Maximum file size raised to 250 MB for administrators.',
      category: 'system',
      createdAtLabel: 'Yesterday',
      isRead: true,
    ),
  ];

  List<ModerationItem> moderationItems() => const [
    ModerationItem(
      id: 'MOD-1',
      type: 'Post',
      author: 'Mahmoud Ashraf',
      groupName: 'CS-4A',
      preview: 'Thread contains duplicated external links.',
      reportsCount: 4,
      status: 'flagged',
      createdAtLabel: '18 min ago',
    ),
    ModerationItem(
      id: 'MOD-2',
      type: 'Message',
      author: 'Sara Emad',
      groupName: 'IS-3B',
      preview: 'Potential harassment phrase detected by policy filter.',
      reportsCount: 2,
      status: 'pending',
      createdAtLabel: '1h ago',
    ),
  ];

  List<RolePermission> roles() => const [
    RolePermission(
      id: 'ROLE-1',
      role: 'Super Admin',
      members: 3,
      permissions: {
        'manage_users': true,
        'manage_schedule': true,
        'moderate_groups': true,
        'broadcast_notifications': true,
      },
    ),
    RolePermission(
      id: 'ROLE-2',
      role: 'Moderator',
      members: 8,
      permissions: {
        'manage_users': false,
        'manage_schedule': false,
        'moderate_groups': true,
        'broadcast_notifications': false,
      },
    ),
  ];

  SettingsBundle settings() => const SettingsBundle(
    themeMode: ThemeMode.light,
    localeCode: 'en',
    pushEnabled: true,
    desktopAlertsEnabled: true,
    auditLoggingEnabled: true,
    sessionTimeoutMinutes: 30,
    uploadLimitMb: 250,
  );
}
