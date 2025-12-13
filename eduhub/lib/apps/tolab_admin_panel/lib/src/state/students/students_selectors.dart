// students_selectors.dart

import '../app_state.dart';

class StudentsSelectors {
  static String selectDepartment(AppState state) {
    return state.students.selectedDepartment;
  }

  static int selectYear(AppState state) {
    return state.students.selectedYear;
  }
}
