import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    required this.languageCode,
    required this.notificationsEnabled,
    required this.themeMode,
  });

  final String languageCode;
  final bool notificationsEnabled;
  final ThemeMode themeMode;

  SettingsState copyWith({
    String? languageCode,
    bool? notificationsEnabled,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
