import '../../../core/models/staff_models.dart';
import '../../../core/network/api_client.dart';

class StaffRepository {
  StaffRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<StaffMemberModel>> fetchStaff() async {
    final response = await _apiClient.get<List<StaffMemberModel>>(
      '/staff-portal/admin/staff',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(StaffMemberModel.fromJson)
          .toList(),
    );

    return response.data ?? const <StaffMemberModel>[];
  }
}
