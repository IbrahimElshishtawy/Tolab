class LoadassistantsAction {}

class assistantsLoadedAction {
  final dynamic data;
  assistantsLoadedAction(this.data);
}

class assistantsFailedAction {
  final String error;
  assistantsFailedAction(this.error);
}
