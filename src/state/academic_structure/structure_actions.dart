class LoadstructureAction {}

class structureLoadedAction {
  final dynamic data;
  structureLoadedAction(this.data);
}

class structureFailedAction {
  final String error;
  structureFailedAction(this.error);
}
