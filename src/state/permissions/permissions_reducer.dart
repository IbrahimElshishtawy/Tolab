import 'permissions_actions.dart';
import 'permissions_state.dart';

permissionsState permissionsReducer(permissionsState state, dynamic action) {
  if (action is LoadpermissionsAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is permissionsLoadedAction) {
    return state.copyWith(isLoading: false, data: action.data);
  }

  if (action is permissionsFailedAction) {
    return state.copyWith(isLoading: false, error: action.error);
  }

  return state;
}
