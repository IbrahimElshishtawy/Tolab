import '../../../../core/models/home_dashboard.dart';

abstract class HomeRepository {
  Future<HomeDashboardData> fetchDashboard();
}
