import 'package:redux/redux.dart';
import 'doctors_actions.dart';
import 'doctors_state.dart';

final doctorsReducer = combineReducers<DoctorsState>([
  TypedReducer<DoctorsState, LoadDoctorsAction>(_onLoad).call,
  TypedReducer<DoctorsState, DoctorsLoadedAction>(_onLoaded).call,
  TypedReducer<DoctorsState, DoctorsFailedAction>(_onFailed).call,
]);

DoctorsState _onLoad(DoctorsState state, LoadDoctorsAction action) {
  return state.copyWith(isLoading: true, error: null);
}

DoctorsState _onLoaded(DoctorsState state, DoctorsLoadedAction action) {
  return state.copyWith(isLoading: false, doctors: action.data);
}

DoctorsState _onFailed(DoctorsState state, DoctorsFailedAction action) {
  return state.copyWith(isLoading: false, error: action.error);
}
