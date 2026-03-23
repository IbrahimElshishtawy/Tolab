import '../../../data/models/user_model.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken:
          (json['accessToken'] ?? json['access_token'] ?? '') as String,
      refreshToken:
          (json['refreshToken'] ?? json['refresh_token'] ?? '') as String,
      user: UserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }
}
