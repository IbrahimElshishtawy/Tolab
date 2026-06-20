import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    required this.languageCode,
    required this.notificationsEnabled,
    required this.themeMode,
    required this.gender,
  });

  final String languageCode;
  final bool notificationsEnabled;
  final ThemeMode themeMode;
  final String gender;

  SettingsState copyWith({
    String? languageCode,
    bool? notificationsEnabled,
    ThemeMode? themeMode,
    String? gender,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      gender: gender ?? this.gender,
    );
  }
}
