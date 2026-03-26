import '../../../data/models/admin_models.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.profile,
  });

  final String accessToken;
  final String refreshToken;
  final ProfileModel profile;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        accessToken: json['access_token'] as String? ?? '',
        refreshToken: json['refresh_token'] as String? ?? '',
        profile: ProfileModel.fromJson(
          json['user'] as Map<String, dynamic>? ?? {},
        ),
      );
}
