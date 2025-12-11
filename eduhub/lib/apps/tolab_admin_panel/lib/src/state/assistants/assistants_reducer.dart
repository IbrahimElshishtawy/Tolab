import 'package:redux/redux.dart';
import 'assistants_actions.dart';
import 'assistants_state.dart';

final assistantsReducer = combineReducers<AssistantsState>([
  TypedReducer<AssistantsState, LoadAssistantsAction>(_onLoad).call,
  TypedReducer<AssistantsState, AssistantsLoadedAction>(_onLoaded).call,
  TypedReducer<AssistantsState, AssistantsFailedAction>(_onFailed).call,
]);

AssistantsState _onLoad(AssistantsState state, LoadAssistantsAction action) {
  return state.copyWith(isLoading: true, error: null);
}

AssistantsState _onLoaded(
  AssistantsState state,
  AssistantsLoadedAction action,
) {
  return state.copyWith(isLoading: false, assistants: action.data);
}

AssistantsState _onFailed(
  AssistantsState state,
  AssistantsFailedAction action,
) {
  return state.copyWith(isLoading: false, error: action.error);
}
