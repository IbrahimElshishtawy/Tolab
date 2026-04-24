import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../data/repositories/mock_quizzes_repository.dart';

final quizzesProvider = FutureProvider.family((ref, String? subjectId) {
  return ref
      .watch(quizzesRepositoryProvider)
      .fetchQuizzes(subjectId: subjectId);
});

final quizDetailsProvider =
    FutureProvider.family<
      StudentQuizDetails,
      ({String subjectId, String quizId})
    >((ref, request) {
      return ref
          .watch(quizzesRepositoryProvider)
          .fetchQuizDetails(
            subjectId: request.subjectId,
            quizId: request.quizId,
          );
    });
