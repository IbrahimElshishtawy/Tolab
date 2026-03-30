import 'dart:convert';

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/notification_models.dart';
import '../models/settings_models.dart';
import '../services/settings_api_service.dart';

class SettingsRepository {
  SettingsRepository(
    this._api,
    this._localStorage,
    this._demoDataService,
  );

  final SettingsApiService _api;
  final LocalStorageService _localStorage;
  final DemoDataService _demoDataService;

  static const String _cacheKey = 'settings.bundle.v2';
  SettingsBundle? _cache;

  Future<SettingsBundle> fetchSettings() async {
    final cached = _cache ?? _readCachedBundle();
    final seed = cached ?? _demoDataService.settings();

    try {
      final remote = await _api.fetchSettings();
      final resolved = remote.copyWith(
        source: 'laravel',
        isSynced: true,
        updatedAt: DateTime.now(),
      );
      await _persist(resolved);
      return resolved;
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) rethrow;
    } catch (_) {
      // Falls back to local cache or seeded demo data below.
    }

    await _persist(seed);
    return seed;
  }

  Future<SettingsMutationResult> saveSettings(SettingsBundle bundle) async {
    final localBundle = bundle.copyWith(
      updatedAt: DateTime.now(),
      source: 'local',
      isSynced: false,
    );
    await _persist(localBundle);

    try {
      final remote = await _api.saveSettings(bundle);
      final syncedBundle = remote.copyWith(
        updatedAt: DateTime.now(),
        source: 'laravel',
        isSynced: true,
      );
      await _persist(syncedBundle);
      return SettingsMutationResult(
        bundle: syncedBundle,
        message: 'Settings saved successfully.',
        syncState: SettingsSyncState.synced,
        notification: _settingsNotification(
          title: 'Settings updated',
          body:
              '${syncedBundle.general.academyName} preferences were synced with Laravel.',
        ),
      );
    } catch (_) {
      return SettingsMutationResult(
        bundle: localBundle,
        message: 'Settings saved locally. Laravel sync is pending.',
        syncState: SettingsSyncState.localOnly,
        notification: _settingsNotification(
          title: 'Local settings backup saved',
          body:
              'Changes were stored on this device while the backend connection is unavailable.',
        ),
      );
    }
  }

  Future<SettingsMutationResult> createBackup(SettingsBundle bundle) async {
    final now = DateTime.now();
    final localSnapshot = BackupSnapshot(
      id: 'backup-${now.microsecondsSinceEpoch}',
      label: 'Manual backup ${now.year}-${now.month}-${now.day}',
      createdAt: now,
      sizeLabel: '1.8 MB',
      status: 'Ready',
      source: 'local',
      restorable: true,
      snapshotPayload: bundle.toBackupPayload(),
    );

    var nextBundle = _insertBackup(bundle, localSnapshot);

    try {
      final remoteSnapshot = await _api.createBackup(bundle);
      nextBundle = _replaceNewestBackup(
        nextBundle,
        remoteSnapshot.copyWith(
          snapshotPayload: bundle.toBackupPayload(),
          source: 'laravel',
        ),
      ).copyWith(source: 'laravel', isSynced: true, updatedAt: now);
      await _persist(nextBundle);
      return SettingsMutationResult(
        bundle: nextBundle,
        message: 'Database backup created successfully.',
        syncState: SettingsSyncState.synced,
        notification: _settingsNotification(
          title: 'Backup completed',
          body: 'A fresh restore point was created and synced to the backend.',
        ),
      );
    } catch (_) {
      await _persist(nextBundle);
      return SettingsMutationResult(
        bundle: nextBundle,
        message: 'Backup created locally. Remote sync is pending.',
        syncState: SettingsSyncState.localOnly,
        notification: _settingsNotification(
          title: 'Local backup created',
          body:
              'The restore point is available locally and will sync when the backend recovers.',
        ),
      );
    }
  }

  Future<SettingsMutationResult> restoreBackup({
    required SettingsBundle currentBundle,
    required String backupId,
  }) async {
    final currentSnapshot = currentBundle.backupRestore.history.firstWhere(
      (item) => item.id == backupId,
      orElse: () => throw AppException('The selected backup could not be found.'),
    );

    try {
      final remoteBundle = await _api.restoreBackup(backupId);
      final merged = remoteBundle.copyWith(
        backupRestore: remoteBundle.backupRestore.copyWith(
          history: _mergeBackupHistory(
            remoteBundle.backupRestore.history,
            currentBundle.backupRestore.history,
          ),
        ),
        updatedAt: DateTime.now(),
        source: 'laravel',
        isSynced: true,
      );
      await _persist(merged);
      return SettingsMutationResult(
        bundle: merged,
        message: 'Backup restored successfully.',
        syncState: SettingsSyncState.synced,
        notification: _settingsNotification(
          title: 'Settings restored',
          body: '${currentSnapshot.label} was restored from the backend.',
        ),
      );
    } catch (_) {
      final payload = currentSnapshot.snapshotPayload;
      if (payload == null || payload.isEmpty) {
        throw AppException('This backup does not include a local restore payload.');
      }
      final restored = SettingsBundle.fromJson(payload).copyWith(
        backupRestore: currentBundle.backupRestore,
        updatedAt: DateTime.now(),
        source: 'local',
        isSynced: false,
      );
      await _persist(restored);
      return SettingsMutationResult(
        bundle: restored,
        message: 'Backup restored locally. Backend sync is pending.',
        syncState: SettingsSyncState.localOnly,
        notification: _settingsNotification(
          title: 'Local restore applied',
          body: '${currentSnapshot.label} was restored from local backup data.',
        ),
      );
    }
  }

  Future<void> cacheBundle(SettingsBundle bundle) => _persist(bundle);

  SettingsBundle? _readCachedBundle() {
    try {
      final payload = _localStorage.readString(_cacheKey);
      if (payload.isEmpty) return null;
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;
      _cache = SettingsBundle.fromJson(decoded);
      return _cache;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(SettingsBundle bundle) async {
    _cache = bundle;
    await _localStorage.writeString(_cacheKey, jsonEncode(bundle.toJson()));
  }

  SettingsBundle _insertBackup(SettingsBundle bundle, BackupSnapshot snapshot) {
    final nextHistory = [snapshot, ...bundle.backupRestore.history]
        .take(bundle.backupRestore.retentionCount)
        .toList(growable: false);
    return bundle.copyWith(
      backupRestore: bundle.backupRestore.copyWith(
        history: nextHistory,
        nextBackupAt: bundle.backupRestore.autoBackupEnabled
            ? DateTime.now().add(
                Duration(days: bundle.backupRestore.frequency.days),
              )
            : null,
        clearNextBackupAt: !bundle.backupRestore.autoBackupEnabled,
      ),
      updatedAt: DateTime.now(),
    );
  }

  SettingsBundle _replaceNewestBackup(
    SettingsBundle bundle,
    BackupSnapshot snapshot,
  ) {
    if (bundle.backupRestore.history.isEmpty) return _insertBackup(bundle, snapshot);
    final nextHistory = [
      snapshot,
      ...bundle.backupRestore.history.skip(1),
    ].toList(growable: false);
    return bundle.copyWith(
      backupRestore: bundle.backupRestore.copyWith(history: nextHistory),
    );
  }

  List<BackupSnapshot> _mergeBackupHistory(
    List<BackupSnapshot> remote,
    List<BackupSnapshot> local,
  ) {
    final merged = <String, BackupSnapshot>{
      for (final item in local) item.id: item,
      for (final item in remote) item.id: item,
    };
    final values = merged.values.toList(growable: false)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return values;
  }

  AdminNotification _settingsNotification({
    required String title,
    required String body,
  }) {
    return AdminNotification(
      id: 'settings-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      category: AdminNotificationCategory.system,
      createdAt: DateTime.now(),
      isRead: false,
      rawType: 'SYSTEM',
      refType: 'settings',
      refId: 'settings-module',
      source: 'settings',
      audienceLabel: 'Admin panel',
    );
  }
}
