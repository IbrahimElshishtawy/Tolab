import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.isLocalSession,
    required this.source,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final bool isLocalSession;
  final String source;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(
        Map<String, dynamic>.from(
          json['user'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      isLocalSession: json['local_session'] == true,
      source: json['source']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'local_session': isLocalSession,
      'source': source,
    };
  }
}
