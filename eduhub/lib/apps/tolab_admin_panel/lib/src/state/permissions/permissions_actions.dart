// ignore_for_file: file_names

class LoadPermissionsAction {}

class UpdatePermissionsAction {
  final Map<String, bool> updates;
  UpdatePermissionsAction(this.updates);
}

class PermissionsLoadedAction {
  final Map<String, bool> permissions;
  PermissionsLoadedAction(this.permissions);
}

class PermissionsFailedAction {
  final String error;
  PermissionsFailedAction(this.error);
}
