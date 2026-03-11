class AuthRoles {
  static const String student = 'student';
  static const String doctor = 'doctor';
  static const String ta = 'ta';
  static const String it = 'it';

  static const String defaultRole = student;

  static const List<String> allowed = <String>[
    student,
    doctor,
    ta,
    it,
  ];
}
