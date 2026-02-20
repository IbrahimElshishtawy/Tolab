import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _roleKey = 'user_role';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
