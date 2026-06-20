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
}
