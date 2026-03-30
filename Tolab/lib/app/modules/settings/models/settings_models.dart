import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../shared/models/notification_models.dart';

const DeepCollectionEquality _deepEquality = DeepCollectionEquality();

enum SettingsSection {
  general,
  theme,
  notifications,
  security,
  userManagement,
  uploadRules,
  calendar,
  system,
  backupRestore,
}

enum StorageLocation { local, s3, cloudinary, privateServer }

enum CalendarViewOption { month, week, day }

enum BackupFrequency { daily, weekly, monthly }

enum SettingsSyncState { synced, localOnly }

extension SettingsSectionX on SettingsSection {
  String get label => switch (this) {
    SettingsSection.general => 'General',
    SettingsSection.theme => 'Theme',
    SettingsSection.notifications => 'Notifications',
    SettingsSection.security => 'Security',
    SettingsSection.userManagement => 'User Management',
    SettingsSection.uploadRules => 'Upload Rules',
    SettingsSection.calendar => 'Calendar',
    SettingsSection.system => 'System',
    SettingsSection.backupRestore => 'Backup & Restore',
  };

  String get subtitle => switch (this) {
    SettingsSection.general =>
      'Branding, language, timezone, and academy identity.',
    SettingsSection.theme =>
      'Appearance, accent colors, and live macOS-style glass surfaces.',
    SettingsSection.notifications =>
      'Realtime delivery, badges, categories, and alert preferences.',
    SettingsSection.security =>
      'Password policy, timeouts, two-factor auth, and blocked accounts.',
    SettingsSection.userManagement =>
      'Default roles, access scopes, and administrative permissions.',
    SettingsSection.uploadRules =>
      'Validation rules, allowed formats, storage, and size limits.',
    SettingsSection.calendar =>
      'Views, event colors, and academic holidays.',
    SettingsSection.system =>
      'Laravel integration, API credentials, logs, and maintenance mode.',
    SettingsSection.backupRestore =>
      'Backups, restore points, retention, and scheduling.',
  };

  IconData get icon => switch (this) {
    SettingsSection.general => Icons.apps_rounded,
    SettingsSection.theme => Icons.palette_rounded,
    SettingsSection.notifications => Icons.notifications_active_rounded,
    SettingsSection.security => Icons.lock_rounded,
    SettingsSection.userManagement => Icons.admin_panel_settings_rounded,
    SettingsSection.uploadRules => Icons.cloud_upload_rounded,
    SettingsSection.calendar => Icons.calendar_month_rounded,
    SettingsSection.system => Icons.settings_suggest_rounded,
    SettingsSection.backupRestore => Icons.backup_rounded,
  };
}

extension StorageLocationX on StorageLocation {
  String get label => switch (this) {
    StorageLocation.local => 'Local storage',
    StorageLocation.s3 => 'Amazon S3',
    StorageLocation.cloudinary => 'Cloudinary',
    StorageLocation.privateServer => 'Private server',
  };

  String get backendValue => switch (this) {
    StorageLocation.local => 'local',
    StorageLocation.s3 => 's3',
    StorageLocation.cloudinary => 'cloudinary',
    StorageLocation.privateServer => 'private_server',
  };
}

extension CalendarViewOptionX on CalendarViewOption {
  String get label => switch (this) {
    CalendarViewOption.month => 'Month',
    CalendarViewOption.week => 'Week',
    CalendarViewOption.day => 'Day',
  };
}

extension BackupFrequencyX on BackupFrequency {
  String get label => switch (this) {
    BackupFrequency.daily => 'Daily',
    BackupFrequency.weekly => 'Weekly',
    BackupFrequency.monthly => 'Monthly',
  };

  int get days => switch (this) {
    BackupFrequency.daily => 1,
    BackupFrequency.weekly => 7,
    BackupFrequency.monthly => 30,
  };
}

class GeneralSettings {
  const GeneralSettings({
    required this.appName,
    required this.academyName,
    required this.logoUrl,
    required this.timezone,
    required this.languageCode,
  });

  final String appName;
  final String academyName;
  final String logoUrl;
  final String timezone;
  final String languageCode;

  GeneralSettings copyWith({
    String? appName,
    String? academyName,
    String? logoUrl,
    String? timezone,
    String? languageCode,
  }) {
    return GeneralSettings(
      appName: appName ?? this.appName,
      academyName: academyName ?? this.academyName,
      logoUrl: logoUrl ?? this.logoUrl,
      timezone: timezone ?? this.timezone,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'app_name': appName,
    'academy_name': academyName,
    'logo_url': logoUrl,
    'timezone': timezone,
    'language_code': languageCode,
  };

  static GeneralSettings fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      appName: _readString(json, ['app_name', 'appName'], fallback: 'Tolab Admin'),
      academyName: _readString(
        json,
        ['academy_name', 'academyName'],
        fallback: 'Tolab Academy',
      ),
      logoUrl: _readString(json, ['logo_url', 'logoUrl']),
      timezone: _readString(
        json,
        ['timezone', 'time_zone'],
        fallback: 'Africa/Cairo',
      ),
      languageCode: _readString(
        json,
        ['language_code', 'language', 'locale'],
        fallback: 'en',
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GeneralSettings &&
        other.appName == appName &&
        other.academyName == academyName &&
        other.logoUrl == logoUrl &&
        other.timezone == timezone &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode => Object.hash(
    appName,
    academyName,
    logoUrl,
    timezone,
    languageCode,
  );
}

class ThemeSettings {
  const ThemeSettings({
    required this.themeMode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.glassmorphismEnabled,
    required this.cardBlurSigma,
  });

  final ThemeMode themeMode;
  final Color primaryColor;
  final Color secondaryColor;
  final bool glassmorphismEnabled;
  final double cardBlurSigma;

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    Color? secondaryColor,
    bool? glassmorphismEnabled,
    double? cardBlurSigma,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      glassmorphismEnabled: glassmorphismEnabled ?? this.glassmorphismEnabled,
      cardBlurSigma: cardBlurSigma ?? this.cardBlurSigma,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme_mode': themeMode.name,
    'primary_color': _colorToHex(primaryColor),
    'secondary_color': _colorToHex(secondaryColor),
    'glassmorphism_enabled': glassmorphismEnabled,
    'card_blur_sigma': cardBlurSigma,
  };

  static ThemeSettings fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: _parseThemeMode(
        _readString(json, ['theme_mode', 'themeMode'], fallback: 'light'),
      ),
      primaryColor: _parseColor(
        json['primary_color'] ?? json['primaryColor'],
        fallback: const Color(0xFF2563EB),
      ),
      secondaryColor: _parseColor(
        json['secondary_color'] ?? json['secondaryColor'],
        fallback: const Color(0xFF0EA5E9),
      ),
      glassmorphismEnabled: _readBool(
        json,
        ['glassmorphism_enabled', 'glassmorphismEnabled'],
        fallback: true,
      ),
      cardBlurSigma: _readDouble(
        json,
        ['card_blur_sigma', 'cardBlurSigma'],
        fallback: 16,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeSettings &&
        other.themeMode == themeMode &&
        other.primaryColor.value == primaryColor.value &&
        other.secondaryColor.value == secondaryColor.value &&
        other.glassmorphismEnabled == glassmorphismEnabled &&
        other.cardBlurSigma == cardBlurSigma;
  }

  @override
  int get hashCode => Object.hash(
    themeMode,
    primaryColor.value,
    secondaryColor.value,
    glassmorphismEnabled,
    cardBlurSigma,
  );
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.pushEnabled,
    required this.desktopAlertsEnabled,
    required this.localAlertsEnabled,
    required this.emailDigestEnabled,
    required this.toastEnabled,
    required this.soundEnabled,
    required this.categories,
  });

  final bool pushEnabled;
  final bool desktopAlertsEnabled;
  final bool localAlertsEnabled;
  final bool emailDigestEnabled;
  final bool toastEnabled;
  final bool soundEnabled;
  final Map<AdminNotificationCategory, bool> categories;

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? desktopAlertsEnabled,
    bool? localAlertsEnabled,
    bool? emailDigestEnabled,
    bool? toastEnabled,
    bool? soundEnabled,
    Map<AdminNotificationCategory, bool>? categories,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      desktopAlertsEnabled: desktopAlertsEnabled ?? this.desktopAlertsEnabled,
      localAlertsEnabled: localAlertsEnabled ?? this.localAlertsEnabled,
      emailDigestEnabled: emailDigestEnabled ?? this.emailDigestEnabled,
      toastEnabled: toastEnabled ?? this.toastEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      categories: categories ?? this.categories,
    );
  }

  bool isEnabledFor(AdminNotificationCategory category) =>
      categories[category] ?? true;

  Map<String, dynamic> toJson() => {
    'push_enabled': pushEnabled,
    'desktop_alerts_enabled': desktopAlertsEnabled,
    'local_alerts_enabled': localAlertsEnabled,
    'email_digest_enabled': emailDigestEnabled,
    'toast_enabled': toastEnabled,
    'sound_enabled': soundEnabled,
    'categories': {
      for (final entry in categories.entries) entry.key.name: entry.value,
    },
  };

  static NotificationPreferences fromJson(Map<String, dynamic> json) {
    final categoryMap = <AdminNotificationCategory, bool>{
      for (final category in AdminNotificationCategory.values) category: true,
    };
    final rawCategories = _asMap(json['categories']);
    for (final entry in rawCategories.entries) {
      final category = _notificationCategoryFromString(entry.key);
      if (category == null) continue;
      categoryMap[category] = _parseBool(entry.value, fallback: true);
    }

    return NotificationPreferences(
      pushEnabled: _readBool(json, ['push_enabled', 'pushEnabled'], fallback: true),
      desktopAlertsEnabled: _readBool(
        json,
        ['desktop_alerts_enabled', 'desktopAlertsEnabled'],
        fallback: true,
      ),
      localAlertsEnabled: _readBool(
        json,
        ['local_alerts_enabled', 'localAlertsEnabled'],
        fallback: true,
      ),
      emailDigestEnabled: _readBool(
        json,
        ['email_digest_enabled', 'emailDigestEnabled'],
      ),
      toastEnabled: _readBool(
        json,
        ['toast_enabled', 'toastEnabled'],
        fallback: true,
      ),
      soundEnabled: _readBool(
        json,
        ['sound_enabled', 'soundEnabled'],
        fallback: true,
      ),
      categories: Map<AdminNotificationCategory, bool>.unmodifiable(categoryMap),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationPreferences &&
        other.pushEnabled == pushEnabled &&
        other.desktopAlertsEnabled == desktopAlertsEnabled &&
        other.localAlertsEnabled == localAlertsEnabled &&
        other.emailDigestEnabled == emailDigestEnabled &&
        other.toastEnabled == toastEnabled &&
        other.soundEnabled == soundEnabled &&
        _deepEquality.equals(other.categories, categories);
  }

  @override
  int get hashCode => Object.hash(
    pushEnabled,
    desktopAlertsEnabled,
    localAlertsEnabled,
    emailDigestEnabled,
    toastEnabled,
    soundEnabled,
    _deepEquality.hash(categories),
  );
}

class PasswordPolicy {
  const PasswordPolicy({
    required this.minLength,
    required this.passwordExpiryDays,
    required this.requireUppercase,
    required this.requireLowercase,
    required this.requireNumbers,
    required this.requireSpecialCharacters,
  });

  final int minLength;
  final int passwordExpiryDays;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialCharacters;

  PasswordPolicy copyWith({
    int? minLength,
    int? passwordExpiryDays,
    bool? requireUppercase,
    bool? requireLowercase,
    bool? requireNumbers,
    bool? requireSpecialCharacters,
  }) {
    return PasswordPolicy(
      minLength: minLength ?? this.minLength,
      passwordExpiryDays: passwordExpiryDays ?? this.passwordExpiryDays,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireLowercase: requireLowercase ?? this.requireLowercase,
      requireNumbers: requireNumbers ?? this.requireNumbers,
      requireSpecialCharacters:
          requireSpecialCharacters ?? this.requireSpecialCharacters,
    );
  }

  Map<String, dynamic> toJson() => {
    'min_length': minLength,
    'password_expiry_days': passwordExpiryDays,
    'require_uppercase': requireUppercase,
    'require_lowercase': requireLowercase,
    'require_numbers': requireNumbers,
    'require_special_characters': requireSpecialCharacters,
  };

  static PasswordPolicy fromJson(Map<String, dynamic> json) {
    return PasswordPolicy(
      minLength: _readInt(json, ['min_length', 'minLength'], fallback: 10),
      passwordExpiryDays: _readInt(
        json,
        ['password_expiry_days', 'passwordExpiryDays'],
        fallback: 90,
      ),
      requireUppercase: _readBool(
        json,
        ['require_uppercase', 'requireUppercase'],
        fallback: true,
      ),
      requireLowercase: _readBool(
        json,
        ['require_lowercase', 'requireLowercase'],
        fallback: true,
      ),
      requireNumbers: _readBool(
        json,
        ['require_numbers', 'requireNumbers'],
        fallback: true,
      ),
      requireSpecialCharacters: _readBool(
        json,
        ['require_special_characters', 'requireSpecialCharacters'],
        fallback: true,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PasswordPolicy &&
        other.minLength == minLength &&
        other.passwordExpiryDays == passwordExpiryDays &&
        other.requireUppercase == requireUppercase &&
        other.requireLowercase == requireLowercase &&
        other.requireNumbers == requireNumbers &&
        other.requireSpecialCharacters == requireSpecialCharacters;
  }

  @override
  int get hashCode => Object.hash(
    minLength,
    passwordExpiryDays,
    requireUppercase,
    requireLowercase,
    requireNumbers,
    requireSpecialCharacters,
  );
}

class BlockedAccount {
  const BlockedAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.reason,
    required this.blockedAt,
    required this.isTemporary,
  });

  final String id;
  final String name;
  final String email;
  final String reason;
  final DateTime blockedAt;
  final bool isTemporary;

  BlockedAccount copyWith({
    String? id,
    String? name,
    String? email,
    String? reason,
    DateTime? blockedAt,
    bool? isTemporary,
  }) {
    return BlockedAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      reason: reason ?? this.reason,
      blockedAt: blockedAt ?? this.blockedAt,
      isTemporary: isTemporary ?? this.isTemporary,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'reason': reason,
    'blocked_at': blockedAt.toIso8601String(),
    'is_temporary': isTemporary,
  };

  static BlockedAccount fromJson(Map<String, dynamic> json) {
    return BlockedAccount(
      id: _readString(json, ['id'], fallback: 'blocked-account'),
      name: _readString(json, ['name'], fallback: 'Blocked user'),
      email: _readString(json, ['email'], fallback: 'user@tolab.edu'),
      reason: _readString(json, ['reason'], fallback: 'Manual block'),
      blockedAt: _parseDateTime(json['blocked_at'] ?? json['blockedAt']),
      isTemporary: _readBool(
        json,
        ['is_temporary', 'isTemporary'],
        fallback: false,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BlockedAccount &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.reason == reason &&
        other.blockedAt == blockedAt &&
        other.isTemporary == isTemporary;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    reason,
    blockedAt,
    isTemporary,
  );
}

class SecuritySettings {
  const SecuritySettings({
    required this.passwordPolicy,
    required this.sessionTimeoutMinutes,
    required this.twoFactorRequired,
    required this.lockOnSuspiciousActivity,
    required this.blockedAccounts,
  });

  final PasswordPolicy passwordPolicy;
  final int sessionTimeoutMinutes;
  final bool twoFactorRequired;
  final bool lockOnSuspiciousActivity;
  final List<BlockedAccount> blockedAccounts;

  SecuritySettings copyWith({
    PasswordPolicy? passwordPolicy,
    int? sessionTimeoutMinutes,
    bool? twoFactorRequired,
    bool? lockOnSuspiciousActivity,
    List<BlockedAccount>? blockedAccounts,
  }) {
    return SecuritySettings(
      passwordPolicy: passwordPolicy ?? this.passwordPolicy,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      twoFactorRequired: twoFactorRequired ?? this.twoFactorRequired,
      lockOnSuspiciousActivity:
          lockOnSuspiciousActivity ?? this.lockOnSuspiciousActivity,
      blockedAccounts: blockedAccounts ?? this.blockedAccounts,
    );
  }

  Map<String, dynamic> toJson() => {
    'password_policy': passwordPolicy.toJson(),
    'session_timeout_minutes': sessionTimeoutMinutes,
    'two_factor_required': twoFactorRequired,
    'lock_on_suspicious_activity': lockOnSuspiciousActivity,
    'blocked_accounts': [
      for (final account in blockedAccounts) account.toJson(),
    ],
  };

  static SecuritySettings fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      passwordPolicy: PasswordPolicy.fromJson(
        _asMap(json['password_policy'] ?? json['passwordPolicy']),
      ),
      sessionTimeoutMinutes: _readInt(
        json,
        ['session_timeout_minutes', 'sessionTimeoutMinutes'],
        fallback: 30,
      ),
      twoFactorRequired: _readBool(
        json,
        ['two_factor_required', 'twoFactorRequired'],
      ),
      lockOnSuspiciousActivity: _readBool(
        json,
        ['lock_on_suspicious_activity', 'lockOnSuspiciousActivity'],
        fallback: true,
      ),
      blockedAccounts: _asList(json['blocked_accounts'] ?? json['blockedAccounts'])
          .map((item) => BlockedAccount.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SecuritySettings &&
        other.passwordPolicy == passwordPolicy &&
        other.sessionTimeoutMinutes == sessionTimeoutMinutes &&
        other.twoFactorRequired == twoFactorRequired &&
        other.lockOnSuspiciousActivity == lockOnSuspiciousActivity &&
        _deepEquality.equals(other.blockedAccounts, blockedAccounts);
  }

  @override
  int get hashCode => Object.hash(
    passwordPolicy,
    sessionTimeoutMinutes,
    twoFactorRequired,
    lockOnSuspiciousActivity,
    _deepEquality.hash(blockedAccounts),
  );
}

class RolePermissionTemplate {
  const RolePermissionTemplate({
    required this.id,
    required this.name,
    required this.adminAccess,
    required this.staffAccess,
    required this.permissions,
  });

  final String id;
  final String name;
  final bool adminAccess;
  final bool staffAccess;
  final Map<String, bool> permissions;

  RolePermissionTemplate copyWith({
    String? id,
    String? name,
    bool? adminAccess,
    bool? staffAccess,
    Map<String, bool>? permissions,
  }) {
    return RolePermissionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      adminAccess: adminAccess ?? this.adminAccess,
      staffAccess: staffAccess ?? this.staffAccess,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'admin_access': adminAccess,
    'staff_access': staffAccess,
    'permissions': permissions,
  };

  static RolePermissionTemplate fromJson(Map<String, dynamic> json) {
    final permissions = <String, bool>{};
    final rawPermissions = _asMap(json['permissions']);
    for (final entry in rawPermissions.entries) {
      permissions[entry.key] = _parseBool(entry.value, fallback: false);
    }

    return RolePermissionTemplate(
      id: _readString(json, ['id'], fallback: 'role-template'),
      name: _readString(json, ['name'], fallback: 'Role'),
      adminAccess: _readBool(
        json,
        ['admin_access', 'adminAccess'],
        fallback: true,
      ),
      staffAccess: _readBool(
        json,
        ['staff_access', 'staffAccess'],
        fallback: true,
      ),
      permissions: Map<String, bool>.unmodifiable(permissions),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RolePermissionTemplate &&
        other.id == id &&
        other.name == name &&
        other.adminAccess == adminAccess &&
        other.staffAccess == staffAccess &&
        _deepEquality.equals(other.permissions, permissions);
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    adminAccess,
    staffAccess,
    _deepEquality.hash(permissions),
  );
}

class UserManagementSettings {
  const UserManagementSettings({
    required this.defaultRole,
    required this.allowStaffAdminAccess,
    required this.requireApprovalForAdminAccess,
    required this.allowRoleCloning,
    required this.roleTemplates,
  });

  final String defaultRole;
  final bool allowStaffAdminAccess;
  final bool requireApprovalForAdminAccess;
  final bool allowRoleCloning;
  final List<RolePermissionTemplate> roleTemplates;

  UserManagementSettings copyWith({
    String? defaultRole,
    bool? allowStaffAdminAccess,
    bool? requireApprovalForAdminAccess,
    bool? allowRoleCloning,
    List<RolePermissionTemplate>? roleTemplates,
  }) {
    return UserManagementSettings(
      defaultRole: defaultRole ?? this.defaultRole,
      allowStaffAdminAccess: allowStaffAdminAccess ?? this.allowStaffAdminAccess,
      requireApprovalForAdminAccess:
          requireApprovalForAdminAccess ?? this.requireApprovalForAdminAccess,
      allowRoleCloning: allowRoleCloning ?? this.allowRoleCloning,
      roleTemplates: roleTemplates ?? this.roleTemplates,
    );
  }

  Map<String, dynamic> toJson() => {
    'default_role': defaultRole,
    'allow_staff_admin_access': allowStaffAdminAccess,
    'require_approval_for_admin_access': requireApprovalForAdminAccess,
    'allow_role_cloning': allowRoleCloning,
    'role_templates': [
      for (final template in roleTemplates) template.toJson(),
    ],
  };

  static UserManagementSettings fromJson(Map<String, dynamic> json) {
    return UserManagementSettings(
      defaultRole: _readString(json, ['default_role', 'defaultRole'], fallback: 'Manager'),
      allowStaffAdminAccess: _readBool(
        json,
        ['allow_staff_admin_access', 'allowStaffAdminAccess'],
        fallback: true,
      ),
      requireApprovalForAdminAccess: _readBool(
        json,
        ['require_approval_for_admin_access', 'requireApprovalForAdminAccess'],
        fallback: true,
      ),
      allowRoleCloning: _readBool(
        json,
        ['allow_role_cloning', 'allowRoleCloning'],
        fallback: true,
      ),
      roleTemplates: _asList(json['role_templates'] ?? json['roleTemplates'])
          .map((item) => RolePermissionTemplate.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserManagementSettings &&
        other.defaultRole == defaultRole &&
        other.allowStaffAdminAccess == allowStaffAdminAccess &&
        other.requireApprovalForAdminAccess ==
            requireApprovalForAdminAccess &&
        other.allowRoleCloning == allowRoleCloning &&
        _deepEquality.equals(other.roleTemplates, roleTemplates);
  }

  @override
  int get hashCode => Object.hash(
    defaultRole,
    allowStaffAdminAccess,
    requireApprovalForAdminAccess,
    allowRoleCloning,
    _deepEquality.hash(roleTemplates),
  );
}

class UploadRulesSettings {
  const UploadRulesSettings({
    required this.maxFileSizeMb,
    required this.allowedFileTypes,
    required this.storageLocation,
    required this.basePath,
    required this.validateMimeType,
    required this.runVirusScan,
    required this.renameOnUpload,
  });

  final int maxFileSizeMb;
  final List<String> allowedFileTypes;
  final StorageLocation storageLocation;
  final String basePath;
  final bool validateMimeType;
  final bool runVirusScan;
  final bool renameOnUpload;

  UploadRulesSettings copyWith({
    int? maxFileSizeMb,
    List<String>? allowedFileTypes,
    StorageLocation? storageLocation,
    String? basePath,
    bool? validateMimeType,
    bool? runVirusScan,
    bool? renameOnUpload,
  }) {
    return UploadRulesSettings(
      maxFileSizeMb: maxFileSizeMb ?? this.maxFileSizeMb,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      storageLocation: storageLocation ?? this.storageLocation,
      basePath: basePath ?? this.basePath,
      validateMimeType: validateMimeType ?? this.validateMimeType,
      runVirusScan: runVirusScan ?? this.runVirusScan,
      renameOnUpload: renameOnUpload ?? this.renameOnUpload,
    );
  }

  Map<String, dynamic> toJson() => {
    'max_file_size_mb': maxFileSizeMb,
    'allowed_file_types': allowedFileTypes,
    'storage_location': storageLocation.backendValue,
    'base_path': basePath,
    'validate_mime_type': validateMimeType,
    'run_virus_scan': runVirusScan,
    'rename_on_upload': renameOnUpload,
  };

  static UploadRulesSettings fromJson(Map<String, dynamic> json) {
    return UploadRulesSettings(
      maxFileSizeMb: _readInt(
        json,
        ['max_file_size_mb', 'maxFileSizeMb', 'upload_limit_mb'],
        fallback: 250,
      ),
      allowedFileTypes: _asList(
        json['allowed_file_types'] ?? json['allowedFileTypes'],
      ).map((item) => item.toString()).toList(growable: false),
      storageLocation: _parseStorageLocation(
        _readString(
          json,
          ['storage_location', 'storageLocation'],
          fallback: 's3',
        ),
      ),
      basePath: _readString(
        json,
        ['base_path', 'basePath'],
        fallback: 'academy/uploads',
      ),
      validateMimeType: _readBool(
        json,
        ['validate_mime_type', 'validateMimeType'],
        fallback: true,
      ),
      runVirusScan: _readBool(
        json,
        ['run_virus_scan', 'runVirusScan'],
        fallback: true,
      ),
      renameOnUpload: _readBool(
        json,
        ['rename_on_upload', 'renameOnUpload'],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UploadRulesSettings &&
        other.maxFileSizeMb == maxFileSizeMb &&
        _deepEquality.equals(other.allowedFileTypes, allowedFileTypes) &&
        other.storageLocation == storageLocation &&
        other.basePath == basePath &&
        other.validateMimeType == validateMimeType &&
        other.runVirusScan == runVirusScan &&
        other.renameOnUpload == renameOnUpload;
  }

  @override
  int get hashCode => Object.hash(
    maxFileSizeMb,
    _deepEquality.hash(allowedFileTypes),
    storageLocation,
    basePath,
    validateMimeType,
    runVirusScan,
    renameOnUpload,
  );
}

class HolidayItem {
  const HolidayItem({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
  });

  final String id;
  final String name;
  final DateTime date;
  final String type;

  HolidayItem copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? type,
  }) {
    return HolidayItem(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'type': type,
  };

  static HolidayItem fromJson(Map<String, dynamic> json) {
    return HolidayItem(
      id: _readString(json, ['id'], fallback: 'holiday'),
      name: _readString(json, ['name'], fallback: 'Holiday'),
      date: _parseDateTime(json['date']),
      type: _readString(json, ['type'], fallback: 'Academic'),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HolidayItem &&
        other.id == id &&
        other.name == name &&
        other.date == date &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, name, date, type);
}

class CalendarSettings {
  const CalendarSettings({
    required this.defaultView,
    required this.typeColors,
    required this.holidays,
  });

  final CalendarViewOption defaultView;
  final Map<String, Color> typeColors;
  final List<HolidayItem> holidays;

  CalendarSettings copyWith({
    CalendarViewOption? defaultView,
    Map<String, Color>? typeColors,
    List<HolidayItem>? holidays,
  }) {
    return CalendarSettings(
      defaultView: defaultView ?? this.defaultView,
      typeColors: typeColors ?? this.typeColors,
      holidays: holidays ?? this.holidays,
    );
  }

  Map<String, dynamic> toJson() => {
    'default_view': defaultView.name,
    'type_colors': {
      for (final entry in typeColors.entries) entry.key: _colorToHex(entry.value),
    },
    'holidays': [for (final holiday in holidays) holiday.toJson()],
  };

  static CalendarSettings fromJson(Map<String, dynamic> json) {
    final colors = <String, Color>{
      'Lecture': const Color(0xFF2563EB),
      'Section': const Color(0xFF16A34A),
      'Exam': const Color(0xFFF59E0B),
      'Holiday': const Color(0xFFEF4444),
    };
    final rawColors = _asMap(json['type_colors'] ?? json['typeColors']);
    for (final entry in rawColors.entries) {
      colors[entry.key] = _parseColor(entry.value, fallback: colors[entry.key]!);
    }

    return CalendarSettings(
      defaultView: _parseCalendarView(
        _readString(json, ['default_view', 'defaultView'], fallback: 'month'),
      ),
      typeColors: Map<String, Color>.unmodifiable(colors),
      holidays: _asList(json['holidays'])
          .map((item) => HolidayItem.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarSettings &&
        other.defaultView == defaultView &&
        _deepEquality.equals(
          other.typeColors.map((key, value) => MapEntry(key, value.value)),
          typeColors.map((key, value) => MapEntry(key, value.value)),
        ) &&
        _deepEquality.equals(other.holidays, holidays);
  }

  @override
  int get hashCode => Object.hash(
    defaultView,
    _deepEquality.hash(typeColors.map((key, value) => MapEntry(key, value.value))),
    _deepEquality.hash(holidays),
  );
}

class ApiCredential {
  const ApiCredential({
    required this.id,
    required this.label,
    required this.valueMasked,
    required this.scope,
    required this.lastRotatedAt,
    required this.isEnabled,
  });

  final String id;
  final String label;
  final String valueMasked;
  final String scope;
  final DateTime lastRotatedAt;
  final bool isEnabled;

  ApiCredential copyWith({
    String? id,
    String? label,
    String? valueMasked,
    String? scope,
    DateTime? lastRotatedAt,
    bool? isEnabled,
  }) {
    return ApiCredential(
      id: id ?? this.id,
      label: label ?? this.label,
      valueMasked: valueMasked ?? this.valueMasked,
      scope: scope ?? this.scope,
      lastRotatedAt: lastRotatedAt ?? this.lastRotatedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'value_masked': valueMasked,
    'scope': scope,
    'last_rotated_at': lastRotatedAt.toIso8601String(),
    'is_enabled': isEnabled,
  };

  static ApiCredential fromJson(Map<String, dynamic> json) {
    return ApiCredential(
      id: _readString(json, ['id'], fallback: 'credential'),
      label: _readString(json, ['label', 'name'], fallback: 'API key'),
      valueMasked: _readString(
        json,
        ['value_masked', 'valueMasked', 'token'],
        fallback: 'sk-live-****',
      ),
      scope: _readString(json, ['scope'], fallback: 'system'),
      lastRotatedAt: _parseDateTime(
        json['last_rotated_at'] ?? json['lastRotatedAt'],
      ),
      isEnabled: _readBool(
        json,
        ['is_enabled', 'isEnabled'],
        fallback: true,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ApiCredential &&
        other.id == id &&
        other.label == label &&
        other.valueMasked == valueMasked &&
        other.scope == scope &&
        other.lastRotatedAt == lastRotatedAt &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    valueMasked,
    scope,
    lastRotatedAt,
    isEnabled,
  );
}

class SystemSettings {
  const SystemSettings({
    required this.apiBaseUrl,
    required this.websocketUrl,
    required this.apiKeys,
    required this.maintenanceMode,
    required this.auditLoggingEnabled,
    required this.logRetentionDays,
    required this.enableLaravelBroadcasting,
    required this.integrationStatus,
  });

  final String apiBaseUrl;
  final String websocketUrl;
  final List<ApiCredential> apiKeys;
  final bool maintenanceMode;
  final bool auditLoggingEnabled;
  final int logRetentionDays;
  final bool enableLaravelBroadcasting;
  final String integrationStatus;

  SystemSettings copyWith({
    String? apiBaseUrl,
    String? websocketUrl,
    List<ApiCredential>? apiKeys,
    bool? maintenanceMode,
    bool? auditLoggingEnabled,
    int? logRetentionDays,
    bool? enableLaravelBroadcasting,
    String? integrationStatus,
  }) {
    return SystemSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      websocketUrl: websocketUrl ?? this.websocketUrl,
      apiKeys: apiKeys ?? this.apiKeys,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      auditLoggingEnabled: auditLoggingEnabled ?? this.auditLoggingEnabled,
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
      enableLaravelBroadcasting:
          enableLaravelBroadcasting ?? this.enableLaravelBroadcasting,
      integrationStatus: integrationStatus ?? this.integrationStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'api_base_url': apiBaseUrl,
    'websocket_url': websocketUrl,
    'api_keys': [for (final key in apiKeys) key.toJson()],
    'maintenance_mode': maintenanceMode,
    'audit_logging_enabled': auditLoggingEnabled,
    'log_retention_days': logRetentionDays,
    'enable_laravel_broadcasting': enableLaravelBroadcasting,
    'integration_status': integrationStatus,
  };

  static SystemSettings fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      apiBaseUrl: _readString(
        json,
        ['api_base_url', 'apiBaseUrl'],
        fallback: 'http://127.0.0.1:8000/api',
      ),
      websocketUrl: _readString(
        json,
        ['websocket_url', 'websocketUrl'],
        fallback: 'ws://127.0.0.1:8000/ws/admin/notifications',
      ),
      apiKeys: _asList(json['api_keys'] ?? json['apiKeys'])
          .map((item) => ApiCredential.fromJson(_asMap(item)))
          .toList(growable: false),
      maintenanceMode: _readBool(
        json,
        ['maintenance_mode', 'maintenanceMode'],
      ),
      auditLoggingEnabled: _readBool(
        json,
        ['audit_logging_enabled', 'auditLoggingEnabled'],
        fallback: true,
      ),
      logRetentionDays: _readInt(
        json,
        ['log_retention_days', 'logRetentionDays'],
        fallback: 30,
      ),
      enableLaravelBroadcasting: _readBool(
        json,
        ['enable_laravel_broadcasting', 'enableLaravelBroadcasting'],
        fallback: true,
      ),
      integrationStatus: _readString(
        json,
        ['integration_status', 'integrationStatus'],
        fallback: 'Connected',
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SystemSettings &&
        other.apiBaseUrl == apiBaseUrl &&
        other.websocketUrl == websocketUrl &&
        _deepEquality.equals(other.apiKeys, apiKeys) &&
        other.maintenanceMode == maintenanceMode &&
        other.auditLoggingEnabled == auditLoggingEnabled &&
        other.logRetentionDays == logRetentionDays &&
        other.enableLaravelBroadcasting == enableLaravelBroadcasting &&
        other.integrationStatus == integrationStatus;
  }

  @override
  int get hashCode => Object.hash(
    apiBaseUrl,
    websocketUrl,
    _deepEquality.hash(apiKeys),
    maintenanceMode,
    auditLoggingEnabled,
    logRetentionDays,
    enableLaravelBroadcasting,
    integrationStatus,
  );
}

class BackupSnapshot {
  const BackupSnapshot({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.sizeLabel,
    required this.status,
    required this.source,
    required this.restorable,
    this.snapshotPayload,
  });

  final String id;
  final String label;
  final DateTime createdAt;
  final String sizeLabel;
  final String status;
  final String source;
  final bool restorable;
  final Map<String, dynamic>? snapshotPayload;

  BackupSnapshot copyWith({
    String? id,
    String? label,
    DateTime? createdAt,
    String? sizeLabel,
    String? status,
    String? source,
    bool? restorable,
    Map<String, dynamic>? snapshotPayload,
    bool clearSnapshotPayload = false,
  }) {
    return BackupSnapshot(
      id: id ?? this.id,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      status: status ?? this.status,
      source: source ?? this.source,
      restorable: restorable ?? this.restorable,
      snapshotPayload: clearSnapshotPayload
          ? null
          : snapshotPayload ?? this.snapshotPayload,
    );
  }

  Map<String, dynamic> toJson({bool includePayload = true}) => {
    'id': id,
    'label': label,
    'created_at': createdAt.toIso8601String(),
    'size_label': sizeLabel,
    'status': status,
    'source': source,
    'restorable': restorable,
    if (includePayload && snapshotPayload != null) 'snapshot_payload': snapshotPayload,
  };

  static BackupSnapshot fromJson(Map<String, dynamic> json) {
    return BackupSnapshot(
      id: _readString(json, ['id'], fallback: 'backup'),
      label: _readString(json, ['label', 'name'], fallback: 'Backup'),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      sizeLabel: _readString(
        json,
        ['size_label', 'sizeLabel'],
        fallback: '0 MB',
      ),
      status: _readString(json, ['status'], fallback: 'Ready'),
      source: _readString(json, ['source'], fallback: 'local'),
      restorable: _readBool(json, ['restorable'], fallback: true),
      snapshotPayload: _asMapOrNull(
        json['snapshot_payload'] ?? json['snapshotPayload'],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BackupSnapshot &&
        other.id == id &&
        other.label == label &&
        other.createdAt == createdAt &&
        other.sizeLabel == sizeLabel &&
        other.status == status &&
        other.source == source &&
        other.restorable == restorable &&
        _deepEquality.equals(other.snapshotPayload, snapshotPayload);
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    createdAt,
    sizeLabel,
    status,
    source,
    restorable,
    _deepEquality.hash(snapshotPayload),
  );
}

class BackupRestoreSettings {
  const BackupRestoreSettings({
    required this.autoBackupEnabled,
    required this.frequency,
    required this.nextBackupAt,
    required this.storageTarget,
    required this.retentionCount,
    required this.encryptBackups,
    required this.history,
  });

  final bool autoBackupEnabled;
  final BackupFrequency frequency;
  final DateTime? nextBackupAt;
  final String storageTarget;
  final int retentionCount;
  final bool encryptBackups;
  final List<BackupSnapshot> history;

  BackupRestoreSettings copyWith({
    bool? autoBackupEnabled,
    BackupFrequency? frequency,
    DateTime? nextBackupAt,
    String? storageTarget,
    int? retentionCount,
    bool? encryptBackups,
    List<BackupSnapshot>? history,
    bool clearNextBackupAt = false,
  }) {
    return BackupRestoreSettings(
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      frequency: frequency ?? this.frequency,
      nextBackupAt: clearNextBackupAt ? null : nextBackupAt ?? this.nextBackupAt,
      storageTarget: storageTarget ?? this.storageTarget,
      retentionCount: retentionCount ?? this.retentionCount,
      encryptBackups: encryptBackups ?? this.encryptBackups,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toJson({bool includeBackupPayloads = true}) => {
    'auto_backup_enabled': autoBackupEnabled,
    'frequency': frequency.name,
    'next_backup_at': nextBackupAt?.toIso8601String(),
    'storage_target': storageTarget,
    'retention_count': retentionCount,
    'encrypt_backups': encryptBackups,
    'history': [
      for (final backup in history)
        backup.toJson(includePayload: includeBackupPayloads),
    ],
  };

  static BackupRestoreSettings fromJson(Map<String, dynamic> json) {
    return BackupRestoreSettings(
      autoBackupEnabled: _readBool(
        json,
        ['auto_backup_enabled', 'autoBackupEnabled'],
        fallback: true,
      ),
      frequency: _parseBackupFrequency(
        _readString(json, ['frequency'], fallback: 'daily'),
      ),
      nextBackupAt: _parseNullableDateTime(
        json['next_backup_at'] ?? json['nextBackupAt'],
      ),
      storageTarget: _readString(
        json,
        ['storage_target', 'storageTarget'],
        fallback: 's3://tolab-backups/admin',
      ),
      retentionCount: _readInt(
        json,
        ['retention_count', 'retentionCount'],
        fallback: 12,
      ),
      encryptBackups: _readBool(
        json,
        ['encrypt_backups', 'encryptBackups'],
        fallback: true,
      ),
      history: _asList(json['history'])
          .map((item) => BackupSnapshot.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BackupRestoreSettings &&
        other.autoBackupEnabled == autoBackupEnabled &&
        other.frequency == frequency &&
        other.nextBackupAt == nextBackupAt &&
        other.storageTarget == storageTarget &&
        other.retentionCount == retentionCount &&
        other.encryptBackups == encryptBackups &&
        _deepEquality.equals(other.history, history);
  }

  @override
  int get hashCode => Object.hash(
    autoBackupEnabled,
    frequency,
    nextBackupAt,
    storageTarget,
    retentionCount,
    encryptBackups,
    _deepEquality.hash(history),
  );
}

class SettingsBundle {
  const SettingsBundle({
    required this.general,
    required this.theme,
    required this.notifications,
    required this.security,
    required this.userManagement,
    required this.uploadRules,
    required this.calendar,
    required this.system,
    required this.backupRestore,
    required this.updatedAt,
    required this.source,
    required this.isSynced,
  });

  final GeneralSettings general;
  final ThemeSettings theme;
  final NotificationPreferences notifications;
  final SecuritySettings security;
  final UserManagementSettings userManagement;
  final UploadRulesSettings uploadRules;
  final CalendarSettings calendar;
  final SystemSettings system;
  final BackupRestoreSettings backupRestore;
  final DateTime updatedAt;
  final String source;
  final bool isSynced;

  ThemeMode get themeMode => theme.themeMode;
  String get localeCode => general.languageCode;
  bool get pushEnabled => notifications.pushEnabled;
  bool get desktopAlertsEnabled => notifications.desktopAlertsEnabled;
  bool get auditLoggingEnabled => system.auditLoggingEnabled;
  int get sessionTimeoutMinutes => security.sessionTimeoutMinutes;
  int get uploadLimitMb => uploadRules.maxFileSizeMb;

  SettingsBundle copyWith({
    GeneralSettings? general,
    ThemeSettings? theme,
    NotificationPreferences? notifications,
    SecuritySettings? security,
    UserManagementSettings? userManagement,
    UploadRulesSettings? uploadRules,
    CalendarSettings? calendar,
    SystemSettings? system,
    BackupRestoreSettings? backupRestore,
    DateTime? updatedAt,
    String? source,
    bool? isSynced,
  }) {
    return SettingsBundle(
      general: general ?? this.general,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      security: security ?? this.security,
      userManagement: userManagement ?? this.userManagement,
      uploadRules: uploadRules ?? this.uploadRules,
      calendar: calendar ?? this.calendar,
      system: system ?? this.system,
      backupRestore: backupRestore ?? this.backupRestore,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson({bool includeBackupPayloads = true}) => {
    'general': general.toJson(),
    'theme': theme.toJson(),
    'notifications': notifications.toJson(),
    'security': security.toJson(),
    'user_management': userManagement.toJson(),
    'upload_rules': uploadRules.toJson(),
    'calendar': calendar.toJson(),
    'system': system.toJson(),
    'backup_restore': backupRestore.toJson(
      includeBackupPayloads: includeBackupPayloads,
    ),
    'updated_at': updatedAt.toIso8601String(),
    'source': source,
    'is_synced': isSynced,
  };

  Map<String, dynamic> toBackupPayload() => toJson(includeBackupPayloads: false);

  static SettingsBundle fromJson(Map<String, dynamic> json) {
    return SettingsBundle(
      general: GeneralSettings.fromJson(_asMap(json['general'])),
      theme: ThemeSettings.fromJson(_asMap(json['theme'])),
      notifications: NotificationPreferences.fromJson(
        _asMap(json['notifications']),
      ),
      security: SecuritySettings.fromJson(_asMap(json['security'])),
      userManagement: UserManagementSettings.fromJson(
        _asMap(json['user_management'] ?? json['userManagement']),
      ),
      uploadRules: UploadRulesSettings.fromJson(
        _asMap(json['upload_rules'] ?? json['uploadRules']),
      ),
      calendar: CalendarSettings.fromJson(_asMap(json['calendar'])),
      system: SystemSettings.fromJson(_asMap(json['system'])),
      backupRestore: BackupRestoreSettings.fromJson(
        _asMap(json['backup_restore'] ?? json['backupRestore']),
      ),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      source: _readString(json, ['source'], fallback: 'seed'),
      isSynced: _readBool(json, ['is_synced', 'isSynced'], fallback: true),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsBundle &&
        other.general == general &&
        other.theme == theme &&
        other.notifications == notifications &&
        other.security == security &&
        other.userManagement == userManagement &&
        other.uploadRules == uploadRules &&
        other.calendar == calendar &&
        other.system == system &&
        other.backupRestore == backupRestore &&
        other.updatedAt == updatedAt &&
        other.source == source &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode => Object.hash(
    general,
    theme,
    notifications,
    security,
    userManagement,
    uploadRules,
    calendar,
    system,
    backupRestore,
    updatedAt,
    source,
    isSynced,
  );
}

class SettingsMutationResult {
  const SettingsMutationResult({
    required this.bundle,
    required this.message,
    required this.syncState,
    this.notification,
  });

  final SettingsBundle bundle;
  final String message;
  final SettingsSyncState syncState;
  final AdminNotification? notification;
}

ThemeMode _parseThemeMode(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };
}

StorageLocation _parseStorageLocation(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'local' => StorageLocation.local,
    'cloudinary' => StorageLocation.cloudinary,
    'private_server' || 'private-server' || 'private server' =>
      StorageLocation.privateServer,
    _ => StorageLocation.s3,
  };
}

CalendarViewOption _parseCalendarView(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'week' => CalendarViewOption.week,
    'day' => CalendarViewOption.day,
    _ => CalendarViewOption.month,
  };
}

BackupFrequency _parseBackupFrequency(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'weekly' => BackupFrequency.weekly,
    'monthly' => BackupFrequency.monthly,
    _ => BackupFrequency.daily,
  };
}

AdminNotificationCategory? _notificationCategoryFromString(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'academic' => AdminNotificationCategory.academic,
    'messages' || 'message' => AdminNotificationCategory.messages,
    'announcements' || 'announcement' =>
      AdminNotificationCategory.announcements,
    'system' => AdminNotificationCategory.system,
    _ => null,
  };
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

Map<String, dynamic>? _asMapOrNull(dynamic value) {
  final map = _asMap(value);
  return map.isEmpty ? null : map;
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is Iterable) return value.toList(growable: false);
  return const <dynamic>[];
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final resolved = value.toString().trim();
    if (resolved.isNotEmpty) return resolved;
  }
  return fallback;
}

bool _readBool(
  Map<String, dynamic> json,
  List<String> keys, {
  bool fallback = false,
}) {
  for (final key in keys) {
    if (!json.containsKey(key)) continue;
    return _parseBool(json[key], fallback: fallback);
  }
  return fallback;
}

int _readInt(
  Map<String, dynamic> json,
  List<String> keys, {
  int fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

double _readDouble(
  Map<String, dynamic> json,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

bool _parseBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}

DateTime _parseDateTime(dynamic value) =>
    _parseNullableDateTime(value) ?? DateTime.now();

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed)?.toLocal();
  }
  return null;
}

Color _parseColor(dynamic value, {required Color fallback}) {
  if (value is Color) return value;
  if (value is int) return Color(value);
  if (value is String) {
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.isEmpty) return fallback;
    final full = normalized.length == 6 ? 'FF$normalized' : normalized;
    final parsed = int.tryParse(full, radix: 16);
    if (parsed != null) return Color(parsed);
  }
  return fallback;
}

String _colorToHex(Color color) =>
    '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
