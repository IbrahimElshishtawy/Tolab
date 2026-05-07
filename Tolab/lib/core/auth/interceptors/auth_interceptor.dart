import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import '../services/token_storage_service.dart';

/// Professional Dio interceptor for handling authentication and token refresh
///
/// Features:
/// - Automatically attaches access token to requests
/// - Detects 401 Unauthorized responses
/// - Automatically refreshes expired tokens
/// - Retries failed requests after token refresh
/// - Prevents infinite refresh loops
/// - Prevents multiple simultaneous refresh requests
/// - Handles errors gracefully
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorageService tokenStorage,
    required Dio dio,
    required Future<String?> Function() onRefreshToken,
    required Future<void> Function(String message) onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _dio = dio,
        _onRefreshToken = onRefreshToken,
        _onSessionExpired = onSessionExpired;

  final TokenStorageService _tokenStorage;
  final Dio _dio;
  final Future<String?> Function() onRefreshToken;
  final Future<void> Function(String message) onSessionExpired;

  /// Mutex to prevent multiple simultaneous token refresh requests
  bool _isRefreshing = false;

  /// Queue of requests waiting for token refresh to complete
  final List<_PendingRequest> _pendingRequests = [];

  /// Paths that don't require authentication
  static const List<String> _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/forgot-password',
    '/health',
  ];

  /// Demo/mock token prefixes (for development)
  static const String _demoAccessTokenPrefix = 'demo-access-token';
  static const String _mockAccessTokenPrefix = 'mock-access-';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token to request if available
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (error.response?.statusCode != 401) {
      handler.next(error);
      return;
    }

    // Don't try to refresh auth endpoints
    if (_isPublicPath(error.requestOptions.path)) {
      handler.next(error);
      return;
    }

    // Check if we can attempt token refresh
    if (!await _canRefreshToken()) {
      await _handleSessionExpired();
      handler.next(error);
      return;
    }

    // If already refreshing, queue this request
    if (_isRefreshing) {
      _pendingRequests.add(_PendingRequest(error, handler));
      return;
    }

    // Attempt token refresh
    _isRefreshing = true;
    try {
      final newAccessToken = await _refreshAccessToken();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _handleSessionExpired();
        handler.next(error);
        return;
      }

      // Retry the original request with new token
      final retryOptions = error.requestOptions.copyWith(
        headers: {
          ...error.requestOptions.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
      );

      try {
        final response = await _dio.fetch<dynamic>(retryOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(error);
      }

      // Process pending requests
      _processPendingRequests(newAccessToken);
    } catch (e) {
      await _handleSessionExpired();
      handler.next(error);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Refresh the access token using the refresh token
  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      // Call the refresh token callback
      final newAccessToken = await onRefreshToken();
      return newAccessToken;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
    }
  }

  /// Check if we can attempt token refresh
  Future<bool> _canRefreshToken() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    // Don't refresh demo/mock tokens
    if (_isDemoOrMockToken(refreshToken)) {
      return false;
    }

    return true;
  }

  /// Handle session expiration
  Future<void> _handleSessionExpired() async {
    await _tokenStorage.clearSession();
    await onSessionExpired('Session expired, please login again.');
  }

  /// Process pending requests with new token
  void _processPendingRequests(String newAccessToken) {
    for (final pending in _pendingRequests) {
      final retryOptions = pending.error.requestOptions.copyWith(
        headers: {
          ...pending.error.requestOptions.headers,
          'Authorization': 'Bearer $newAccessToken',
        },
      );

      _dio.fetch<dynamic>(retryOptions).then(
        (response) => pending.handler.resolve(response),
        onError: (e) => pending.handler.next(pending.error),
      );
    }

    _pendingRequests.clear();
  }

  /// Check if path is public (doesn't require authentication)
  bool _isPublicPath(String path) {
    final normalizedPath = path.toLowerCase().trim();
    return _publicPaths.any((publicPath) => normalizedPath.startsWith(publicPath));
  }

  /// Check if token is a demo or mock token
  bool _isDemoOrMockToken(String token) {
    return token.startsWith(_demoAccessTokenPrefix) ||
           token.startsWith(_mockAccessTokenPrefix);
  }
}

/// Represents a pending request waiting for token refresh
class _PendingRequest {
  _PendingRequest(this.error, this.handler);

  final DioException error;
  final ErrorInterceptorHandler handler;
}
