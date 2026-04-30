import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../data/repositories/mock_quizzes_repository.dart';

final quizzesProvider = FutureProvider.family((ref, String? subjectId) {
  return ref.watch(quizzesRepositoryProvider).getQuizzes(subjectId);
});

final quizDetailsProvider =
    FutureProvider.family<
      StudentQuizDetails,
      ({String subjectId, String quizId})
    >((ref, request) {
      return ref
          .watch(quizzesRepositoryProvider)
          .getQuizDetails(
            courseOfferingId: request.subjectId,
            quizId: request.quizId,
          );
    });
