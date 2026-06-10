enum AuthRole {
  admin,
  doctor,
  assistant,
  student,
  unknown;

  static AuthRole fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'admin':
      case 'administrator':
      case 'superadmin':
        return AuthRole.admin;
      case 'doctor':
        return AuthRole.doctor;
      case 'assistant':
      case 'teaching_assistant':
      case 'ta':
      case 'staff':
        return AuthRole.assistant;
      case 'student':
        return AuthRole.student;
      default:
        return AuthRole.unknown;
    }
  }

  String get value => switch (this) {
    AuthRole.admin => 'admin',
    AuthRole.doctor => 'doctor',
    AuthRole.assistant => 'assistant',
    AuthRole.student => 'student',
    AuthRole.unknown => 'unknown',
  };

  bool get isAdmin => this == AuthRole.admin;

  bool get isDoctorAssistant =>
      this == AuthRole.doctor || this == AuthRole.assistant;

  bool get isStudent => this == AuthRole.student;
}
