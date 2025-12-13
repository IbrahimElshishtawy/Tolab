// الطلاب - الإجراءات (Actions)
// students_actions.dart

class LoadStudentsAction {}

class FilterStudentsByYearAction {
  final int year;

  FilterStudentsByYearAction(this.year);
}

class FilterStudentsByDepartmentAction {
  final String department;

  FilterStudentsByDepartmentAction(this.department);
}
