import '../../../core/state/async_state.dart';
import 'quizzes_actions.dart';
import 'quizzes_state.dart';

QuizzesState quizzesReducer(QuizzesState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadQuizzesAction:
    case SaveQuizAction:
      return QuizzesState(status: ViewStatus.loading, data: state.data);
    case LoadQuizzesSuccessAction:
      return QuizzesState(
        status: ViewStatus.success,
        data: (action as LoadQuizzesSuccessAction).items,
      );
    case LoadQuizzesFailureAction:
      return QuizzesState(
        status: ViewStatus.failure,
        data: state.data,
        error: (action as LoadQuizzesFailureAction).message,
      );
    default:
      return state;
  }
}
