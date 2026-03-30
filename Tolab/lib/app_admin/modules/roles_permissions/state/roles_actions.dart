import 'package:flutter/foundation.dart';

import '../models/permission_model.dart';
import '../models/role_model.dart';
import '../repositories/roles_repository.dart';
import 'roles_state.dart';

class RolesDashboardRequestedAction {
  const RolesDashboardRequestedAction({this.silent = false});

  final bool silent;
}

class RolesDashboardLoadedAction {
  const RolesDashboardLoadedAction(this.bundle);

  final RolesDashboardBundle bundle;
}

class RolesDashboardFailedAction {
  const RolesDashboardFailedAction(this.message);

  final String message;
}

class RolesFiltersChangedAction {
  const RolesFiltersChangedAction(this.filters);

  final RolesFilters filters;
}

class RolesDashboardViewChangedAction {
  const RolesDashboardViewChangedAction(this.view);

  final RolesDashboardView view;
}

class RoleSelectedAction {
  const RoleSelectedAction(this.roleId);

  final String roleId;
}

class CreateRoleRequestedAction {
  const CreateRoleRequestedAction({
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final RoleUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class UpdateRoleRequestedAction {
  const UpdateRoleRequestedAction({
    required this.roleId,
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final String roleId;
  final RoleUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class DeleteRoleRequestedAction {
  const DeleteRoleRequestedAction({
    required this.roleId,
    this.onSuccess,
    this.onError,
  });

  final String roleId;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class CreatePermissionRequestedAction {
  const CreatePermissionRequestedAction({
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final PermissionUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class UpdatePermissionRequestedAction {
  const UpdatePermissionRequestedAction({
    required this.permissionId,
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final String permissionId;
  final PermissionUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class DeletePermissionRequestedAction {
  const DeletePermissionRequestedAction({
    required this.permissionId,
    this.onSuccess,
    this.onError,
  });

  final String permissionId;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class AssignPermissionsRequestedAction {
  const AssignPermissionsRequestedAction({
    required this.roleId,
    required this.permissionIds,
    this.onSuccess,
    this.onError,
  });

  final String roleId;
  final List<String> permissionIds;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class ToggleRolePermissionRequestedAction {
  const ToggleRolePermissionRequestedAction({
    required this.roleId,
    required this.permissionId,
    required this.nextValue,
    this.onSuccess,
    this.onError,
  });

  final String roleId;
  final String permissionId;
  final bool nextValue;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class AssignUsersRequestedAction {
  const AssignUsersRequestedAction({
    required this.roleId,
    required this.userIds,
    this.onSuccess,
    this.onError,
  });

  final String roleId;
  final List<String> userIds;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class RolesMutationStartedAction {
  const RolesMutationStartedAction({this.permissionBusyKey, this.userBusyKey});

  final String? permissionBusyKey;
  final String? userBusyKey;
}

class RolesMutationSucceededAction {
  const RolesMutationSucceededAction(this.result);

  final RolesMutationResult result;
}

class RolesMutationFailedAction {
  const RolesMutationFailedAction({
    required this.message,
    this.permissionBusyKey,
    this.userBusyKey,
  });

  final String message;
  final String? permissionBusyKey;
  final String? userBusyKey;
}

class ClearRolesFeedbackAction {
  const ClearRolesFeedbackAction();
}
