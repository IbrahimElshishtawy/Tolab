import 'package:redux/redux.dart';
import 'students_actions.dart';
import 'students_state.dart';

final studentsReducer = combineReducers<StudentsState>([
  TypedReducer<StudentsState, LoadStudentsAction>(_onLoad).call,
  TypedReducer<StudentsState, StudentsLoadedAction>(_onLoaded).call,
  TypedReducer<StudentsState, StudentsFailedAction>(_onFailed).call,
]);

StudentsState _onLoad(StudentsState state, LoadStudentsAction action) {
  return state.copyWith(isLoading: true, error: null);
}

StudentsState _onLoaded(StudentsState state, StudentsLoadedAction action) {
  return state.copyWith(isLoading: false, students: action.data);
}

StudentsState _onFailed(StudentsState state, StudentsFailedAction action) {
  return state.copyWith(isLoading: false, error: action.error);
}
