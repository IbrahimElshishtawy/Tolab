import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  static Future<LocalStorageService> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService(preferences);
  }

  bool readBool(String key, {bool fallback = false}) =>
      _preferences.getBool(key) ?? fallback;

  String readString(String key, {String fallback = ''}) =>
      _preferences.getString(key) ?? fallback;

  int readInt(String key, {int fallback = 0}) =>
      _preferences.getInt(key) ?? fallback;

  Future<void> writeBool(String key, bool value) =>
      _preferences.setBool(key, value);

  Future<void> writeString(String key, String value) =>
      _preferences.setString(key, value);

  Future<void> writeInt(String key, int value) =>
      _preferences.setInt(key, value);
}
