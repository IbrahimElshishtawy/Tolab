import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/quizzes_repository.dart';

final quizzesRepositoryProvider = Provider<QuizzesRepository>((ref) {
  return MockQuizzesRepository(ref.watch(mockBackendServiceProvider));
});

class MockQuizzesRepository implements QuizzesRepository {
  const MockQuizzesRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<List<QuizItem>> fetchQuizzes({String? subjectId}) {
    return _backendService.fetchQuizzes(subjectId: subjectId);
  }
}
