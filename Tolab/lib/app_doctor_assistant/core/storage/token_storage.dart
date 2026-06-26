import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _key = 'doctor_assistant_session';
  final FlutterSecureStorage _storage;

  Future<void> write(Map<String, dynamic> payload) async {
    try {
      await _storage.write(key: _key, value: jsonEncode(payload));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}
