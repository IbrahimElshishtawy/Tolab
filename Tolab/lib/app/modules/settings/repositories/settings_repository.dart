import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/settings_models.dart';

class SettingsRepository {
  SettingsRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<SettingsBundle> fetchSettings() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _demoDataService.settings();
  }
}
