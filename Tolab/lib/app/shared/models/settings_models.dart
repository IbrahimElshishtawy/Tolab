import 'package:flutter/material.dart';

class SettingsBundle {
  const SettingsBundle({
    required this.themeMode,
    required this.localeCode,
    required this.pushEnabled,
    required this.desktopAlertsEnabled,
    required this.auditLoggingEnabled,
    required this.sessionTimeoutMinutes,
    required this.uploadLimitMb,
  });

  final ThemeMode themeMode;
  final String localeCode;
  final bool pushEnabled;
  final bool desktopAlertsEnabled;
  final bool auditLoggingEnabled;
  final int sessionTimeoutMinutes;
  final int uploadLimitMb;

  SettingsBundle copyWith({
    ThemeMode? themeMode,
    String? localeCode,
    bool? pushEnabled,
    bool? desktopAlertsEnabled,
    bool? auditLoggingEnabled,
    int? sessionTimeoutMinutes,
    int? uploadLimitMb,
  }) {
    return SettingsBundle(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      desktopAlertsEnabled: desktopAlertsEnabled ?? this.desktopAlertsEnabled,
      auditLoggingEnabled: auditLoggingEnabled ?? this.auditLoggingEnabled,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      uploadLimitMb: uploadLimitMb ?? this.uploadLimitMb,
    );
  }
}
