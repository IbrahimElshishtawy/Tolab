import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class TasksApi {
  final ApiClient _client = ApiClient();

  Future<Response> getTasks(int subjectId) async {
    return await _client.get(ApiEndpoints.tasks.replaceFirst('{id}', subjectId.toString()));
  }

  Future<Response> submitTask(int taskId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    return await _client.post(
      ApiEndpoints.submissions.replaceFirst('{id}', taskId.toString()),
      data: formData,
    );
  }

  Future<Response> createTask(int subjectId, Map<String, dynamic> data) async {
    return await _client.post(
      ApiEndpoints.tasks.replaceFirst('{id}', subjectId.toString()),
      data: FormData.fromMap(data),
    );
  }

  Future<Response> getSubmissions(int taskId) async {
    return await _client.get(ApiEndpoints.submissions.replaceFirst('{id}', taskId.toString()));
  }

  Future<Response> gradeSubmission(int submissionId, double grade, {String? feedback}) async {
    return await _client.post(
      "/submissions/$submissionId/grade",
      data: FormData.fromMap({
        'grade': grade,
        'feedback': feedback,
      }),
    );
  }
}
