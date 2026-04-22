import '../../../core/models/academic_models.dart';
import '../../../core/network/api_client.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class AdminRepository {
  Future<Map<String, dynamic>> fetchOverview();

  Future<List<String>> fetchPermissions();

  Future<List<DepartmentModel>> fetchDepartments();

  Future<void> toggleActivation(int userId, bool isActive);
}

class ApiAdminRepository implements AdminRepository {
  ApiAdminRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> fetchOverview() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/admin/overview',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return response.data ?? const <String, dynamic>{};
  }

  @override
  Future<List<String>> fetchPermissions() async {
    final response = await _apiClient.get<List<String>>(
      '/staff-portal/admin/permissions',
      parser: (value) => (value as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );

    return response.data ?? const <String>[];
  }

  @override
  Future<List<DepartmentModel>> fetchDepartments() async {
    final response = await _apiClient.get<List<DepartmentModel>>(
      '/staff-portal/admin/departments',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DepartmentModel.fromJson)
          .toList(),
    );

    return response.data ?? const <DepartmentModel>[];
  }

  @override
  Future<void> toggleActivation(int userId, bool isActive) async {
    await _apiClient.patch<Object?>(
      '/staff-portal/admin/staff/$userId/activation',
      data: {'is_active': isActive},
      parser: (_) => null,
    );
  }
}

class MockAdminRepository implements AdminRepository {
  MockAdminRepository(this._mockRepository);

  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<Map<String, dynamic>> fetchOverview() async {
    await _mockRepository.simulateLatency();
    return _mockRepository.adminOverview();
  }

  @override
  Future<List<String>> fetchPermissions() async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 180));
    return _mockRepository.adminPermissions();
  }

  @override
  Future<List<DepartmentModel>> fetchDepartments() async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 180));
    return _mockRepository.departments();
  }

  @override
  Future<void> toggleActivation(int userId, bool isActive) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 160));
    _mockRepository.toggleStaffActivation(userId, isActive);
  }
}
