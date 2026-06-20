import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/mock_backend_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import 'settings_state.dart';

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final preferences = ref.watch(preferencesServiceProvider);
    final languageCode =
        preferences.getString(StorageKeys.preferredLocale) ?? 'ar';
    final gender = preferences.getString(StorageKeys.userGender) ?? 'male';

    // Apply gender on startup to the mock backend service
    ref.read(mockBackendServiceProvider).updateProfileGender(gender);

    return SettingsState(
      languageCode: languageCode == 'en' ? 'en' : 'ar',
      notificationsEnabled: preferences.getBool(
        StorageKeys.notificationsEnabled,
        fallback: true,
      ),
      themeMode: _themeModeFromStorage(
        preferences.getString(StorageKeys.themeMode),
      ),
      gender: gender,
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

  Future<void> updateGender(String gender) async {
    await ref
        .read(preferencesServiceProvider)
        .setString(StorageKeys.userGender, gender);
    ref.read(mockBackendServiceProvider).updateProfileGender(gender);
    ref.invalidate(profileProvider);
    ref.invalidate(homeDashboardProvider);
    state = state.copyWith(gender: gender);
  }

  ThemeMode _themeModeFromStorage(String? value) {
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.dark,
    };
  }
}
