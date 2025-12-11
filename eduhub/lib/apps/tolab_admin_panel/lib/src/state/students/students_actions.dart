class LoadStudentsAction {}

class StudentsLoadedAction {
  final List<Map<String, dynamic>> data;
  StudentsLoadedAction(this.data);
}

class StudentsFailedAction {
  final String error;
  StudentsFailedAction(this.error);
}
