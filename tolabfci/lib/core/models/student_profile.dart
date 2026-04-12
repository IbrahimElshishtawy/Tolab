class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.nationalId,
    required this.faculty,
    required this.department,
    required this.level,
    required this.academicAdvisor,
    required this.gpa,
    required this.seatNumber,
    required this.previousQualification,
  });

  final String id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String nationalId;
  final String faculty;
  final String department;
  final String level;
  final String academicAdvisor;
  final double gpa;
  final String seatNumber;
  final String previousQualification;
}
