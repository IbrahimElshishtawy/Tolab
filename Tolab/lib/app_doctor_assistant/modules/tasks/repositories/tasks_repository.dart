import '../../../core/models/content_models.dart';
import '../../../core/network/api_client.dart';

class TasksRepository {
  TasksRepository(this._apiClient);

  final ApiClient _apiClient;

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

  Future<void> saveTask(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/tasks',
      data: payload,
      parser: (_) => null,
    );
  }
}
