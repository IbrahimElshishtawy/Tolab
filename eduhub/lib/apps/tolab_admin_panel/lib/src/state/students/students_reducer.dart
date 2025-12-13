// الطلاب - reducer
import 'students_state.dart';
import 'students_actions.dart';

StudentsState studentsReducer(StudentsState state, dynamic action) {
  if (action is FilterStudentsByYearAction) {
    return state.copyWith(selectedYear: action.year);
  } else if (action is FilterStudentsByDepartmentAction) {
    return state.copyWith(selectedDepartment: action.department);
  }
  return state;
}
