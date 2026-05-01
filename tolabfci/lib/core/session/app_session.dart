enum AppUserRole {
  student;

  bool get isStaff => false;

  String get storageValue => name;

  static AppUserRole fromStorage(String? value) {
    return AppUserRole.student;
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
