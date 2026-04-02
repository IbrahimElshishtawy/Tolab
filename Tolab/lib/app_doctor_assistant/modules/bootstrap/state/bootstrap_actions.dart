class BootstrapStartedAction {}

class BootstrapCompletedAction {}

class BootstrapFailedAction {
  BootstrapFailedAction(this.message);

  final String message;
}
