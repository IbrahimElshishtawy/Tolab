import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/storage_providers.dart';
import 'settings_state.dart';

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final preferences = ref.watch(preferencesServiceProvider);
    final languageCode =
        preferences.getString(StorageKeys.preferredLocale) ?? 'ar';

    return SettingsState(
      languageCode: languageCode == 'en' ? 'en' : 'ar',
      notificationsEnabled: preferences.getBool(
        StorageKeys.notificationsEnabled,
        fallback: true,
      ),
      themeMode: _themeModeFromStorage(
        preferences.getString(StorageKeys.themeMode),
      ),
    );
  }

  Future<void> updateLanguage(String languageCode) async {
    await ref
        .read(preferencesServiceProvider)
        .setString(StorageKeys.preferredLocale, languageCode);
    state = state.copyWith(languageCode: languageCode);
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await ref
        .read(preferencesServiceProvider)
        .setString(StorageKeys.themeMode, themeMode.name);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> updateNotifications(bool enabled) async {
    await ref
        .read(preferencesServiceProvider)
        .setBool(StorageKeys.notificationsEnabled, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  ThemeMode _themeModeFromStorage(String? value) {
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.dark,
    };
  }
}
