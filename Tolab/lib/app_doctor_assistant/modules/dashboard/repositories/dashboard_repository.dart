import '../../../core/models/dashboard_models.dart';
import '../../../core/network/api_client.dart';

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardSnapshot> fetchDashboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff/dashboard',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return DashboardSnapshot.fromJson(response.data ?? const {});
  }
}
