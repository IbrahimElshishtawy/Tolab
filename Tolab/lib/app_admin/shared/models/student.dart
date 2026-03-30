class Student {
  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.level,
    required this.section,
    required this.status,
    required this.gpa,
    required this.enrolledSubjects,
  });

  final String id;
  final String name;
  final String email;
  final String department;
  final String level;
  final String section;
  final String status;
  final double gpa;
  final int enrolledSubjects;
}
