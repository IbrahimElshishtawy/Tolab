import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationManager {
  static Map<String, String>? _localizedStrings;

  static Future<void> load(String languageCode) async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      _localizedStrings = {};
    }
  }

  static String translate(String key) {
    if (_localizedStrings == null) return key;
    return _localizedStrings![key] ?? key;
  }
}

extension AppLocalizations on String {
  String tr() => LocalizationManager.translate(this);
}
