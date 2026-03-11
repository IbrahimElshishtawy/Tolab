class AuthRoles {
  static const String student = 'student';
  static const String doctor = 'doctor';
  static const String ta = 'ta';
  static const String it = 'it';

  // The app has no dedicated "developer" role, so developer access maps to IT.
  static const String defaultDeveloperRole = it;

  static const List<String> allowed = <String>[
    student,
    doctor,
    ta,
    it,
  ];
}
