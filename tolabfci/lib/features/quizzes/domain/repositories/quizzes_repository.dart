import '../../../../core/models/quiz_models.dart';

abstract class QuizzesRepository {
  Future<List<QuizItem>> fetchQuizzes({String? subjectId});
}
