class LoginResponse {
  final String accessToken;
  final String tokenType;
  final String role;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      role: json['role'],
    );
  }
}

class UserProfile {
  final int id;
  final String email;
  final String fullName;
  final String role;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
    );
  }
}
