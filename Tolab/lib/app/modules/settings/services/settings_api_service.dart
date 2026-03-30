import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/settings_models.dart';

class SettingsApiService {
  SettingsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<SettingsBundle> fetchSettings() {
    return _apiClient.get<SettingsBundle>(
      '/admin/settings',
      decoder: (json) => SettingsBundle.fromJson(_normalizeBundlePayload(json)),
    );
  }

  Future<SettingsBundle> saveSettings(SettingsBundle bundle) {
    return _apiClient.put<SettingsBundle>(
      '/admin/settings',
      data: bundle.toJson(includeBackupPayloads: false),
      decoder: (json) => SettingsBundle.fromJson(_normalizeBundlePayload(json)),
    );
  }

  Future<BackupSnapshot> createBackup(SettingsBundle bundle) {
    return _apiClient.post<BackupSnapshot>(
      '/admin/settings/backups',
      data: {
        'settings': bundle.toBackupPayload(),
        'storage_target': bundle.backupRestore.storageTarget,
        'encrypt': bundle.backupRestore.encryptBackups,
      },
      decoder: (json) => BackupSnapshot.fromJson(_normalizeBackupPayload(json)),
    );
  }

  Future<SettingsBundle> restoreBackup(String backupId) {
    return _apiClient.post<SettingsBundle>(
      '/admin/settings/backups/$backupId/restore',
      decoder: (json) => SettingsBundle.fromJson(_normalizeBundlePayload(json)),
    );
  }

  Map<String, dynamic> _normalizeBundlePayload(dynamic json) {
    final resolved = switch (json) {
      JsonMap() when json['settings'] is JsonMap =>
        json['settings'] as Map<String, dynamic>,
      JsonMap() when json['bundle'] is JsonMap =>
        json['bundle'] as Map<String, dynamic>,
      JsonMap() when json['data'] is JsonMap => json['data'] as Map<String, dynamic>,
      JsonMap() => json,
      _ => <String, dynamic>{},
    };
    return Map<String, dynamic>.from(resolved);
  }

  Map<String, dynamic> _normalizeBackupPayload(dynamic json) {
    final resolved = switch (json) {
      JsonMap() when json['backup'] is JsonMap =>
        json['backup'] as Map<String, dynamic>,
      JsonMap() when json['data'] is JsonMap => json['data'] as Map<String, dynamic>,
      JsonMap() => json,
      _ => <String, dynamic>{},
    };
    return Map<String, dynamic>.from(resolved);
  }
}
