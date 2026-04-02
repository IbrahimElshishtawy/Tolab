class UpdateSettingsAction {
  UpdateSettingsAction(this.payload);

  final Map<String, dynamic> payload;
}

class UpdateSettingsFailureAction {
  UpdateSettingsFailureAction(this.message);

  final String message;
}
