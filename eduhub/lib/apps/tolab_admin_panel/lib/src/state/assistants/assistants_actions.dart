class LoadAssistantsAction {}

class AssistantsLoadedAction {
  final List<Map<String, dynamic>> data;
  AssistantsLoadedAction(this.data);
}

class AssistantsFailedAction {
  final String error;
  AssistantsFailedAction(this.error);
}
