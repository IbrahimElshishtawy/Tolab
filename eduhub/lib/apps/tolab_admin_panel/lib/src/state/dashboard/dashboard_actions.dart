class LoadDashboardDataAction {}

class DashboardDataLoadedAction {
  final int students;
  final int doctors;
  final int subjects;
  final int pending;
  final List<String> activity;

  DashboardDataLoadedAction({
    required this.students,
    required this.doctors,
    required this.subjects,
    required this.pending,
    required this.activity,
  });
}

class DashboardDataFailedAction {
  final String message;
  DashboardDataFailedAction(this.message);
}
