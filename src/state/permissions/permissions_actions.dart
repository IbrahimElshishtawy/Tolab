class LoadpermissionsAction {}

class permissionsLoadedAction {
  final dynamic data;
  permissionsLoadedAction(this.data);
}

class permissionsFailedAction {
  final String error;
  permissionsFailedAction(this.error);
}
