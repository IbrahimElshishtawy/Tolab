enum AppUserRole {
  student,
  doctor,
  assistant;

  bool get isStaff =>
      this == AppUserRole.doctor || this == AppUserRole.assistant;

  String get storageValue => name;

  static AppUserRole fromStorage(String? value) {
    return switch (value) {
      'doctor' => AppUserRole.doctor,
      'assistant' => AppUserRole.assistant,
      _ => AppUserRole.student,
    };
  }
}

class AuthSessionData {
  const AuthSessionData({
    required this.token,
    required this.role,
    required this.email,
    required this.nationalId,
  });

  final String token;
  final AppUserRole role;
  final String email;
  final String nationalId;
}
