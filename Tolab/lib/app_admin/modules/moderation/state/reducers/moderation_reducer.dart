import '../../../../shared/enums/load_status.dart';
import '../../models/moderation_models.dart';
import '../actions/moderation_actions.dart';
import '../models/moderation_state_models.dart';

ModerationState moderationReducer(ModerationState state, dynamic action) {
  switch (action) {
    case LoadModerationDashboardRequestedAction():
      return state.copyWith(
        status: action.silent ? LoadStatus.refreshing : LoadStatus.loading,
        clearError: true,
      );
    case ModerationDashboardLoadedAction():
      return state.copyWith(
        status: LoadStatus.success,
        groups: action.bundle.groups,
        posts: action.bundle.posts,
        comments: action.bundle.comments,
        messages: action.bundle.messages,
        reports: action.bundle.reports,
        moderators: action.bundle.moderators,
        permissionScopes: action.bundle.permissionScopes,
        roleProfiles: action.bundle.roleProfiles,
        notifications: action.bundle.notifications,
        analytics: action.bundle.analytics,
        isUsingFallbackData: action.bundle.isFallback,
        feedbackMessage: action.bundle.notice,
        clearError: true,
        clearSelection: true,
        lastSyncedAt: DateTime.now(),
      );
    case ModerationDashboardFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case ModerationTabChangedAction():
      return state.copyWith(activeTab: action.tab);
    case ModerationQueryChangedAction():
      return switch (action.section) {
        ModerationSectionKey.groups => state.copyWith(groupsQuery: action.query),
        ModerationSectionKey.posts => state.copyWith(postsQuery: action.query),
        ModerationSectionKey.comments =>
          state.copyWith(commentsQuery: action.query),
        ModerationSectionKey.messages =>
          state.copyWith(messagesQuery: action.query),
        ModerationSectionKey.reports =>
          state.copyWith(reportsQuery: action.query),
      };
    case ModerationSelectionToggledAction():
      return _toggleSelection(state, action);
    case ModerationVisibleSelectionChangedAction():
      return _toggleVisibleSelection(state, action);
    case ModerationSelectionClearedAction():
      return _clearSelection(state, action.section);
    case ModerationMutationStartedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.loading,
        clearFeedback: true,
      );
    case ModerationMutationSucceededAction():
      return state.copyWith(
        mutationStatus: LoadStatus.success,
        status: LoadStatus.success,
        groups: action.result.bundle.groups,
        posts: action.result.bundle.posts,
        comments: action.result.bundle.comments,
        messages: action.result.bundle.messages,
        reports: action.result.bundle.reports,
        moderators: action.result.bundle.moderators,
        permissionScopes: action.result.bundle.permissionScopes,
        roleProfiles: action.result.bundle.roleProfiles,
        notifications: action.result.bundle.notifications,
        analytics: action.result.bundle.analytics,
        isUsingFallbackData: action.result.bundle.isFallback,
        feedbackMessage: action.result.message,
        clearError: true,
        clearSelection: true,
        lastSyncedAt: DateTime.now(),
      );
    case ModerationMutationFailedAction():
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    case ClearModerationFeedbackAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearFeedback: true,
      );
    case StartModerationNotificationsPollingAction():
      return state.copyWith(isPollingNotifications: true);
    case StopModerationNotificationsPollingAction():
      return state.copyWith(isPollingNotifications: false);
    case RefreshModerationNotificationsRequestedAction():
      return state.copyWith(notificationsStatus: LoadStatus.loading);
    case ModerationNotificationsLoadedAction():
      return state.copyWith(
        notificationsStatus: LoadStatus.success,
        notifications: action.notifications,
      );
    case ModerationNotificationsFailedAction():
      return state.copyWith(
        notificationsStatus: LoadStatus.failure,
        feedbackMessage: action.message,
      );
    default:
      return state;
  }
}

ModerationState _toggleSelection(
  ModerationState state,
  ModerationSelectionToggledAction action,
) {
  final next = Set<String>.from(state.selectedIdsFor(action.section));
  if (action.selected) {
    next.add(action.itemId);
  } else {
    next.remove(action.itemId);
  }
  return _applySelectionSet(state, action.section, next);
}

ModerationState _toggleVisibleSelection(
  ModerationState state,
  ModerationVisibleSelectionChangedAction action,
) {
  final next = Set<String>.from(state.selectedIdsFor(action.section));
  if (action.selected) {
    next.addAll(action.visibleIds);
  } else {
    next.removeAll(action.visibleIds);
  }
  return _applySelectionSet(state, action.section, next);
}

ModerationState _clearSelection(
  ModerationState state,
  ModerationSectionKey section,
) {
  return _applySelectionSet(state, section, <String>{});
}

ModerationState _applySelectionSet(
  ModerationState state,
  ModerationSectionKey section,
  Set<String> next,
) {
  return switch (section) {
    ModerationSectionKey.groups => state.copyWith(selectedGroupIds: next),
    ModerationSectionKey.posts => state.copyWith(selectedPostIds: next),
    ModerationSectionKey.comments => state.copyWith(selectedCommentIds: next),
    ModerationSectionKey.messages => state.copyWith(selectedMessageIds: next),
    ModerationSectionKey.reports => state.copyWith(selectedReportIds: next),
  };
}
