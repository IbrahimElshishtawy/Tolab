class LoadDoctorsAction {}

class DoctorsLoadedAction {
  final List<Map<String, dynamic>> data;
  DoctorsLoadedAction(this.data);
}

class DoctorsFailedAction {
  final String error;
  DoctorsFailedAction(this.error);
}
