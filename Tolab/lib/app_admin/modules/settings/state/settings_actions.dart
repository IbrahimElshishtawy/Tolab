import '../models/settings_models.dart';

class LoadSettingsAction {
  const LoadSettingsAction({this.silent = false});

  final bool silent;
}

class SettingsLoadedAction {
  const SettingsLoadedAction(this.bundle);

  final SettingsBundle bundle;
}

class SettingsLoadFailedAction {
  const SettingsLoadFailedAction(this.message);

  final String message;
}

class UpdateSettingsBundleAction {
  const UpdateSettingsBundleAction(this.bundle);

  final SettingsBundle bundle;
}

class SelectSettingsSectionAction {
  const SelectSettingsSectionAction(this.section);

  final SettingsSection section;
}

class ToggleThemeModeAction {
  const ToggleThemeModeAction();
}

class RevertSettingsChangesAction {
  const RevertSettingsChangesAction();
}

class SaveSettingsRequestedAction {
  const SaveSettingsRequestedAction();
}

class SettingsSaveSucceededAction {
  const SettingsSaveSucceededAction(this.result);

  final SettingsMutationResult result;
}

class SettingsSaveFailedAction {
  const SettingsSaveFailedAction(this.message);

  final String message;
}

class CreateSettingsBackupRequestedAction {
  const CreateSettingsBackupRequestedAction();
}

class RestoreSettingsBackupRequestedAction {
  const RestoreSettingsBackupRequestedAction(this.backupId);

  final String backupId;
}
