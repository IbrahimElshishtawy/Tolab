import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for securely storing and retrieving authentication tokens
class TokenStorageService {
  TokenStorageService({
    FlutterSecureStorage? secureStorage,
    SharedPreferences? sharedPreferences,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _sharedPreferences = sharedPreferences;

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences? _sharedPreferences;

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _userEmailKey = 'auth_user_email';

  /// Write access token to secure storage
  Future<void> writeAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  /// Read access token from secure storage
  Future<String?> readAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Write refresh token to secure storage
  Future<void> writeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Read refresh token from secure storage
  Future<String?> readRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Write user ID to shared preferences (non-sensitive)
  Future<void> writeUserId(String userId) async {
    await _sharedPreferences?.setString(_userIdKey, userId);
  }

  /// Read user ID from shared preferences
  Future<String?> readUserId() async {
    return _sharedPreferences?.getString(_userIdKey);
  }

  /// Write user email to shared preferences (non-sensitive)
  Future<void> writeUserEmail(String email) async {
    await _sharedPreferences?.setString(_userEmailKey, email);
  }

  /// Read user email from shared preferences
  Future<String?> readUserEmail() async {
    return _sharedPreferences?.getString(_userEmailKey);
  }

  /// Clear all authentication data
  Future<void> clearSession() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _sharedPreferences?.remove(_userIdKey) ?? Future.value(),
        _sharedPreferences?.remove(_userEmailKey) ?? Future.value(),
      ]);
    } catch (_) {
      try {
        await _sharedPreferences?.remove(_userIdKey);
        await _sharedPreferences?.remove(_userEmailKey);
      } catch (_) {}
    }
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    final accessToken = await readAccessToken();
    final refreshToken = await readRefreshToken();
    return accessToken != null && accessToken.isNotEmpty &&
           refreshToken != null && refreshToken.isNotEmpty;
  }

  /// Check if access token exists and is not empty
  Future<bool> hasAccessToken() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if refresh token exists and is not empty
  Future<bool> hasRefreshToken() async {
    final token = await readRefreshToken();
    return token != null && token.isNotEmpty;
  }
}
