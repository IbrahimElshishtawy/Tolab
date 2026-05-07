import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/auth_models.dart';
import 'token_storage_service.dart';

/// Manages session state and expiration handling
class SessionManager {
  SessionManager({
    required TokenStorageService tokenStorage,
    required Future<String?> Function() onRefreshToken,
  })  : _tokenStorage = tokenStorage,
        _onRefreshToken = onRefreshToken;

  final TokenStorageService _tokenStorage;
  final Future<String?> Function() onRefreshToken;

  /// Callback for session expiration
  Future<void> Function(String message)? _onSessionExpired;

  /// Set the session expiration callback
  void setSessionExpiredCallback(Future<void> Function(String message) callback) {
    _onSessionExpired = callback;
  }

  /// Handle session expiration
  Future<void> handleSessionExpired(BuildContext context) async {
    await _tokenStorage.clearSession();

    if (_onSessionExpired != null) {
      await _onSessionExpired!('Session expired, please login again.');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired, please login again.'),
          duration: Duration(seconds: 3),
        ),
      );

      context.go('/login');
    }
  }

  /// Check if session is still valid
  Future<bool> isSessionValid() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();

    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
  }

  /// Get current access token
  Future<String?> getAccessToken() => _tokenStorage.readAccessToken();

  /// Get current refresh token
  Future<String?> getRefreshToken() => _tokenStorage.readRefreshToken();

  /// Persist tokens
  Future<void> persistTokens(AuthTokens tokens) async {
    await _tokenStorage.writeAccessToken(tokens.accessToken);
    await _tokenStorage.writeRefreshToken(tokens.refreshToken);
  }

  /// Clear session
  Future<void> clearSession() => _tokenStorage.clearSession();
}
