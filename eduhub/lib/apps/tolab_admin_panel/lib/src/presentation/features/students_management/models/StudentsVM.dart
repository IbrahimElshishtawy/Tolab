import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

class StudentsVM {
  final List<Map<String, dynamic>> students;
  final bool canViewStudents;
  final bool canEditStudents;

  final String? department;
  final int? year;

  final ValueChanged<String?> onDepartmentChange;
  final ValueChanged<int?> onYearChange;

  StudentsVM({
    required this.students,
    required this.canViewStudents,
    required this.canEditStudents,
    required this.department,
    required this.year,
    required this.onDepartmentChange,
    required this.onYearChange,
  });

  static StudentsVM fromStore(Store<AppState> store) {
    return StudentsVM(
      students: selectFilteredStudents(store.state),
      canViewStudents: store.state.permissions.canViewStudents,
      canEditStudents: store.state.permissions.canEditStudents,
      department: store.state.students.selectedDepartment,
      year: store.state.students.selectedYear,
      onDepartmentChange: (d) => store.dispatch(FilterStudentsByDepartment(d)),
      onYearChange: (y) => store.dispatch(FilterStudentsByYear(y)),
    );
  }
}
