import '../../../core/models/staff_models.dart';
import '../../../core/network/api_client.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class StaffRepository {
  Future<List<StaffMemberModel>> fetchStaff();
}

class ApiStaffRepository implements StaffRepository {
  ApiStaffRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
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

class MockStaffRepository implements StaffRepository {
  MockStaffRepository(this._mockRepository);

  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<StaffMemberModel>> fetchStaff() async {
    await _mockRepository.simulateLatency();
    return _mockRepository.staffMembers();
  }
}
