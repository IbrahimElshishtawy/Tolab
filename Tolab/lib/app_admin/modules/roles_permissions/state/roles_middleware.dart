import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_dependencies.dart';
import '../../../state/app_state.dart';
import 'roles_actions.dart';
import 'roles_selectors.dart';

List<Middleware<AppState>> createRolesMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, RolesDashboardRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final bundle = await deps.rolesRepository.fetchDashboard(
          preferRemote: await deps.authService.hasUsableSession(),
        );
        store.dispatch(RolesDashboardLoadedAction(bundle));
      } catch (error) {
        store.dispatch(RolesDashboardFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, CreateRoleRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await _runMutation(
        store: store,
        actionRunner: () => deps.rolesRepository.createRole(action.payload),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, UpdateRoleRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await _runMutation(
        store: store,
        actionRunner: () => deps.rolesRepository.updateRole(
          roleId: action.roleId,
          payload: action.payload,
        ),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, DeleteRoleRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await _runMutation(
        store: store,
        actionRunner: () => deps.rolesRepository.deleteRole(action.roleId),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, CreatePermissionRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await _runMutation(
        store: store,
        actionRunner: () => deps.rolesRepository.createPermission(
          action.payload,
          selectedRoleId: store.state.rolesState.selectedRoleId,
        ),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, UpdatePermissionRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await _runMutation(
        store: store,
        actionRunner: () => deps.rolesRepository.updatePermission(
          permissionId: action.permissionId,
          payload: action.payload,
          selectedRoleId: store.state.rolesState.selectedRoleId,
        ),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, DeletePermissionRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await _runMutation(
        store: store,
        actionRunner: () => deps.rolesRepository.deletePermission(
          permissionId: action.permissionId,
          selectedRoleId: store.state.rolesState.selectedRoleId,
        ),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, AssignPermissionsRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await _runMutation(
        store: store,
        actionRunner: () => deps.rolesRepository.assignPermissions(
          roleId: action.roleId,
          permissionIds: action.permissionIds,
        ),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, ToggleRolePermissionRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      final role = store.state.rolesState.roleEntities[action.roleId];
      if (role == null) {
        const message = 'The selected role could not be found.';
        store.dispatch(const RolesMutationFailedAction(message: message));
        action.onError?.call(message);
        return;
      }

      final nextPermissionIds = <String>{...role.permissionIds};
      if (action.nextValue) {
        nextPermissionIds.add(action.permissionId);
      } else {
        nextPermissionIds.remove(action.permissionId);
      }
      final busyKey = permissionBusyKeyFor(action.roleId, action.permissionId);

      await _runMutation(
        store: store,
        permissionBusyKey: busyKey,
        actionRunner: () => deps.rolesRepository.assignPermissions(
          roleId: action.roleId,
          permissionIds: nextPermissionIds.toList(growable: false),
        ),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
    TypedMiddleware<AppState, AssignUsersRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      final busyKey = userBusyKeyFor(action.roleId);
      await _runMutation(
        store: store,
        userBusyKey: busyKey,
        actionRunner: () => deps.rolesRepository.assignUsers(
          roleId: action.roleId,
          userIds: action.userIds,
        ),
        onSuccess: action.onSuccess,
        onError: action.onError,
      );
    }).call,
  ];
}

Future<void> _runMutation({
  required Store<AppState> store,
  required Future<dynamic> Function() actionRunner,
  VoidCallback? onSuccess,
  void Function(String message)? onError,
  String? permissionBusyKey,
  String? userBusyKey,
}) async {
  store.dispatch(
    RolesMutationStartedAction(
      permissionBusyKey: permissionBusyKey,
      userBusyKey: userBusyKey,
    ),
  );
  try {
    final result = await actionRunner();
    store.dispatch(RolesMutationSucceededAction(result));
    onSuccess?.call();
  } catch (error) {
    final message = _messageOf(error);
    store.dispatch(
      RolesMutationFailedAction(
        message: message,
        permissionBusyKey: permissionBusyKey,
        userBusyKey: userBusyKey,
      ),
    );
    onError?.call(message);
  }
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
