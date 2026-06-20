class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.studentNumber,
    required this.nationalId,
    required this.faculty,
    required this.department,
    required this.level,
    required this.academicAdvisor,
    required this.academicStatus,
    required this.gpa,
    required this.completedHours,
    required this.registeredHours,
    required this.seatNumber,
    required this.previousQualification,
    this.gender = 'male',
  });

  final String id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String studentNumber;
  final String nationalId;
  final String faculty;
  final String department;
  final String level;
  final String academicAdvisor;
  final String academicStatus;
  final double gpa;
  final int completedHours;
  final int registeredHours;
  final String seatNumber;
  final String previousQualification;
  final String gender;

  bool get isMale => gender == 'male';

  StudentProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? studentNumber,
    String? nationalId,
    String? faculty,
    String? department,
    String? level,
    String? academicAdvisor,
    String? academicStatus,
    double? gpa,
    int? completedHours,
    int? registeredHours,
    String? seatNumber,
    String? previousQualification,
    String? gender,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      studentNumber: studentNumber ?? this.studentNumber,
      nationalId: nationalId ?? this.nationalId,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      level: level ?? this.level,
      academicAdvisor: academicAdvisor ?? this.academicAdvisor,
      academicStatus: academicStatus ?? this.academicStatus,
      gpa: gpa ?? this.gpa,
      completedHours: completedHours ?? this.completedHours,
      registeredHours: registeredHours ?? this.registeredHours,
      seatNumber: seatNumber ?? this.seatNumber,
      previousQualification: previousQualification ?? this.previousQualification,
      gender: gender ?? this.gender,
    );
  }

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString() ?? '',
      studentNumber: json['studentNumber']?.toString() ?? json['student_number']?.toString() ?? '',
      nationalId: json['nationalId']?.toString() ?? json['national_id']?.toString() ?? '',
      faculty: json['faculty']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      academicAdvisor: json['academicAdvisor']?.toString() ?? json['academic_advisor']?.toString() ?? '',
      academicStatus: json['academicStatus']?.toString() ?? json['academic_status']?.toString() ?? '',
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      completedHours: (json['completedHours'] ?? json['completed_hours'] as num?)?.toInt() ?? 0,
      registeredHours: (json['registeredHours'] ?? json['registered_hours'] as num?)?.toInt() ?? 0,
      seatNumber: json['seatNumber']?.toString() ?? json['seat_number']?.toString() ?? '',
      previousQualification: json['previousQualification']?.toString() ?? json['previous_qualification']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'male',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'studentNumber': studentNumber,
      'nationalId': nationalId,
      'faculty': faculty,
      'department': department,
      'level': level,
      'academicAdvisor': academicAdvisor,
      'academicStatus': academicStatus,
      'gpa': gpa,
      'completedHours': completedHours,
      'registeredHours': registeredHours,
      'seatNumber': seatNumber,
      'previousQualification': previousQualification,
      'gender': gender,
    };
  }
}
