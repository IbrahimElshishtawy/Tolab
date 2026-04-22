import '../../../core/models/notification_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEventModel>> fetchEvents();
}

class ApiScheduleRepository implements ScheduleRepository {
  ApiScheduleRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ScheduleEventModel>> fetchEvents() async {
    final response = await _apiClient.get<List<ScheduleEventModel>>(
      '/staff-portal/schedule',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ScheduleEventModel.fromJson)
          .toList(),
    );

    return response.data ?? const <ScheduleEventModel>[];
  }
}

class MockScheduleRepository implements ScheduleRepository {
  MockScheduleRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<ScheduleEventModel>> fetchEvents() async {
    await _mockRepository.simulateLatency();
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.scheduleModelsFor(user);
  }
}
