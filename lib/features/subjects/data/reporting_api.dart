import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class ReportingApi {
  final ApiClient _client = ApiClient();

  Future<Response> getGradebook(int subjectId) async {
    return await _client.get(ApiEndpoints.gradebook.replaceFirst('{id}', subjectId.toString()));
  }

  Future<Response> getProgress(int subjectId) async {
    return await _client.get(ApiEndpoints.progress.replaceFirst('{id}', subjectId.toString()));
  }
}
