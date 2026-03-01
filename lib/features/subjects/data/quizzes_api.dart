import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class QuizzesApi {
  final ApiClient _client = ApiClient();

  Future<Response> getQuizzes(int subjectId) async {
    return await _client.get(ApiEndpoints.quizzes, queryParameters: {'subject_id': subjectId});
  }

  Future<Response> createQuiz(Map<String, dynamic> data) async {
    return await _client.post(ApiEndpoints.quizzes, data: data);
  }

  Future<Response> startAttempt(int quizId) async {
    return await _client.post("${ApiEndpoints.quizzes}/$quizId/attempt");
  }

  Future<Response> submitAttempt(int attemptId, int score) async {
    return await _client.post("${ApiEndpoints.quizzes}/attempts/$attemptId/submit", data: {'score': score});
  }
}
