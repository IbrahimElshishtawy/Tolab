import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';

class SessionStorage {
  SessionStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'tolab_unified_session';
  final FlutterSecureStorage _storage;

  Future<void> write(AuthSession session) async {
    try {
      await _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
    } catch (_) {}
  }

  Future<AuthSession?> read() async {
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }

      return AuthSession.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {}
  }
}
