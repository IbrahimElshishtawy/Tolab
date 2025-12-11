class LoaddoctorsAction {}

class doctorsLoadedAction {
  final dynamic data;
  doctorsLoadedAction(this.data);
}

class doctorsFailedAction {
  final String error;
  doctorsFailedAction(this.error);
}
