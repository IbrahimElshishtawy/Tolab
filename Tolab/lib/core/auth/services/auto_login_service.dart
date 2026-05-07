import 'package:flutter/foundation.dart';

import '../models/auth_models.dart';
import 'token_storage_service.dart';

/// Handles automatic login on app startup
class AutoLoginService {
  AutoLoginService({
    required TokenStorageService tokenStorage,
    required Future<(AuthTokens, UserProfile)?> Function() onRefreshAndFetchUser,
  })  : _tokenStorage = tokenStorage,
        _onRefreshAndFetchUser = onRefreshAndFetchUser;

  final TokenStorageService _tokenStorage;
  final Future<(AuthTokens, UserProfile)?> Function() _onRefreshAndFetchUser;

  /// Check if user can be auto-logged in
  Future<bool> canAutoLogin() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();

    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    // Don't auto-login with demo tokens
    if (_isDemoOrMockToken(accessToken)) {
      return false;
    }

    return true;
  }

  /// Attempt to refresh token and get user profile
  Future<(AuthTokens, UserProfile)?> attemptAutoLogin() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Try to refresh the token and fetch user
      final result = await _onRefreshAndFetchUser();
      if (result != null) {
        final (newTokens, userProfile) = result;
        // Persist new tokens
        await _tokenStorage.writeAccessToken(newTokens.accessToken);
        await _tokenStorage.writeRefreshToken(newTokens.refreshToken);
        return (newTokens, userProfile);
      }

      return null;
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      // Clear session on failure
      await _tokenStorage.clearSession();
      return null;
    }
  }

  /// Check if token is demo or mock
  bool _isDemoOrMockToken(String token) {
    return token.startsWith('demo-access-token') ||
        token.startsWith('mock-access-');
  }
}
