import 'subjects_state.dart';
import 'subjects_actions.dart';

SubjectsState subjectsReducer(SubjectsState state, dynamic action) {
  if (action is FetchSubjectsStartAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  if (action is FetchSubjectsSuccessAction) {
    return state.copyWith(
      subjects: action.subjects,
      isLoading: false,
    );
  }
  if (action is FetchSubjectsFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  return state;
}
