import '../../../core/models/content_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';

abstract class QuizzesRepository {
  Future<List<QuizModel>> fetchQuizzes();

  Future<void> saveQuiz(Map<String, dynamic> payload);
}

class ApiQuizzesRepository implements QuizzesRepository {
  ApiQuizzesRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
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

  @override
  Future<void> saveQuiz(Map<String, dynamic> payload) async {
    await _apiClient.post<Object?>(
      '/staff-portal/quizzes',
      data: payload,
      parser: (_) => null,
    );
  }
}

class MockQuizzesRepository implements QuizzesRepository {
  MockQuizzesRepository(this._tokenStorage, this._mockRepository);

  final TokenStorage _tokenStorage;
  final DoctorAssistantMockRepository _mockRepository;

  @override
  Future<List<QuizModel>> fetchQuizzes() async {
    await _mockRepository.simulateLatency();
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    return _mockRepository.quizzesFor(user);
  }

  @override
  Future<void> saveQuiz(Map<String, dynamic> payload) async {
    await _mockRepository.simulateLatency(const Duration(milliseconds: 220));
    final session = await _tokenStorage.read();
    final user =
        _mockRepository.restoreUserFromSession(session) ??
        _mockRepository.userByEmail('doctor@tolab.edu');
    _mockRepository.saveQuiz(payload, user);
  }
}
