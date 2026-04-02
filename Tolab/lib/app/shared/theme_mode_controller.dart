import 'package:flutter/material.dart';

class ThemeModeController extends ChangeNotifier {
  ThemeModeController({ThemeMode initialMode = ThemeMode.system})
    : _themeMode = initialMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  void toggle() {
    _themeMode = switch (_themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    };
    notifyListeners();
  }
}
