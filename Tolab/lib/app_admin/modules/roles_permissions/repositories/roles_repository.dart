import '../../../core/errors/app_exception.dart';
import '../models/permission_model.dart';
import '../models/role_model.dart';
import '../services/roles_service.dart';

class RolesDashboardBundle {
  const RolesDashboardBundle({
    required this.roles,
    required this.permissions,
    required this.assignableUsers,
    this.isFallback = false,
    this.notice,
  });

  final List<RoleModel> roles;
  final List<PermissionModel> permissions;
  final List<RoleUserAssignment> assignableUsers;
  final bool isFallback;
  final String? notice;
}

class RolesMutationResult {
  const RolesMutationResult({
    required this.bundle,
    required this.message,
    this.selectedRoleId,
  });

  final RolesDashboardBundle bundle;
  final String message;
  final String? selectedRoleId;
}

class RolesRepository {
  RolesRepository(this._service);

  final RolesService _service;

  List<RoleModel> _cachedRoles = const <RoleModel>[];
  List<PermissionModel> _cachedPermissions = const <PermissionModel>[];
  List<RoleUserAssignment> _cachedUsers = const <RoleUserAssignment>[];

  Future<RolesDashboardBundle> fetchDashboard({
    bool preferRemote = true,
  }) async {
    if (!preferRemote) {
      final seedBundle = _seedBundle();
      _cachedRoles = seedBundle.roles;
      _cachedPermissions = seedBundle.permissions;
      _cachedUsers = seedBundle.assignableUsers;
      return seedBundle;
    }

    try {
      final results = await Future.wait<Object>([
        _service.fetchRoles(),
        _service.fetchPermissions(),
      ]);
      final rolesSnapshot = results[0] as RolesSnapshot;
      final permissions = results[1] as List<PermissionModel>;
      final users = _resolveUsers(
        rolesSnapshot.assignableUsers,
        rolesSnapshot.roles,
      );
      final roles = _hydrateRoles(rolesSnapshot.roles, users);
      final resolvedPermissions = _hydratePermissions(permissions, roles);

      _cachedRoles = roles;
      _cachedPermissions = resolvedPermissions;
      _cachedUsers = users;

      return RolesDashboardBundle(
        roles: roles,
        permissions: resolvedPermissions,
        assignableUsers: users,
      );
    } catch (error) {
      if (_cachedRoles.isNotEmpty || _cachedPermissions.isNotEmpty) {
        return RolesDashboardBundle(
          roles: _cachedRoles,
          permissions: _cachedPermissions,
          assignableUsers: _cachedUsers,
          isFallback: true,
          notice:
              'Showing the last synced security data while the network recovers.',
        );
      }

      final seedBundle = _seedBundle();
      _cachedRoles = seedBundle.roles;
      _cachedPermissions = seedBundle.permissions;
      _cachedUsers = seedBundle.assignableUsers;

      if (error is AppException) {
        return RolesDashboardBundle(
          roles: seedBundle.roles,
          permissions: seedBundle.permissions,
          assignableUsers: seedBundle.assignableUsers,
          isFallback: true,
          notice: 'Using local fallback data until the API becomes reachable.',
        );
      }

      rethrow;
    }
  }

  Future<RolesMutationResult> createRole(RoleUpsertPayload payload) async {
    final createdRoleId = await _service.createRole(payload);
    final bundle = await fetchDashboard();
    final fallbackRoleId = bundle.roles
        .where((role) => role.slug == (payload.slug ?? _slugify(payload.name)))
        .map((role) => role.id)
        .firstOrNull;
    return RolesMutationResult(
      bundle: bundle,
      message: 'Role created successfully.',
      selectedRoleId: createdRoleId ?? fallbackRoleId,
    );
  }

  Future<RolesMutationResult> updateRole({
    required String roleId,
    required RoleUpsertPayload payload,
  }) async {
    await _service.updateRole(roleId, payload);
    final bundle = await fetchDashboard();
    return RolesMutationResult(
      bundle: bundle,
      message: 'Role updated successfully.',
      selectedRoleId: roleId,
    );
  }

  Future<RolesMutationResult> deleteRole(String roleId) async {
    await _service.deleteRole(roleId);
    final bundle = await fetchDashboard();
    return RolesMutationResult(
      bundle: bundle,
      message: 'Role removed successfully.',
      selectedRoleId: bundle.roles.isNotEmpty ? bundle.roles.first.id : null,
    );
  }

  Future<RolesMutationResult> createPermission(
    PermissionUpsertPayload payload, {
    String? selectedRoleId,
  }) async {
    await _service.createPermission(payload);
    final bundle = await fetchDashboard();
    return RolesMutationResult(
      bundle: bundle,
      message: 'Permission created successfully.',
      selectedRoleId: selectedRoleId,
    );
  }

  Future<RolesMutationResult> updatePermission({
    required String permissionId,
    required PermissionUpsertPayload payload,
    String? selectedRoleId,
  }) async {
    await _service.updatePermission(permissionId, payload);
    final bundle = await fetchDashboard();
    return RolesMutationResult(
      bundle: bundle,
      message: 'Permission updated successfully.',
      selectedRoleId: selectedRoleId,
    );
  }

  Future<RolesMutationResult> deletePermission({
    required String permissionId,
    String? selectedRoleId,
  }) async {
    await _service.deletePermission(permissionId);
    final bundle = await fetchDashboard();
    return RolesMutationResult(
      bundle: bundle,
      message: 'Permission deleted successfully.',
      selectedRoleId: selectedRoleId,
    );
  }

  Future<RolesMutationResult> assignPermissions({
    required String roleId,
    required List<String> permissionIds,
  }) async {
    await _service.assignPermissions(
      roleId: roleId,
      permissionIds: permissionIds,
    );
    final bundle = await fetchDashboard();
    return RolesMutationResult(
      bundle: bundle,
      message: 'Role permissions updated successfully.',
      selectedRoleId: roleId,
    );
  }

  Future<RolesMutationResult> assignUsers({
    required String roleId,
    required List<String> userIds,
  }) async {
    await _service.assignUsers(roleId: roleId, userIds: userIds);
    final bundle = await fetchDashboard();
    return RolesMutationResult(
      bundle: bundle,
      message: 'Role membership updated successfully.',
      selectedRoleId: roleId,
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

List<RoleModel> _hydrateRoles(
  List<RoleModel> roles,
  List<RoleUserAssignment> users,
) {
  final userMap = {for (final user in users) user.id: user};
  return roles
      .map((role) {
        final assignedUsers = role.userIds
            .map((userId) => userMap[userId])
            .whereType<RoleUserAssignment>()
            .toList(growable: false);
        return role.copyWith(
          userIds: assignedUsers.isNotEmpty
              ? assignedUsers.map((user) => user.id).toList(growable: false)
              : role.userIds,
          assignedUsers: assignedUsers.isNotEmpty
              ? assignedUsers
              : role.assignedUsers,
          membersCount: assignedUsers.isNotEmpty
              ? assignedUsers.length
              : role.membersCount,
        );
      })
      .toList(growable: false);
}

List<PermissionModel> _hydratePermissions(
  List<PermissionModel> permissions,
  List<RoleModel> roles,
) {
  return permissions
      .map((permission) {
        final roleIds = roles
            .where((role) => role.permissionIds.contains(permission.id))
            .map((role) => role.id)
            .toList(growable: false);
        return permission.copyWith(roleIds: roleIds);
      })
      .toList(growable: false);
}

List<RoleUserAssignment> _resolveUsers(
  List<RoleUserAssignment> fromApi,
  List<RoleModel> roles,
) {
  final users = <String, RoleUserAssignment>{
    for (final user in fromApi) user.id: user,
  };
  for (final role in roles) {
    for (final user in role.assignedUsers) {
      users[user.id] = user;
    }
  }
  final orderedUsers = users.values.toList(growable: false)
    ..sort(
      (left, right) =>
          left.name.toLowerCase().compareTo(right.name.toLowerCase()),
    );
  return orderedUsers;
}

RolesDashboardBundle _seedBundle() {
  final users = [
    const RoleUserAssignment(
      id: 'user-super-admin',
      name: 'Maya Hassan',
      email: 'maya.hassan@tolab.edu',
      department: 'Executive Office',
    ),
    const RoleUserAssignment(
      id: 'user-registrar',
      name: 'Omar Elsayed',
      email: 'omar.elsayed@tolab.edu',
      department: 'Registrar',
    ),
    const RoleUserAssignment(
      id: 'user-dean',
      name: 'Nour Fahmy',
      email: 'nour.fahmy@tolab.edu',
      department: 'Academic Affairs',
    ),
    const RoleUserAssignment(
      id: 'user-support',
      name: 'Salma Magdy',
      email: 'salma.magdy@tolab.edu',
      department: 'Student Services',
    ),
  ];

  final permissions = [
    PermissionModel(
      id: 'perm-users-view',
      name: 'View users',
      key: 'users_view',
      module: 'Users',
      action: PermissionActionKind.view,
      description: 'Browse staff and student records across the workspace.',
      isCore: true,
      updatedAt: DateTime(2026, 3, 28),
    ),
    PermissionModel(
      id: 'perm-users-manage',
      name: 'Manage users',
      key: 'users_manage',
      module: 'Users',
      action: PermissionActionKind.manage,
      description: 'Create, edit, suspend, and reset user access.',
      isCore: true,
      updatedAt: DateTime(2026, 3, 28),
    ),
    PermissionModel(
      id: 'perm-roles-view',
      name: 'View roles',
      key: 'roles_view',
      module: 'Security',
      action: PermissionActionKind.view,
      description: 'Inspect role coverage, assignments, and security posture.',
      isCore: true,
      updatedAt: DateTime(2026, 3, 28),
    ),
    PermissionModel(
      id: 'perm-roles-manage',
      name: 'Manage roles',
      key: 'roles_manage',
      module: 'Security',
      action: PermissionActionKind.manage,
      description: 'Create roles and assign permissions across modules.',
      isCore: true,
      updatedAt: DateTime(2026, 3, 28),
    ),
    PermissionModel(
      id: 'perm-enrollments-approve',
      name: 'Approve enrollments',
      key: 'enrollments_approve',
      module: 'Enrollments',
      action: PermissionActionKind.approve,
      description: 'Approve, reject, and review enrollment changes.',
      isCore: false,
      updatedAt: DateTime(2026, 3, 28),
    ),
    PermissionModel(
      id: 'perm-content-update',
      name: 'Publish content',
      key: 'content_update',
      module: 'Content',
      action: PermissionActionKind.update,
      description: 'Edit and publish course content for academic teams.',
      isCore: false,
      updatedAt: DateTime(2026, 3, 28),
    ),
    PermissionModel(
      id: 'perm-schedule-configure',
      name: 'Configure schedule',
      key: 'schedule_configure',
      module: 'Schedule',
      action: PermissionActionKind.configure,
      description: 'Manage calendar rules, conflicts, and session setup.',
      isCore: false,
      updatedAt: DateTime(2026, 3, 28),
    ),
  ];

  final roles = [
    RoleModel(
      id: 'role-super-admin',
      name: 'Super Admin',
      slug: 'super-admin',
      description:
          'Full platform authority for identity, configuration, and policy.',
      isSystem: true,
      permissionIds: permissions
          .map((permission) => permission.id)
          .toList(growable: false),
      userIds: <String>['user-super-admin'],
      assignedUsers: <RoleUserAssignment>[users.first],
      membersCount: 1,
      createdAt: DateTime(2026, 1, 5),
      updatedAt: DateTime(2026, 3, 28),
      colorHex: '2563EB',
    ),
    RoleModel(
      id: 'role-registrar',
      name: 'Registrar Lead',
      slug: 'registrar-lead',
      description:
          'Oversees enrollment approvals, compliance, and record integrity.',
      isSystem: false,
      permissionIds: <String>[
        'perm-users-view',
        'perm-roles-view',
        'perm-enrollments-approve',
      ],
      userIds: <String>['user-registrar'],
      assignedUsers: <RoleUserAssignment>[users[1]],
      membersCount: 1,
      createdAt: DateTime(2026, 1, 12),
      updatedAt: DateTime(2026, 3, 24),
      colorHex: '0EA5E9',
    ),
    RoleModel(
      id: 'role-academic-ops',
      name: 'Academic Operations',
      slug: 'academic-operations',
      description:
          'Coordinates content publishing, scheduling, and faculty operations.',
      isSystem: false,
      permissionIds: <String>[
        'perm-users-view',
        'perm-content-update',
        'perm-schedule-configure',
      ],
      userIds: <String>['user-dean', 'user-support'],
      assignedUsers: <RoleUserAssignment>[users[2], users[3]],
      membersCount: 2,
      createdAt: DateTime(2026, 2, 8),
      updatedAt: DateTime(2026, 3, 26),
      colorHex: '16A34A',
    ),
  ];

  final resolvedPermissions = _hydratePermissions(permissions, roles);
  return RolesDashboardBundle(
    roles: roles,
    permissions: resolvedPermissions,
    assignableUsers: users,
    isFallback: true,
    notice:
        'Using bundled fallback data until the Laravel API returns live security records.',
  );
}

String _slugify(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
