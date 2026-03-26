import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  SharedPreferences? _prefs;

  Future<LocalStorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String? read(String key) => _prefs?.getString(key);
  Future<void> write(String key, String value) async =>
      _prefs?.setString(key, value);
  Future<void> remove(String key) async => _prefs?.remove(key);
}
