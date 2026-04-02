import '../../../core/models/content_models.dart';
import '../../../core/network/api_client.dart';

class QuizzesRepository {
  QuizzesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<QuizModel>> fetchQuizzes() async {
    final response = await _apiClient.get<List<QuizModel>>(
      '/staff-portal/quizzes',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(QuizModel.fromJson)
          .toList(),
    );

    return response.data ?? const <QuizModel>[];
  }

  Future<void> saveQuiz(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/quizzes',
      data: payload,
      parser: (_) => null,
    );
  }
}
