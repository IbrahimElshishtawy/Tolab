import 'package:dio/dio.dart';

/// Represents authentication tokens (access and refresh)
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token']?.toString() ?? json['accessToken']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? json['refreshToken']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;
}

/// Represents the current user profile
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
  };
}

/// Represents authentication state
enum AuthState {
  /// Initial state, checking if user is logged in
  initial,
  /// User is authenticated
  authenticated,
  /// User is not authenticated
  unauthenticated,
  /// Session is being refreshed
  refreshing,
  /// Session refresh failed
  refreshFailed,
}

/// Exception thrown during authentication
class AuthException implements Exception {
  AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Exception thrown when session expires
class SessionExpiredException extends AuthException {
  SessionExpiredException() : super('Session expired, please login again.', statusCode: 401);
}

/// Exception thrown when token refresh fails
class TokenRefreshException extends AuthException {
  TokenRefreshException() : super('Failed to refresh session. Please login again.', statusCode: 401);
}
