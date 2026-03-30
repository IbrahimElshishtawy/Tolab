import 'package:flutter/material.dart';

import '../../../shared/enums/load_status.dart';
import '../../../shared/models/notification_models.dart';
import '../models/settings_models.dart';
import 'settings_actions.dart';

class SettingsState {
  SettingsState({
    this.loadStatus = LoadStatus.initial,
    this.saveStatus = LoadStatus.initial,
    SettingsBundle? bundle,
    SettingsBundle? persistedBundle,
    this.selectedSection = SettingsSection.general,
    this.errorMessage,
    this.successMessage,
  }) : bundle = bundle ?? _createDefaultBundle(),
       persistedBundle = persistedBundle ?? bundle ?? _createDefaultBundle();

  final LoadStatus loadStatus;
  final LoadStatus saveStatus;
  final SettingsBundle bundle;
  final SettingsBundle persistedBundle;
  final SettingsSection selectedSection;
  final String? errorMessage;
  final String? successMessage;

  bool get hasPendingChanges => bundle != persistedBundle;

  SettingsState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? saveStatus,
    SettingsBundle? bundle,
    SettingsBundle? persistedBundle,
    SettingsSection? selectedSection,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      loadStatus: loadStatus ?? this.loadStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      bundle: bundle ?? this.bundle,
      persistedBundle: persistedBundle ?? this.persistedBundle,
      selectedSection: selectedSection ?? this.selectedSection,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}

SettingsBundle _createDefaultBundle() => SettingsBundle(
  general: const GeneralSettings(
    appName: 'Tolab Admin',
    academyName: 'Tolab Academy',
    logoUrl: '',
    timezone: 'Africa/Cairo',
    languageCode: 'en',
  ),
  theme: const ThemeSettings(
    themeMode: ThemeMode.light,
    primaryColor: Color(0xFF2563EB),
    secondaryColor: Color(0xFF0EA5E9),
    glassmorphismEnabled: true,
    cardBlurSigma: 16,
  ),
  notifications: const NotificationPreferences(
    pushEnabled: true,
    desktopAlertsEnabled: true,
    localAlertsEnabled: true,
    emailDigestEnabled: false,
    toastEnabled: true,
    soundEnabled: true,
    categories: {
      AdminNotificationCategory.academic: true,
      AdminNotificationCategory.messages: true,
      AdminNotificationCategory.system: true,
      AdminNotificationCategory.announcements: true,
    },
  ),
  security: const SecuritySettings(
    passwordPolicy: PasswordPolicy(
      minLength: 10,
      passwordExpiryDays: 90,
      requireUppercase: true,
      requireLowercase: true,
      requireNumbers: true,
      requireSpecialCharacters: true,
    ),
    sessionTimeoutMinutes: 30,
    twoFactorRequired: false,
    lockOnSuspiciousActivity: true,
    blockedAccounts: [],
  ),
  userManagement: const UserManagementSettings(
    defaultRole: 'Manager',
    allowStaffAdminAccess: true,
    requireApprovalForAdminAccess: true,
    allowRoleCloning: true,
    roleTemplates: [],
  ),
  uploadRules: const UploadRulesSettings(
    maxFileSizeMb: 250,
    allowedFileTypes: ['pdf', 'docx', 'xlsx', 'jpg', 'png', 'zip'],
    storageLocation: StorageLocation.s3,
    basePath: 'academy/uploads',
    validateMimeType: true,
    runVirusScan: true,
    renameOnUpload: false,
  ),
  calendar: const CalendarSettings(
    defaultView: CalendarViewOption.month,
    typeColors: {
      'Lecture': Color(0xFF2563EB),
      'Section': Color(0xFF16A34A),
      'Exam': Color(0xFFF59E0B),
      'Holiday': Color(0xFFEF4444),
    },
    holidays: [],
  ),
  system: const SystemSettings(
    apiBaseUrl: 'http://127.0.0.1:8000/api',
    websocketUrl: 'ws://127.0.0.1:8000/ws/admin/notifications',
    apiKeys: [],
    maintenanceMode: false,
    auditLoggingEnabled: true,
    logRetentionDays: 30,
    enableLaravelBroadcasting: true,
    integrationStatus: 'Connected',
  ),
  backupRestore: const BackupRestoreSettings(
    autoBackupEnabled: true,
    frequency: BackupFrequency.daily,
    nextBackupAt: null,
    storageTarget: 's3://tolab-backups/admin',
    retentionCount: 12,
    encryptBackups: true,
    history: [],
  ),
  updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  source: 'seed',
  isSynced: true,
);

SettingsState settingsReducer(SettingsState state, dynamic action) {
  switch (action) {
    case LoadSettingsAction():
      return action.silent
          ? state.copyWith(clearError: true)
          : state.copyWith(
              loadStatus: LoadStatus.loading,
              clearError: true,
              clearSuccess: true,
            );
    case SettingsLoadedAction():
      return state.copyWith(
        loadStatus: LoadStatus.success,
        saveStatus: LoadStatus.initial,
        bundle: action.bundle,
        persistedBundle: action.bundle,
        clearError: true,
      );
    case SettingsLoadFailedAction():
      return state.copyWith(
        loadStatus: LoadStatus.failure,
        errorMessage: action.message,
        clearSuccess: true,
      );
    case UpdateSettingsBundleAction():
      return state.copyWith(
        bundle: action.bundle,
        saveStatus: LoadStatus.initial,
        clearError: true,
      );
    case SelectSettingsSectionAction():
      return state.copyWith(selectedSection: action.section);
    case ToggleThemeModeAction():
      final nextMode = switch (state.bundle.theme.themeMode) {
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.light,
        ThemeMode.system => ThemeMode.light,
      };
      return state.copyWith(
        bundle: state.bundle.copyWith(
          theme: state.bundle.theme.copyWith(themeMode: nextMode),
        ),
        saveStatus: LoadStatus.initial,
      );
    case RevertSettingsChangesAction():
      return state.copyWith(
        bundle: state.persistedBundle,
        saveStatus: LoadStatus.initial,
        clearError: true,
        clearSuccess: true,
      );
    case SaveSettingsRequestedAction():
    case CreateSettingsBackupRequestedAction():
    case RestoreSettingsBackupRequestedAction():
      return state.copyWith(
        saveStatus: LoadStatus.loading,
        clearError: true,
        clearSuccess: true,
      );
    case SettingsSaveSucceededAction():
      return state.copyWith(
        bundle: action.result.bundle,
        persistedBundle: action.result.bundle,
        saveStatus: LoadStatus.success,
        successMessage: action.result.message,
        clearError: true,
      );
    case SettingsSaveFailedAction():
      return state.copyWith(
        saveStatus: LoadStatus.failure,
        errorMessage: action.message,
        clearSuccess: true,
      );
    default:
      return state;
  }
}
