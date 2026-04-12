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
    return SettingsState(
      languageCode: preferences.getString(StorageKeys.preferredLocale) ?? 'en',
      notificationsEnabled:
          preferences.getBool(StorageKeys.notificationsEnabled, fallback: true),
    );
  }

  Future<void> updateLanguage(String languageCode) async {
    await ref.read(preferencesServiceProvider).setString(
          StorageKeys.preferredLocale,
          languageCode,
        );
    state = state.copyWith(languageCode: languageCode);
  }

  Future<void> updateNotifications(bool enabled) async {
    await ref.read(preferencesServiceProvider).setBool(
          StorageKeys.notificationsEnabled,
          enabled,
        );
    state = state.copyWith(notificationsEnabled: enabled);
  }
}
