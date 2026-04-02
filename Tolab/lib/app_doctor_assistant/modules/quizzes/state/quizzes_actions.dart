import '../../../core/models/content_models.dart';

class LoadQuizzesAction {}

class LoadQuizzesSuccessAction {
  LoadQuizzesSuccessAction(this.items);

  final List<QuizModel> items;
}

class LoadQuizzesFailureAction {
  LoadQuizzesFailureAction(this.message);

  final String message;
}

class SaveQuizAction {
  SaveQuizAction(this.payload);

  final Map<String, dynamic> payload;
}
