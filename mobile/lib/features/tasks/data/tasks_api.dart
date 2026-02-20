import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class TasksApi {
  final ApiClient _client = ApiClient();

  Future<Response> getTasks(int subjectId) async {
    return await _client.get(ApiEndpoints.tasks.replaceFirst('{id}', subjectId.toString()));
  }

  Future<Response> submitTask(int taskId, String fileUrl) async {
    return await _client.post(
      ApiEndpoints.submissions.replaceFirst('{id}', taskId.toString()),
      data: {'file_url': fileUrl},
    );
  }
}
