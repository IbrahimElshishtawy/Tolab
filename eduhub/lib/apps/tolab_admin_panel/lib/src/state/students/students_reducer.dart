import 'students_state.dart';
import 'students_actions.dart';

StudentsState studentsReducer(StudentsState state, dynamic action) {
  if (action is LoadStudentsAction) {
    return state.copyWith(isLoading: true, error: null);
  }

  if (action is StudentsLoadedAction) {
    return state.copyWith(
      isLoading: false,
      students: action.students,
      error: null,
    );
  }

  if (action is StudentsFailedAction) {
    return state.copyWith(isLoading: false, error: action.error);
  }

  return state;
}
