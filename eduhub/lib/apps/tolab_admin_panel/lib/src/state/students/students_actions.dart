class LoadStudentsAction {}

class StudentsLoadedAction {
  final List<Map<String, dynamic>> students;
  StudentsLoadedAction(this.students);
}

class StudentsFailedAction {
  final String error;
  StudentsFailedAction(this.error);
}
