import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService extends GetxService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  Future<LocalStorageService> init() async => this;

  String? readString(String key) => _preferences.getString(key);
  bool? readBool(String key) => _preferences.getBool(key);

  Future<void> writeString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<void> writeBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}
