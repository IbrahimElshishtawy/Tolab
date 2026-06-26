import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  Future<void> writeAccessToken(String token) async {
    try {
      await _storage.write(key: accessTokenKey, value: token);
    } catch (_) {}
  }

  Future<void> writeRefreshToken(String token) async {
    try {
      await _storage.write(key: refreshTokenKey, value: token);
    } catch (_) {}
  }

  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
