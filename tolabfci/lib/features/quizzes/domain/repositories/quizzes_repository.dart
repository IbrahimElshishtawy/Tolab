import '../../../../core/models/quiz_models.dart';

abstract class QuizzesRepository {
  Future<List<QuizItem>> getQuizzes(String? courseOfferingId);

  Future<StudentQuizDetails> getQuizDetails({
    required String courseOfferingId,
    required String quizId,
  });

  Future<StudentQuizDetails> startQuiz({
    required String courseOfferingId,
    required String quizId,
  });

  Future<QuizItem> submitQuiz(
    String quizId, {
    String? subjectId,
    Map<String, Object?> answers = const {},
  });

  Future<List<QuizItem>> fetchQuizzes({String? subjectId});

  Future<StudentQuizDetails> fetchQuizDetails({
    required String subjectId,
    required String quizId,
  });

}
