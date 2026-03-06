import '../../features/tasks/data/models.dart';
import '../fake_delay.dart';
import '../mock_data.dart';

class TasksFakeRepo {
  Future<List<Task>> getTasks(int subjectId) async {
    await fakeDelay();
    final list = mockTasksDataMap[subjectId] ?? [];
    return list.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> createTask(int subjectId, Task task) async {
    await fakeDelay(1000);
  }

  Future<void> updateTask(Task task) async {
    await fakeDelay(800);
  }

  Future<void> deleteTask(int taskId) async {
    await fakeDelay(500);
  }

  Future<List<Submission>> getSubmissions(int taskId) async {
    await fakeDelay();
    return mockSubmissionsData.map((json) => Submission.fromJson(json)).toList();
  }

  Future<void> gradeSubmission(int submissionId, String grade) async {
    await fakeDelay(600);
  }
}
