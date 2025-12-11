import 'doctors_actions.dart';
import 'doctors_state.dart';

doctorsState doctorsReducer(doctorsState state, dynamic action) {
  if (action is LoaddoctorsAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is doctorsLoadedAction) {
    return state.copyWith(isLoading: false, data: action.data);
  }

  if (action is doctorsFailedAction) {
    return state.copyWith(isLoading: false, error: action.error);
  }

  return state;
}
