import '../../../core/models/dashboard_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot> fetchDashboard();
}

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DashboardSnapshot> fetchDashboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff/dashboard',
      requiresAuth: true,
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return DashboardSnapshot.fromJson(response.data ?? const {});
  }
}

class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<DashboardSnapshot> fetchDashboard() async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 320));
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.dashboardFor(user);
  }
}
