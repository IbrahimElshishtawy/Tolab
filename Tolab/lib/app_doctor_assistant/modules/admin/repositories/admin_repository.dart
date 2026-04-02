import '../../../core/models/academic_models.dart';
import '../../../core/network/api_client.dart';

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchOverview() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/staff-portal/admin/overview',
      parser: (value) => Map<String, dynamic>.from(value as Map),
    );

    return response.data ?? const <String, dynamic>{};
  }

  Future<List<String>> fetchPermissions() async {
    final response = await _apiClient.get<List<String>>(
      '/staff-portal/admin/permissions',
      parser: (value) => (value as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );

    return response.data ?? const <String>[];
  }

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

  Future<void> toggleActivation(int userId, bool isActive) async {
    await _apiClient.patch<Object?>(
      '/staff-portal/admin/staff/$userId/activation',
      data: {'is_active': isActive},
      parser: (_) => null,
    );
  }
}
