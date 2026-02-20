import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class SubjectsApi {
  final ApiClient _client = ApiClient();

  Future<Response> getSubjects() async {
    return await _client.get(ApiEndpoints.subjects);
  }

  Future<Response> getLectures(int subjectId) async {
    return await _client.get(ApiEndpoints.lectures.replaceFirst('{id}', subjectId.toString()));
  }

  Future<Response> getSections(int subjectId) async {
    return await _client.get(ApiEndpoints.sections.replaceFirst('{id}', subjectId.toString()));
  }
}
