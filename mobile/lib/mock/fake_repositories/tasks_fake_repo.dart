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

  Future<void> createTask(int subjectId, Task task) async {
    await fakeDelay(1000);
  }

  Future<void> updateTask(Task task) async {
    await fakeDelay(1000);
  }

  Future<void> deleteTask(int taskId) async {
    await fakeDelay(1000);
  }

  Future<List<Submission>> getSubmissions(int taskId) async {
    await fakeDelay();
    return mockSubmissionsData
        .where((json) => json['task_id'] == taskId)
        .map((json) => Submission.fromJson(json))
        .toList();
  }

  Future<void> gradeSubmission(int submissionId, String grade) async {
    await fakeDelay(800);
  }
}
