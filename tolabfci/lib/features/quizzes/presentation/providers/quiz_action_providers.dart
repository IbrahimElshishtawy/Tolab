import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_quizzes_repository.dart';
import '../../../home/presentation/providers/home_providers.dart';
import 'quizzes_providers.dart';

final quizActionsProvider = Provider<QuizActionsController>((ref) {
  return QuizActionsController(ref);
});

class QuizActionsController {
  const QuizActionsController(this._ref);

  final Ref _ref;

  Future<void> submitQuiz(String quizId, {String? subjectId}) async {
    await _ref.read(quizzesRepositoryProvider).submitQuiz(quizId);
    _ref.invalidate(quizzesProvider(null));
    _ref.invalidate(homeDashboardProvider);
    if (subjectId != null) {
      _ref.invalidate(quizzesProvider(subjectId));
    }
  }
}
