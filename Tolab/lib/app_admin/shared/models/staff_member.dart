class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.title,
    required this.department,
    required this.subjects,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final String title;
  final String department;
  final int subjects;
  final String status;
}
