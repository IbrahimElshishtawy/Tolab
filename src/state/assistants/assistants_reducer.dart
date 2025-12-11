import 'assistants_actions.dart';
import 'assistants_state.dart';

assistantsState assistantsReducer(assistantsState state, dynamic action) {
  if (action is LoadassistantsAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is assistantsLoadedAction) {
    return state.copyWith(isLoading: false, data: action.data);
  }

  if (action is assistantsFailedAction) {
    return state.copyWith(isLoading: false, error: action.error);
  }

  return state;
}
