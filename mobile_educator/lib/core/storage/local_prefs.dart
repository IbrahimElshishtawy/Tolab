import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  static final LocalPrefs _instance = LocalPrefs._internal();
  factory LocalPrefs() => _instance;
  LocalPrefs._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _languageKey = 'app_language';
  static const _notificationsEnabledKey = 'notifications_enabled';

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }
}
