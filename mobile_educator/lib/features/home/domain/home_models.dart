class User {
  final int id;
  final String name;
  final String role;
  final String email;
  final bool isActive;
  final String? profileImageUrl;
  final List<String> departments;
  final String academicYear;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.isActive,
    this.profileImageUrl,
    required this.departments,
    required this.academicYear,
  });
}

class HomeSummary {
  final List<SubjectSession> upcomingLectures;
  final List<SubjectSession> upcomingQuizzes;

  HomeSummary({required this.upcomingLectures, required this.upcomingQuizzes});
}

class SubjectSession {
  final String subjectName;
  final DateTime date;

  SubjectSession({required this.subjectName, required this.date});
}
