import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/quizzes_repository.dart';
import 'quizzes_actions.dart';

List<Middleware<DoctorAssistantAppState>> createQuizzesMiddleware(
  QuizzesRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadQuizzesAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await repository.fetchQuizzes();
        store.dispatch(LoadQuizzesSuccessAction(items));
      } catch (error) {
        store.dispatch(LoadQuizzesFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, SaveQuizAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.saveQuiz(action.payload);
      store.dispatch(LoadQuizzesAction());
    }).call,
  ];
}
