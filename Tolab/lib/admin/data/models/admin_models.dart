import 'package:intl/intl.dart';

abstract class AdminEntity {
  String get id;
  String get primaryLabel;
  String get secondaryLabel;
  String get status;
}

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.totalStudents,
    required this.totalDoctors,
    required this.totalSubjects,
    required this.pendingAssignments,
    required this.activities,
    required this.trendValues,
  });

  final int totalStudents;
  final int totalDoctors;
  final int totalSubjects;
  final int pendingAssignments;
  final List<ActivityItemModel> activities;
  final List<double> trendValues;
}

class ActivityItemModel {
  const ActivityItemModel({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.status,
  });

  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String status;

  String get relativeLabel => DateFormat('MMM d, hh:mm a').format(timestamp);
}

class StudentModel implements AdminEntity {
  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.academicYear,
    required this.batch,
    required this.gpa,
    required this.status,
    required this.enrolledSubjects,
  });

  @override
  final String id;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String academicYear;
  final String batch;
  final double gpa;
  @override
  final String status;
  final int enrolledSubjects;

  @override
  String get primaryLabel => name;

  @override
  String get secondaryLabel => '$department • $academicYear';

  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? academicYear,
    String? batch,
    double? gpa,
    String? status,
    int? enrolledSubjects,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
      batch: batch ?? this.batch,
      gpa: gpa ?? this.gpa,
      status: status ?? this.status,
      enrolledSubjects: enrolledSubjects ?? this.enrolledSubjects,
    );
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    department: json['department'] as String? ?? '',
    academicYear: json['academic_year'] as String? ?? '',
    batch: json['batch'] as String? ?? '',
    gpa: (json['gpa'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? 'active',
    enrolledSubjects: json['enrolled_subjects'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'department': department,
    'academic_year': academicYear,
    'batch': batch,
    'gpa': gpa,
    'status': status,
    'enrolled_subjects': enrolledSubjects,
  };
}

class StaffModel implements AdminEntity {
  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.office,
    required this.status,
  });

  @override
  final String id;
  final String name;
  final String email;
  final String department;
  final String role;
  final String office;
  @override
  final String status;

  @override
  String get primaryLabel => name;

  @override
  String get secondaryLabel => '$department • $office';

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    department: json['department'] as String? ?? '',
    role: json['role'] as String? ?? '',
    office: json['office'] as String? ?? '',
    status: json['status'] as String? ?? 'active',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'department': department,
    'role': role,
    'office': office,
    'status': status,
  };
}

class DepartmentModel implements AdminEntity {
  const DepartmentModel({
    required this.id,
    required this.name,
    required this.head,
    required this.studentsCount,
    required this.status,
  });

  @override
  final String id;
  final String name;
  final String head;
  final int studentsCount;
  @override
  final String status;

  @override
  String get primaryLabel => name;

  @override
  String get secondaryLabel => '$head • $studentsCount students';

  factory DepartmentModel.fromJson(Map<String, dynamic> json) =>
      DepartmentModel(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        head: json['head'] as String? ?? '',
        studentsCount: json['students_count'] as int? ?? 0,
        status: json['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'head': head,
    'students_count': studentsCount,
    'status': status,
  };
}

class AcademicYearModel implements AdminEntity {
  const AcademicYearModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  @override
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  @override
  final String status;

  @override
  String get primaryLabel => name;

  @override
  String get secondaryLabel =>
      '${DateFormat('MMM y').format(startDate)} - ${DateFormat('MMM y').format(endDate)}';

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) =>
      AcademicYearModel(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        startDate:
            DateTime.tryParse(json['start_date'] as String? ?? '') ??
            DateTime.now(),
        endDate:
            DateTime.tryParse(json['end_date'] as String? ?? '') ??
            DateTime.now(),
        status: json['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'status': status,
  };
}

class BatchModel implements AdminEntity {
  const BatchModel({
    required this.id,
    required this.name,
    required this.department,
    required this.academicYear,
    required this.studentsCount,
    required this.status,
  });

  @override
  final String id;
  final String name;
  final String department;
  final String academicYear;
  final int studentsCount;
  @override
  final String status;

  @override
  String get primaryLabel => name;

  @override
  String get secondaryLabel => '$department • $studentsCount students';

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
    id: json['id'].toString(),
    name: json['name'] as String? ?? '',
    department: json['department'] as String? ?? '',
    academicYear: json['academic_year'] as String? ?? '',
    studentsCount: json['students_count'] as int? ?? 0,
    status: json['status'] as String? ?? 'active',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'department': department,
    'academic_year': academicYear,
    'students_count': studentsCount,
    'status': status,
  };
}

class SubjectModel implements AdminEntity {
  const SubjectModel({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.creditHours,
    required this.doctorName,
    required this.status,
  });

  @override
  final String id;
  final String code;
  final String name;
  final String department;
  final int creditHours;
  final String doctorName;
  @override
  final String status;

  @override
  String get primaryLabel => '$code • $name';

  @override
  String get secondaryLabel => '$department • $creditHours credits';

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json['id'].toString(),
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    department: json['department'] as String? ?? '',
    creditHours: json['credit_hours'] as int? ?? 0,
    doctorName: json['doctor_name'] as String? ?? '',
    status: json['status'] as String? ?? 'active',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'department': department,
    'credit_hours': creditHours,
    'doctor_name': doctorName,
    'status': status,
  };
}

class SubjectAssignmentModel implements AdminEntity {
  const SubjectAssignmentModel({
    required this.id,
    required this.subjectName,
    required this.doctorName,
    required this.assistantName,
    required this.batch,
    required this.status,
  });

  @override
  final String id;
  final String subjectName;
  final String doctorName;
  final String assistantName;
  final String batch;
  @override
  final String status;

  @override
  String get primaryLabel => subjectName;

  @override
  String get secondaryLabel => '$doctorName • $assistantName';

  factory SubjectAssignmentModel.fromJson(Map<String, dynamic> json) =>
      SubjectAssignmentModel(
        id: json['id'].toString(),
        subjectName: json['subject_name'] as String? ?? '',
        doctorName: json['doctor_name'] as String? ?? '',
        assistantName: json['assistant_name'] as String? ?? '',
        batch: json['batch'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_name': subjectName,
    'doctor_name': doctorName,
    'assistant_name': assistantName,
    'batch': batch,
    'status': status,
  };
}

class CourseOfferingModel implements AdminEntity {
  const CourseOfferingModel({
    required this.id,
    required this.subjectName,
    required this.semester,
    required this.batch,
    required this.capacity,
    required this.enrolled,
    required this.status,
  });

  @override
  final String id;
  final String subjectName;
  final String semester;
  final String batch;
  final int capacity;
  final int enrolled;
  @override
  final String status;

  @override
  String get primaryLabel => subjectName;

  @override
  String get secondaryLabel => '$semester • $enrolled / $capacity';

  factory CourseOfferingModel.fromJson(Map<String, dynamic> json) =>
      CourseOfferingModel(
        id: json['id'].toString(),
        subjectName: json['subject_name'] as String? ?? '',
        semester: json['semester'] as String? ?? '',
        batch: json['batch'] as String? ?? '',
        capacity: json['capacity'] as int? ?? 0,
        enrolled: json['enrolled'] as int? ?? 0,
        status: json['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject_name': subjectName,
    'semester': semester,
    'batch': batch,
    'capacity': capacity,
    'enrolled': enrolled,
    'status': status,
  };
}

class EnrollmentModel implements AdminEntity {
  const EnrollmentModel({
    required this.id,
    required this.studentName,
    required this.subjectName,
    required this.batch,
    required this.createdAt,
    required this.status,
  });

  @override
  final String id;
  final String studentName;
  final String subjectName;
  final String batch;
  final DateTime createdAt;
  @override
  final String status;

  @override
  String get primaryLabel => studentName;

  @override
  String get secondaryLabel =>
      '$subjectName • ${DateFormat('MMM d').format(createdAt)}';

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentModel(
        id: json['id'].toString(),
        studentName: json['student_name'] as String? ?? '',
        subjectName: json['subject_name'] as String? ?? '',
        batch: json['batch'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        status: json['status'] as String? ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_name': studentName,
    'subject_name': subjectName,
    'batch': batch,
    'created_at': createdAt.toIso8601String(),
    'status': status,
  };
}

class ScheduleItemModel implements AdminEntity {
  const ScheduleItemModel({
    required this.id,
    required this.title,
    required this.day,
    required this.time,
    required this.location,
    required this.owner,
    required this.status,
  });

  @override
  final String id;
  final String title;
  final String day;
  final String time;
  final String location;
  final String owner;
  @override
  final String status;

  @override
  String get primaryLabel => title;

  @override
  String get secondaryLabel => '$day • $time • $location';

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) =>
      ScheduleItemModel(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        day: json['day'] as String? ?? '',
        time: json['time'] as String? ?? '',
        location: json['location'] as String? ?? '',
        owner: json['owner'] as String? ?? '',
        status: json['status'] as String? ?? 'scheduled',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'day': day,
    'time': time,
    'location': location,
    'owner': owner,
    'status': status,
  };
}

class AdminNotificationModel implements AdminEntity {
  const AdminNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.createdAt,
    required this.isRead,
    required this.status,
  });

  @override
  final String id;
  final String title;
  final String body;
  final String audience;
  final DateTime createdAt;
  final bool isRead;
  @override
  final String status;

  @override
  String get primaryLabel => title;

  @override
  String get secondaryLabel =>
      '$audience • ${DateFormat('MMM d').format(createdAt)}';

  AdminNotificationModel copyWith({bool? isRead}) {
    return AdminNotificationModel(
      id: id,
      title: title,
      body: body,
      audience: audience,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      status: status,
    );
  }

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) =>
      AdminNotificationModel(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        audience: json['audience'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        isRead: json['is_read'] as bool? ?? false,
        status: json['status'] as String? ?? 'sent',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'audience': audience,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
    'status': status,
  };
}

class ProfileModel {
  const ProfileModel({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.department,
  });

  final String name;
  final String email;
  final String role;
  final String phone;
  final String department;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    department: json['department'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'department': department,
  };
}

class SettingsModel {
  const SettingsModel({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.compactSidebar,
    required this.autoRefreshDashboard,
  });

  final bool pushNotifications;
  final bool emailNotifications;
  final bool compactSidebar;
  final bool autoRefreshDashboard;

  SettingsModel copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? compactSidebar,
    bool? autoRefreshDashboard,
  }) {
    return SettingsModel(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      compactSidebar: compactSidebar ?? this.compactSidebar,
      autoRefreshDashboard: autoRefreshDashboard ?? this.autoRefreshDashboard,
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    pushNotifications: json['push_notifications'] as bool? ?? true,
    emailNotifications: json['email_notifications'] as bool? ?? true,
    compactSidebar: json['compact_sidebar'] as bool? ?? false,
    autoRefreshDashboard: json['auto_refresh_dashboard'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'push_notifications': pushNotifications,
    'email_notifications': emailNotifications,
    'compact_sidebar': compactSidebar,
    'auto_refresh_dashboard': autoRefreshDashboard,
  };
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
  });

  final List<T> items;
  final int total;
  final int page;
  final int perPage;
}
