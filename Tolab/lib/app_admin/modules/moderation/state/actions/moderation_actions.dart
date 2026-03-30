import 'package:flutter/foundation.dart';

import '../../models/moderation_models.dart';
import '../models/moderation_state_models.dart';

class LoadModerationDashboardRequestedAction {
  const LoadModerationDashboardRequestedAction({this.silent = false});

  final bool silent;
}

class ModerationDashboardLoadedAction {
  const ModerationDashboardLoadedAction(this.bundle);

  final ModerationDashboardBundle bundle;
}

class ModerationDashboardFailedAction {
  const ModerationDashboardFailedAction(this.message);

  final String message;
}

class ModerationTabChangedAction {
  const ModerationTabChangedAction(this.tab);

  final ModerationWorkspaceTab tab;
}

class ModerationQueryChangedAction {
  const ModerationQueryChangedAction({
    required this.section,
    required this.query,
  });

  final ModerationSectionKey section;
  final ModerationTableQuery query;
}

class ModerationSelectionToggledAction {
  const ModerationSelectionToggledAction({
    required this.section,
    required this.itemId,
    required this.selected,
  });

  final ModerationSectionKey section;
  final String itemId;
  final bool selected;
}

class ModerationVisibleSelectionChangedAction {
  const ModerationVisibleSelectionChangedAction({
    required this.section,
    required this.visibleIds,
    required this.selected,
  });

  final ModerationSectionKey section;
  final List<String> visibleIds;
  final bool selected;
}

class ModerationSelectionClearedAction {
  const ModerationSelectionClearedAction(this.section);

  final ModerationSectionKey section;
}

class PerformModerationActionRequestedAction {
  const PerformModerationActionRequestedAction({
    required this.command,
    this.onSuccess,
    this.onError,
  });

  final ModerationActionCommand command;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class ModerationMutationStartedAction {
  const ModerationMutationStartedAction();
}

class ModerationMutationSucceededAction {
  const ModerationMutationSucceededAction(this.result);

  final ModerationMutationResult result;
}

class ModerationMutationFailedAction {
  const ModerationMutationFailedAction(this.message);

  final String message;
}

class ClearModerationFeedbackAction {
  const ClearModerationFeedbackAction();
}

class StartModerationNotificationsPollingAction {
  const StartModerationNotificationsPollingAction();
}

class StopModerationNotificationsPollingAction {
  const StopModerationNotificationsPollingAction();
}

class RefreshModerationNotificationsRequestedAction {
  const RefreshModerationNotificationsRequestedAction();
}

class ModerationNotificationsLoadedAction {
  const ModerationNotificationsLoadedAction(this.notifications);

  final List<ModerationNotificationItem> notifications;
}

class ModerationNotificationsFailedAction {
  const ModerationNotificationsFailedAction(this.message);

  final String message;
}
