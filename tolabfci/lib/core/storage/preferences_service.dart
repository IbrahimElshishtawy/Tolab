import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  const PreferencesService(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<void> setBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }

  bool getBool(String key, {bool fallback = false}) {
    return _sharedPreferences.getBool(key) ?? fallback;
  }

  Future<void> setString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  String? getString(String key) => _sharedPreferences.getString(key);
}
