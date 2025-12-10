import 'students_state.dart';
import 'students_actions.dart';

StudentsState studentsReducer(StudentsState state, dynamic action) {
  if (action is LoadStudentsAction) {
    return state.copyWith(isLoading: true);
  }

  if (action is StudentsLoadedAction) {
    return state.copyWith(isLoading: false, students: action.students);
  }

  if (action is StudentsFailedAction) {
    return state.copyWith(isLoading: false, error: action.error);
  }

  return state;
}
