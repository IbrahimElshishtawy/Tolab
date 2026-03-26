import '../../core/helpers/json_types.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(JsonMap json) {
    return AuthTokens(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.department,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? department;
  final String? avatarUrl;

  factory UserProfile.fromJson(JsonMap json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'admin',
      status: json['status']?.toString() ?? 'active',
      department: json['department']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
