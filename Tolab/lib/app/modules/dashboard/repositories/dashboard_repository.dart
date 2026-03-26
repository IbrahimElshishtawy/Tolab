import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/dashboard_models.dart';

class DashboardRepository {
  DashboardRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<DashboardBundle> fetchDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _demoDataService.dashboardBundle();
  }
}
