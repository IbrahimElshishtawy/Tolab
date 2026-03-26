// ignore_for_file: unused_field

import '../../datasources/admin/admin_resource_remote_data_source.dart';
import '../../models/admin_models.dart';
import '../../models/admin_seed_data.dart';

class SettingsRepository {
  SettingsRepository(this._remoteDataSource);

  final AdminResourceRemoteDataSource _remoteDataSource;
  SettingsModel _settings = AdminSeedData.settings();

  Future<SettingsModel> getSettings() async => _settings;

  Future<SettingsModel> saveSettings(SettingsModel settings) async {
    _settings = settings;
    return _settings;
  }
}
