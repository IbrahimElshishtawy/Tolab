import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'current_locale_state.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._(
    this._preferences,
    this._locale, {
    required bool hasStoredPreference,
  }) : _hasStoredPreference = hasStoredPreference {
    CurrentLocaleState.update(_locale.languageCode);
  }

  static const String _storageKey = 'tolab.locale';
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  final SharedPreferences _preferences;
  Locale _locale;
  bool _hasStoredPreference;

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  bool get isArabic => languageCode == 'ar';

  static Future<LocaleController> initialize({
    String? fallbackLanguageCode,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final storedLanguageCode = preferences.getString(_storageKey);
    final hasStoredPreference = _isSupported(storedLanguageCode);
    final resolvedLanguageCode = hasStoredPreference
        ? storedLanguageCode!
        : _normalize(fallbackLanguageCode);

    return LocaleController._(
      preferences,
      Locale(resolvedLanguageCode),
      hasStoredPreference: hasStoredPreference,
    );
  }

  Future<void> setLanguage(
    String languageCode, {
    bool persist = true,
  }) async {
    final normalized = _normalize(languageCode);
    if (_locale.languageCode == normalized &&
        (!persist || _hasStoredPreference)) {
      return;
    }

    _locale = Locale(normalized);
    CurrentLocaleState.update(normalized);

    if (persist) {
      _hasStoredPreference = true;
      await _preferences.setString(_storageKey, normalized);
    }

    notifyListeners();
  }

  Future<void> hydrateFromUserPreference(String? languageCode) async {
    if (_hasStoredPreference || !_isSupported(languageCode)) {
      return;
    }

    await setLanguage(languageCode!, persist: false);
  }

  Future<void> toggle() => setLanguage(isArabic ? 'en' : 'ar');

  static String normalizeLanguageCode(String? languageCode) =>
      _normalize(languageCode);

  static bool _isSupported(String? languageCode) =>
      languageCode == 'en' || languageCode == 'ar';

  static String _normalize(String? languageCode) =>
      languageCode == 'ar' ? 'ar' : 'en';
}
