class SettingsState {
  const SettingsState({
    required this.languageCode,
    required this.notificationsEnabled,
  });

  final String languageCode;
  final bool notificationsEnabled;

  SettingsState copyWith({
    String? languageCode,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
