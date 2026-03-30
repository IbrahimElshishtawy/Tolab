import '../../../shared/models/schedule_models.dart';

enum SectionDetailTab { overview, students, schedule, subjects, staff }

enum SectionScheduleViewMode { day, week }

class SectionManagementRecord {
  const SectionManagementRecord({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.yearLabel,
    required this.yearValue,
    required this.semesterLabel,
    required this.status,
    required this.capacity,
    required this.description,
    required this.locationLabel,
    required this.lastUpdatedLabel,
    required this.students,
    required this.subjects,
    required this.staff,
    required this.scheduleEvents,
    required this.performanceTrend,
    required this.alerts,
  });

  final String id;
  final String name;
  final String code;
  final String department;
  final String yearLabel;
  final int yearValue;
  final String semesterLabel;
  final String status;
  final int capacity;
  final String description;
  final String locationLabel;
  final String lastUpdatedLabel;
  final List<SectionStudentRecord> students;
  final List<SectionSubjectRecord> subjects;
  final List<SectionStaffRecord> staff;
  final List<ScheduleEventModel> scheduleEvents;
  final List<SectionChartPoint> performanceTrend;
  final List<SectionAlert> alerts;

  bool get isActive => status == 'Active';
  int get studentsCount => students.length;
  int get activeStudentsCount =>
      students.where((student) => student.status == 'Active').length;
  int get inactiveStudentsCount =>
      students.where((student) => student.status != 'Active').length;
  int get subjectsCount => subjects.length;
  int get staffCount => staff.length;
  int get doctorsCount =>
      staff.where((member) => member.role == 'Doctor').length;
  int get assistantsCount =>
      staff.where((member) => member.role == 'Assistant').length;
  int get availableSeats => capacity - studentsCount;
  int get waitlistCount => availableSeats < 0 ? availableSeats.abs() : 0;
  double get capacityUsage => capacity == 0 ? 0 : studentsCount / capacity;
  int get capacityUsagePercent => (capacityUsage * 100).round();
  double get averageGpa {
    if (students.isEmpty) return 0;
    final total = students.fold<double>(0, (sum, student) => sum + student.gpa);
    return total / students.length;
  }

  double get averageAttendance {
    if (students.isEmpty) return 0;
    final total = students.fold<double>(
      0,
      (sum, student) => sum + student.attendanceRate,
    );
    return total / students.length;
  }

  double get performanceScore {
    if (students.isEmpty) return 0;
    return ((averageGpa / 4) * 60) + (averageAttendance * 0.4);
  }

  SectionCapacityBand get capacityBand {
    if (capacityUsage >= 1) return SectionCapacityBand.full;
    if (capacityUsage >= 0.85) return SectionCapacityBand.almostFull;
    return SectionCapacityBand.available;
  }

  List<SectionChartPoint> get studentDistribution => [
    SectionChartPoint(label: 'Active', value: activeStudentsCount.toDouble()),
    SectionChartPoint(
      label: 'Inactive',
      value: inactiveStudentsCount.toDouble(),
    ),
    SectionChartPoint(
      label: 'At risk',
      value: students.where((student) => student.isAtRisk).length.toDouble(),
    ),
  ];

  SectionManagementRecord copyWith({
    String? status,
    List<SectionStudentRecord>? students,
    List<SectionSubjectRecord>? subjects,
    List<SectionStaffRecord>? staff,
    List<ScheduleEventModel>? scheduleEvents,
    List<SectionAlert>? alerts,
  }) {
    return SectionManagementRecord(
      id: id,
      name: name,
      code: code,
      department: department,
      yearLabel: yearLabel,
      yearValue: yearValue,
      semesterLabel: semesterLabel,
      status: status ?? this.status,
      capacity: capacity,
      description: description,
      locationLabel: locationLabel,
      lastUpdatedLabel: lastUpdatedLabel,
      students: students ?? this.students,
      subjects: subjects ?? this.subjects,
      staff: staff ?? this.staff,
      scheduleEvents: scheduleEvents ?? this.scheduleEvents,
      performanceTrend: performanceTrend,
      alerts: alerts ?? this.alerts,
    );
  }
}

enum SectionCapacityBand { available, almostFull, full }

class SectionStudentRecord {
  const SectionStudentRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.department,
    required this.yearLabel,
    required this.currentSectionCode,
    required this.gpa,
    required this.attendanceRate,
    required this.creditHours,
    required this.performanceLabel,
    required this.lastActivityLabel,
  });

  final String id;
  final String name;
  final String email;
  final String status;
  final String department;
  final String yearLabel;
  final String currentSectionCode;
  final double gpa;
  final double attendanceRate;
  final int creditHours;
  final String performanceLabel;
  final String lastActivityLabel;

  String get initials {
    final tokens = name.trim().split(RegExp(r'\s+'));
    if (tokens.length == 1) return tokens.first.substring(0, 1).toUpperCase();
    return '${tokens.first.substring(0, 1)}${tokens.last.substring(0, 1)}'
        .toUpperCase();
  }

  bool get isAtRisk => gpa < 2.6 || attendanceRate < 0.78;

  SectionStudentRecord copyWith({
    String? status,
    String? department,
    String? yearLabel,
    String? currentSectionCode,
  }) {
    return SectionStudentRecord(
      id: id,
      name: name,
      email: email,
      status: status ?? this.status,
      department: department ?? this.department,
      yearLabel: yearLabel ?? this.yearLabel,
      currentSectionCode: currentSectionCode ?? this.currentSectionCode,
      gpa: gpa,
      attendanceRate: attendanceRate,
      creditHours: creditHours,
      performanceLabel: performanceLabel,
      lastActivityLabel: lastActivityLabel,
    );
  }
}

class SectionSubjectRecord {
  const SectionSubjectRecord({
    required this.code,
    required this.title,
    required this.lecturesCount,
    required this.instructorName,
    required this.deliveryLabel,
    required this.status,
    required this.completionRate,
  });

  final String code;
  final String title;
  final int lecturesCount;
  final String instructorName;
  final String deliveryLabel;
  final String status;
  final double completionRate;
}

class SectionStaffRecord {
  const SectionStaffRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.focusArea,
    required this.officeHoursLabel,
    required this.loadRate,
  });

  final String id;
  final String name;
  final String role;
  final String status;
  final String focusArea;
  final String officeHoursLabel;
  final double loadRate;

  String get initials {
    final tokens = name.trim().split(RegExp(r'\s+'));
    if (tokens.length == 1) return tokens.first.substring(0, 1).toUpperCase();
    return '${tokens.first.substring(0, 1)}${tokens.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class SectionChartPoint {
  const SectionChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class SectionLoadSnapshot {
  const SectionLoadSnapshot({
    required this.id,
    required this.label,
    required this.department,
    required this.yearLabel,
    required this.usedSeats,
    required this.capacity,
  });

  final String id;
  final String label;
  final String department;
  final String yearLabel;
  final int usedSeats;
  final int capacity;

  double get usage => capacity == 0 ? 0 : usedSeats / capacity;
  int get usagePercent => (usage * 100).round();
}

class SectionAlert {
  const SectionAlert({
    required this.title,
    required this.message,
    required this.severity,
  });

  final String title;
  final String message;
  final String severity;
}
