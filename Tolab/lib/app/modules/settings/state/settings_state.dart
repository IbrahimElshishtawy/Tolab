import 'package:flutter/material.dart';

import '../../../shared/enums/load_status.dart';
import '../../../shared/models/settings_models.dart';

class SettingsState {
  const SettingsState({
    this.status = LoadStatus.initial,
    this.bundle = const SettingsBundle(
      themeMode: ThemeMode.light,
      localeCode: 'en',
      pushEnabled: true,
      desktopAlertsEnabled: true,
      auditLoggingEnabled: true,
      sessionTimeoutMinutes: 30,
      uploadLimitMb: 250,
    ),
  });

  final LoadStatus status;
  final SettingsBundle bundle;

  SettingsState copyWith({LoadStatus? status, SettingsBundle? bundle}) {
    return SettingsState(
      status: status ?? this.status,
      bundle: bundle ?? this.bundle,
    );
  }
}

class SettingsLoadedAction {
  SettingsLoadedAction(this.bundle);

  final SettingsBundle bundle;
}

class ToggleThemeModeAction {}

SettingsState settingsReducer(SettingsState state, dynamic action) {
  switch (action) {
    case SettingsLoadedAction():
      return state.copyWith(status: LoadStatus.success, bundle: action.bundle);
    case ToggleThemeModeAction():
      final nextMode = state.bundle.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      return state.copyWith(bundle: state.bundle.copyWith(themeMode: nextMode));
    default:
      return state;
  }
}
