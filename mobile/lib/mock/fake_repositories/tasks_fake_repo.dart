import '../../features/tasks/data/models.dart';
import '../fake_delay.dart';
import '../mock_data.dart';

class TasksFakeRepo {
  Future<List<Task>> getTasks(int subjectId) async {
    await fakeDelay();
    return mockTasksData.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> submitTask(int taskId, String fileUrl) async {
    await fakeDelay(1500);
  }
}
