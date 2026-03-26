import 'admin_models.dart';

class AdminSeedData {
  const AdminSeedData._();

  static DashboardSummaryModel dashboard() => DashboardSummaryModel(
    totalStudents: students.length,
    totalDoctors: doctors.length,
    totalSubjects: subjects.length,
    pendingAssignments: assignments
        .where((item) => item.status != 'active')
        .length,
    activities: [
      ActivityItemModel(
        title: 'Broadcast sent to all students',
        subtitle: 'Reminder for course registration deadlines',
        timestamp: DateTime(2026, 3, 26, 9, 10),
        status: 'success',
      ),
      ActivityItemModel(
        title: 'New batch created',
        subtitle: 'Software Engineering 2027 added to the system',
        timestamp: DateTime(2026, 3, 25, 15, 45),
        status: 'info',
      ),
      ActivityItemModel(
        title: 'Subject assignment updated',
        subtitle: 'Operating Systems reassigned to Dr. Layla Samir',
        timestamp: DateTime(2026, 3, 24, 12, 5),
        status: 'warning',
      ),
    ],
    trendValues: const [28, 35, 31, 44, 48, 52, 60],
  );

  static final List<StudentModel> students = [
    const StudentModel(
      id: 'ST-1021',
      name: 'Mariam Adel',
      email: 'mariam.adel@tolab.edu',
      phone: '+20 100 900 1200',
      department: 'Computer Science',
      academicYear: 'Year 3',
      batch: 'CS-2024',
      gpa: 3.72,
      status: 'active',
      enrolledSubjects: 6,
    ),
    const StudentModel(
      id: 'ST-1042',
      name: 'Youssef Ahmed',
      email: 'youssef.ahmed@tolab.edu',
      phone: '+20 100 900 1201',
      department: 'Information Systems',
      academicYear: 'Year 2',
      batch: 'IS-2025',
      gpa: 3.41,
      status: 'review',
      enrolledSubjects: 5,
    ),
    const StudentModel(
      id: 'ST-1088',
      name: 'Hana Samy',
      email: 'hana.samy@tolab.edu',
      phone: '+20 100 900 1202',
      department: 'Software Engineering',
      academicYear: 'Year 4',
      batch: 'SE-2023',
      gpa: 3.89,
      status: 'active',
      enrolledSubjects: 7,
    ),
  ];

  static final List<StaffModel> doctors = [
    const StaffModel(
      id: 'DR-14',
      name: 'Dr. Layla Samir',
      email: 'layla.samir@tolab.edu',
      department: 'Computer Science',
      role: 'Doctor',
      office: 'B3-204',
      status: 'active',
    ),
    const StaffModel(
      id: 'DR-18',
      name: 'Dr. Omar Nabil',
      email: 'omar.nabil@tolab.edu',
      department: 'Software Engineering',
      role: 'Doctor',
      office: 'C1-112',
      status: 'active',
    ),
  ];

  static final List<StaffModel> assistants = [
    const StaffModel(
      id: 'TA-40',
      name: 'Nour Khaled',
      email: 'nour.khaled@tolab.edu',
      department: 'Computer Science',
      role: 'Assistant',
      office: 'Lab 3',
      status: 'active',
    ),
    const StaffModel(
      id: 'TA-48',
      name: 'Ziad Mostafa',
      email: 'ziad.mostafa@tolab.edu',
      department: 'Information Systems',
      role: 'Assistant',
      office: 'Lab 1',
      status: 'leave',
    ),
  ];

  static final List<DepartmentModel> departments = [
    const DepartmentModel(
      id: 'DEP-1',
      name: 'Computer Science',
      head: 'Dr. Maha Hussein',
      studentsCount: 1240,
      status: 'active',
    ),
    const DepartmentModel(
      id: 'DEP-2',
      name: 'Information Systems',
      head: 'Dr. Karim Salah',
      studentsCount: 860,
      status: 'active',
    ),
    const DepartmentModel(
      id: 'DEP-3',
      name: 'Software Engineering',
      head: 'Dr. Hisham Adel',
      studentsCount: 540,
      status: 'active',
    ),
  ];

  static final List<AcademicYearModel> academicYears = [
    AcademicYearModel(
      id: 'AY-2025',
      name: '2025 / 2026',
      startDate: DateTime(2025, 9, 1),
      endDate: DateTime(2026, 7, 20),
      status: 'current',
    ),
    AcademicYearModel(
      id: 'AY-2024',
      name: '2024 / 2025',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2025, 7, 15),
      status: 'archived',
    ),
  ];

  static final List<BatchModel> batches = [
    const BatchModel(
      id: 'BA-2024-CS',
      name: 'CS-2024',
      department: 'Computer Science',
      academicYear: '2025 / 2026',
      studentsCount: 320,
      status: 'active',
    ),
    const BatchModel(
      id: 'BA-2025-IS',
      name: 'IS-2025',
      department: 'Information Systems',
      academicYear: '2025 / 2026',
      studentsCount: 280,
      status: 'active',
    ),
  ];

  static final List<SubjectModel> subjects = [
    const SubjectModel(
      id: 'SUB-201',
      code: 'CS401',
      name: 'Operating Systems',
      department: 'Computer Science',
      creditHours: 3,
      doctorName: 'Dr. Layla Samir',
      status: 'active',
    ),
    const SubjectModel(
      id: 'SUB-207',
      code: 'SE330',
      name: 'Software Testing',
      department: 'Software Engineering',
      creditHours: 2,
      doctorName: 'Dr. Omar Nabil',
      status: 'active',
    ),
  ];

  static final List<SubjectAssignmentModel> assignments = [
    const SubjectAssignmentModel(
      id: 'AS-301',
      subjectName: 'Operating Systems',
      doctorName: 'Dr. Layla Samir',
      assistantName: 'Nour Khaled',
      batch: 'CS-2024',
      status: 'active',
    ),
    const SubjectAssignmentModel(
      id: 'AS-302',
      subjectName: 'Software Testing',
      doctorName: 'Dr. Omar Nabil',
      assistantName: 'Ziad Mostafa',
      batch: 'SE-2023',
      status: 'review',
    ),
  ];

  static final List<CourseOfferingModel> offerings = [
    const CourseOfferingModel(
      id: 'CO-10',
      subjectName: 'Operating Systems',
      semester: 'Spring 2026',
      batch: 'CS-2024',
      capacity: 180,
      enrolled: 154,
      status: 'active',
    ),
    const CourseOfferingModel(
      id: 'CO-11',
      subjectName: 'Software Testing',
      semester: 'Spring 2026',
      batch: 'SE-2023',
      capacity: 120,
      enrolled: 112,
      status: 'active',
    ),
  ];

  static final List<EnrollmentModel> enrollments = [
    EnrollmentModel(
      id: 'EN-501',
      studentName: 'Mariam Adel',
      subjectName: 'Operating Systems',
      batch: 'CS-2024',
      createdAt: DateTime(2026, 2, 14),
      status: 'confirmed',
    ),
    EnrollmentModel(
      id: 'EN-502',
      studentName: 'Youssef Ahmed',
      subjectName: 'Database Systems',
      batch: 'IS-2025',
      createdAt: DateTime(2026, 2, 15),
      status: 'pending',
    ),
  ];

  static final List<ScheduleItemModel> schedules = [
    const ScheduleItemModel(
      id: 'SC-11',
      title: 'Operating Systems Lecture',
      day: 'Sunday',
      time: '09:00 - 10:30',
      location: 'Hall A1',
      owner: 'Dr. Layla Samir',
      status: 'scheduled',
    ),
    const ScheduleItemModel(
      id: 'SC-12',
      title: 'Software Testing Lab',
      day: 'Tuesday',
      time: '12:00 - 14:00',
      location: 'Lab C2',
      owner: 'Ziad Mostafa',
      status: 'updated',
    ),
  ];

  static final List<AdminNotificationModel> notifications = [
    AdminNotificationModel(
      id: 'NO-11',
      title: 'Exam seating plans ready',
      body: 'Final exam seating plans are now published for all departments.',
      audience: 'Students',
      createdAt: DateTime(2026, 3, 26, 8, 30),
      isRead: false,
      status: 'sent',
    ),
    AdminNotificationModel(
      id: 'NO-12',
      title: 'Assignment review pending',
      body: 'Two subject assignments still need dean approval.',
      audience: 'Admin',
      createdAt: DateTime(2026, 3, 25, 11, 15),
      isRead: true,
      status: 'action',
    ),
  ];

  static ProfileModel profile() => const ProfileModel(
    name: 'Alaa Hassan',
    email: 'alaa.hassan@tolab.edu',
    role: 'Super Admin',
    phone: '+20 100 220 3344',
    department: 'University Administration',
  );

  static SettingsModel settings() => const SettingsModel(
    pushNotifications: true,
    emailNotifications: true,
    compactSidebar: false,
    autoRefreshDashboard: true,
  );
}
