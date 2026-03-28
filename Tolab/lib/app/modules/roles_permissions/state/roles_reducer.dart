import '../../../shared/enums/load_status.dart';
import 'roles_actions.dart';
import 'roles_state.dart';

RolesState rolesReducer(RolesState state, dynamic action) {
  switch (action) {
    case RolesDashboardRequestedAction():
      return state.copyWith(
        status: action.silent ? LoadStatus.refreshing : LoadStatus.loading,
        clearError: true,
      );
    case RolesDashboardLoadedAction():
      final rolesMap = {for (final role in action.bundle.roles) role.id: role};
      final permissionsMap = {
        for (final permission in action.bundle.permissions)
          permission.id: permission,
      };
      final resolvedSelection =
          state.selectedRoleId != null &&
              rolesMap.containsKey(state.selectedRoleId)
          ? state.selectedRoleId
          : action.bundle.roles.isNotEmpty
          ? action.bundle.roles.first.id
          : null;

      return state.copyWith(
        status: LoadStatus.success,
        roleEntities: rolesMap,
        orderedRoleIds: action.bundle.roles
            .map((role) => role.id)
            .toList(growable: false),
        permissionEntities: permissionsMap,
        orderedPermissionIds: action.bundle.permissions
            .map((permission) => permission.id)
            .toList(growable: false),
        assignableUsers: action.bundle.assignableUsers,
        selectedRoleId: resolvedSelection,
        isUsingFallbackData: action.bundle.isFallback,
        feedbackMessage: action.bundle.notice,
        clearError: true,
        lastSyncedAt: DateTime.now(),
      );
    case RolesDashboardFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case RolesFiltersChangedAction():
      return state.copyWith(filters: action.filters);
    case RolesDashboardViewChangedAction():
      return state.copyWith(view: action.view);
    case RoleSelectedAction():
      return state.copyWith(selectedRoleId: action.roleId);
    case RolesMutationStartedAction():
      final permissionKeys = Set<String>.from(state.pendingPermissionKeys);
      final userKeys = Set<String>.from(state.pendingUserKeys);
      if (action.permissionBusyKey != null) {
        permissionKeys.add(action.permissionBusyKey!);
      }
      if (action.userBusyKey != null) {
        userKeys.add(action.userBusyKey!);
      }
      return state.copyWith(
        mutationStatus: LoadStatus.loading,
        pendingPermissionKeys: permissionKeys,
        pendingUserKeys: userKeys,
        clearFeedback: true,
      );
    case RolesMutationSucceededAction():
      final rolesMap = {
        for (final role in action.result.bundle.roles) role.id: role,
      };
      final permissionsMap = {
        for (final permission in action.result.bundle.permissions)
          permission.id: permission,
      };
      final selectedRoleId = action.result.selectedRoleId;
      final resolvedSelection =
          selectedRoleId != null && rolesMap.containsKey(selectedRoleId)
          ? selectedRoleId
          : state.selectedRoleId != null &&
                rolesMap.containsKey(state.selectedRoleId)
          ? state.selectedRoleId
          : action.result.bundle.roles.isNotEmpty
          ? action.result.bundle.roles.first.id
          : null;
      return state.copyWith(
        mutationStatus: LoadStatus.success,
        status: LoadStatus.success,
        roleEntities: rolesMap,
        orderedRoleIds: action.result.bundle.roles
            .map((role) => role.id)
            .toList(growable: false),
        permissionEntities: permissionsMap,
        orderedPermissionIds: action.result.bundle.permissions
            .map((permission) => permission.id)
            .toList(growable: false),
        assignableUsers: action.result.bundle.assignableUsers,
        isUsingFallbackData: action.result.bundle.isFallback,
        selectedRoleId: resolvedSelection,
        feedbackMessage: action.result.message,
        lastSyncedAt: DateTime.now(),
        clearError: true,
        clearBusyPermissionKeys: true,
        clearBusyUserKeys: true,
      );
    case RolesMutationFailedAction():
      final permissionKeys = Set<String>.from(state.pendingPermissionKeys);
      final userKeys = Set<String>.from(state.pendingUserKeys);
      if (action.permissionBusyKey != null) {
        permissionKeys.remove(action.permissionBusyKey);
      } else {
        permissionKeys.clear();
      }
      if (action.userBusyKey != null) {
        userKeys.remove(action.userBusyKey);
      } else {
        userKeys.clear();
      }
      return state.copyWith(
        mutationStatus: LoadStatus.failure,
        feedbackMessage: action.message,
        pendingPermissionKeys: permissionKeys,
        pendingUserKeys: userKeys,
      );
    case ClearRolesFeedbackAction():
      return state.copyWith(
        mutationStatus: LoadStatus.initial,
        clearFeedback: true,
      );
    default:
      return state;
  }
}
