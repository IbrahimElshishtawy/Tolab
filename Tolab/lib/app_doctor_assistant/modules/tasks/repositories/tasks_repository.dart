import '../../../core/models/content_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class TasksRepository {
  Future<List<TaskModel>> fetchTasks();

  Future<void> saveTask(Map<String, dynamic> payload);
}

class ApiTasksRepository implements TasksRepository {
  ApiTasksRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    final response = await _apiClient.get<List<TaskModel>>(
      '/staff-portal/tasks',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList(),
    );

    return response.data ?? const <TaskModel>[];
  }

  @override
  Future<void> saveTask(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/tasks',
      data: payload,
      parser: (_) => null,
    );
  }
}

class MockTasksRepository implements TasksRepository {
  MockTasksRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<TaskModel>> fetchTasks() async {
    await _mockRepository.simulateLatency();
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('assistant@tolab.edu');
    return _mockRepository.tasksFor(user);
  }

  @override
  Future<void> saveTask(Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('assistant@tolab.edu');
    _mockRepository.saveTask(payload, user);
  }
}
