import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_quizzes_repository.dart';

final quizzesProvider = FutureProvider.family((ref, String? subjectId) {
  return ref.watch(quizzesRepositoryProvider).fetchQuizzes(subjectId: subjectId);
});
