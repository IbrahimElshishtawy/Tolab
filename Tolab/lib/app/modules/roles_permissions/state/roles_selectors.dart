import '../../../state/app_state.dart';
import '../models/permission_model.dart';
import '../models/role_model.dart';
import 'roles_state.dart';

class RolesOverviewMetrics {
  const RolesOverviewMetrics({
    required this.totalRoles,
    required this.systemRoles,
    required this.totalPermissions,
    required this.coveredUsers,
    required this.averagePermissionsPerRole,
  });

  final int totalRoles;
  final int systemRoles;
  final int totalPermissions;
  final int coveredUsers;
  final double averagePermissionsPerRole;
}

RolesState rolesStateOf(AppState state) => state.rolesState;

List<RoleModel> selectAllRoles(RolesState state) {
  return state.orderedRoleIds
      .map((id) => state.roleEntities[id])
      .whereType<RoleModel>()
      .toList(growable: false);
}

List<PermissionModel> selectAllPermissions(RolesState state) {
  return state.orderedPermissionIds
      .map((id) => state.permissionEntities[id])
      .whereType<PermissionModel>()
      .toList(growable: false);
}

RoleModel? selectSelectedRole(RolesState state) {
  final selectedRoleId = state.selectedRoleId;
  if (selectedRoleId == null) return null;
  return state.roleEntities[selectedRoleId];
}

List<String> selectPermissionModules(RolesState state) {
  final modules =
      {
        for (final permission in selectAllPermissions(state)) permission.module,
      }.toList()..sort(
        (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
      );
  return List<String>.unmodifiable(modules);
}

List<RoleModel> selectFilteredRoles(RolesState state) {
  final query = state.filters.searchQuery.trim().toLowerCase();
  final moduleFilter = state.filters.moduleFilter?.toLowerCase();
  final permissions = state.permissionEntities;
  final roles = selectAllRoles(state)
      .where((role) {
        if (!state.filters.showSystemRoles && role.isSystem) {
          return false;
        }

        final userMatches = role.assignedUsers.any((user) {
          final haystack = '${user.name} ${user.email} ${user.department}'
              .toLowerCase();
          return haystack.contains(query);
        });

        final permissionModules = role.permissionIds
            .map(
              (permissionId) => permissions[permissionId]?.module.toLowerCase(),
            )
            .whereType<String>()
            .toSet();

        final matchesQuery =
            query.isEmpty ||
            role.name.toLowerCase().contains(query) ||
            role.slug.toLowerCase().contains(query) ||
            role.description.toLowerCase().contains(query) ||
            userMatches ||
            role.permissionIds.any((permissionId) {
              final permission = permissions[permissionId];
              if (permission == null) return false;
              final haystack =
                  '${permission.name} ${permission.module} ${permission.description}'
                      .toLowerCase();
              return haystack.contains(query);
            });

        final matchesModule =
            moduleFilter == null || permissionModules.contains(moduleFilter);

        return matchesQuery && matchesModule;
      })
      .toList(growable: false);

  roles.sort((left, right) {
    return switch (state.filters.sortOption) {
      RolesSortOption.alphabetical => left.name.toLowerCase().compareTo(
        right.name.toLowerCase(),
      ),
      RolesSortOption.mostMembers => right.membersCount.compareTo(
        left.membersCount,
      ),
      RolesSortOption.mostPermissions => right.permissionIds.length.compareTo(
        left.permissionIds.length,
      ),
      RolesSortOption.recentlyUpdated => right.updatedAt.compareTo(
        left.updatedAt,
      ),
    };
  });
  return List<RoleModel>.unmodifiable(roles);
}

List<PermissionModel> selectFilteredPermissions(
  RolesState state, {
  String? searchQuery,
  String? moduleFilter,
}) {
  final query = (searchQuery ?? state.filters.searchQuery).trim().toLowerCase();
  final resolvedModuleFilter = (moduleFilter ?? state.filters.moduleFilter)
      ?.toLowerCase();
  final permissions = selectAllPermissions(state)
      .where((permission) {
        final matchesQuery =
            query.isEmpty ||
            permission.name.toLowerCase().contains(query) ||
            permission.key.toLowerCase().contains(query) ||
            permission.module.toLowerCase().contains(query) ||
            permission.description.toLowerCase().contains(query);
        final matchesModule =
            resolvedModuleFilter == null ||
            permission.module.toLowerCase() == resolvedModuleFilter;
        return matchesQuery && matchesModule;
      })
      .toList(growable: false);

  permissions.sort((left, right) {
    final moduleCompare = left.module.toLowerCase().compareTo(
      right.module.toLowerCase(),
    );
    if (moduleCompare != 0) return moduleCompare;
    final actionCompare = left.action.label.compareTo(right.action.label);
    if (actionCompare != 0) return actionCompare;
    return left.name.toLowerCase().compareTo(right.name.toLowerCase());
  });
  return List<PermissionModel>.unmodifiable(permissions);
}

RolesOverviewMetrics selectRolesOverviewMetrics(RolesState state) {
  final roles = selectAllRoles(state);
  final uniqueUsers = <String>{};
  for (final role in roles) {
    uniqueUsers.addAll(role.userIds);
  }

  final totalPermissions = selectAllPermissions(state).length;
  final averagePermissions = roles.isEmpty
      ? 0.0
      : roles.fold<int>(0, (sum, role) => sum + role.permissionIds.length) /
            roles.length;

  return RolesOverviewMetrics(
    totalRoles: roles.length,
    systemRoles: roles.where((role) => role.isSystem).length,
    totalPermissions: totalPermissions,
    coveredUsers: uniqueUsers.length,
    averagePermissionsPerRole: averagePermissions,
  );
}

List<RoleUserAssignment> selectAvailableUsersForRole(
  RolesState state,
  String? roleId,
) {
  final role = roleId == null ? null : state.roleEntities[roleId];
  final selectedUserIds = role?.userIds.toSet() ?? const <String>{};
  final assignedUsers = state.assignableUsers.toList(growable: false)
    ..sort((left, right) {
      final leftSelected = selectedUserIds.contains(left.id);
      final rightSelected = selectedUserIds.contains(right.id);
      if (leftSelected != rightSelected) {
        return leftSelected ? -1 : 1;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
  return List<RoleUserAssignment>.unmodifiable(assignedUsers);
}

bool isPermissionBusy(RolesState state, String roleId, String permissionId) {
  return state.pendingPermissionKeys.contains(
    _permissionBusyKey(roleId, permissionId),
  );
}

bool isUsersAssignmentBusy(RolesState state, String roleId) {
  return state.pendingUserKeys.contains(_userBusyKey(roleId));
}

String permissionBusyKeyFor(String roleId, String permissionId) =>
    _permissionBusyKey(roleId, permissionId);

String userBusyKeyFor(String roleId) => _userBusyKey(roleId);

double permissionCoverageForRole(RoleModel role, int totalPermissions) {
  if (totalPermissions <= 0) return 0;
  final coverage = role.permissionIds.length / totalPermissions;
  return coverage > 1 ? 1 : coverage;
}

String _permissionBusyKey(String roleId, String permissionId) =>
    '$roleId::$permissionId';

String _userBusyKey(String roleId) => '$roleId::users';
