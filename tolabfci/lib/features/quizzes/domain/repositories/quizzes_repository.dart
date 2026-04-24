import '../../../../core/models/quiz_models.dart';

abstract class QuizzesRepository {
  Future<List<QuizItem>> fetchQuizzes({String? subjectId});

  Future<StudentQuizDetails> fetchQuizDetails({
    required String subjectId,
    required String quizId,
  });

  Future<QuizItem> submitQuiz(String quizId, {String? subjectId});
}
