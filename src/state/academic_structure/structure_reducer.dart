import 'structure_actions.dart';
import 'structure_state.dart';

structureState structureReducer(structureState state, dynamic action) {
  if (action is LoadstructureAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is structureLoadedAction) {
    return state.copyWith(isLoading: false, data: action.data);
  }

  if (action is structureFailedAction) {
    return state.copyWith(isLoading: false, error: action.error);
  }

  return state;
}
