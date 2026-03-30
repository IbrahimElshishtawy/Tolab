import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/helpers/json_types.dart';
import '../../../core/network/api_client.dart';
import '../models/permission_model.dart';
import '../models/role_model.dart';

class RolesSnapshot {
  const RolesSnapshot({required this.roles, required this.assignableUsers});

  final List<RoleModel> roles;
  final List<RoleUserAssignment> assignableUsers;
}

class RolesService {
  RolesService(this._apiClient);

  final ApiClient _apiClient;

  Future<RolesSnapshot> fetchRoles() async {
    await _ensureOnline();
    return _apiClient.get<RolesSnapshot>(
      '/roles',
      decoder: (json) {
        final rolesList = _extractList(json, ['roles', 'items', 'data']);
        final roles = rolesList.map(RoleModel.fromJson).toList(growable: false);
        final usersList = _extractList(json, [
          'assignable_users',
          'users',
          'user_options',
          'members',
        ]);
        final assignableUsers = usersList.isNotEmpty
            ? usersList.map(RoleUserAssignment.fromJson).toList(growable: false)
            : _extractUsersFromRoles(roles);
        return RolesSnapshot(roles: roles, assignableUsers: assignableUsers);
      },
    );
  }

  Future<List<PermissionModel>> fetchPermissions() async {
    await _ensureOnline();
    return _apiClient.get<List<PermissionModel>>(
      '/permissions',
      decoder: (json) {
        return _extractList(json, [
          'permissions',
          'items',
          'data',
        ]).map(PermissionModel.fromJson).toList(growable: false);
      },
    );
  }

  Future<String?> createRole(RoleUpsertPayload payload) async {
    await _ensureOnline();
    return _apiClient.post<String?>(
      '/roles',
      data: payload.toJson(),
      decoder: _extractEntityId,
    );
  }

  Future<void> updateRole(String roleId, RoleUpsertPayload payload) async {
    await _ensureOnline();
    await _apiClient.put<void>(
      '/roles/$roleId',
      data: payload.toJson(),
      decoder: (_) {},
    );
  }

  Future<void> deleteRole(String roleId) async {
    await _ensureOnline();
    await _apiClient.delete<void>('/roles/$roleId', decoder: (_) {});
  }

  Future<void> createPermission(PermissionUpsertPayload payload) async {
    await _ensureOnline();
    await _apiClient.post<void>(
      '/permissions',
      data: payload.toJson(),
      decoder: (_) {},
    );
  }

  Future<void> updatePermission(
    String permissionId,
    PermissionUpsertPayload payload,
  ) async {
    await _ensureOnline();
    await _apiClient.put<void>(
      '/permissions/$permissionId',
      data: payload.toJson(),
      decoder: (_) {},
    );
  }

  Future<void> deletePermission(String permissionId) async {
    await _ensureOnline();
    await _apiClient.delete<void>(
      '/permissions/$permissionId',
      decoder: (_) {},
    );
  }

  Future<void> assignPermissions({
    required String roleId,
    required List<String> permissionIds,
  }) async {
    await _ensureOnline();
    await _apiClient.post<void>(
      '/roles/$roleId/permissions',
      data: <String, dynamic>{'permission_ids': permissionIds},
      decoder: (_) {},
    );
  }

  Future<void> assignUsers({
    required String roleId,
    required List<String> userIds,
  }) async {
    await _ensureOnline();
    await _apiClient.post<void>(
      '/roles/$roleId/users',
      data: <String, dynamic>{'user_ids': userIds},
      decoder: (_) {},
    );
  }

  Future<void> _ensureOnline() async {
    final dynamic result = await Connectivity().checkConnectivity();
    if (result is ConnectivityResult && result == ConnectivityResult.none) {
      throw AppException(
        'You appear to be offline. Reconnect to sync roles and permissions.',
      );
    }
    if (result is List<ConnectivityResult> &&
        result.every((entry) => entry == ConnectivityResult.none)) {
      throw AppException(
        'You appear to be offline. Reconnect to sync roles and permissions.',
      );
    }
  }
}

String? _extractEntityId(dynamic json) {
  if (json is JsonMap) {
    return _stringValue(json['id'] ?? json['role_id'] ?? json['permission_id']);
  }
  return _stringValue(json);
}

List<JsonMap> _extractList(dynamic json, List<String> candidateKeys) {
  if (json is List) {
    return json.whereType<JsonMap>().toList(growable: false);
  }
  if (json is JsonMap) {
    for (final key in candidateKeys) {
      final value = json[key];
      if (value is List) {
        return value.whereType<JsonMap>().toList(growable: false);
      }
      if (value is JsonMap) {
        final nested = _extractList(value, candidateKeys);
        if (nested.isNotEmpty) return nested;
      }
    }
    return <JsonMap>[json];
  }
  return const <JsonMap>[];
}

List<RoleUserAssignment> _extractUsersFromRoles(List<RoleModel> roles) {
  final users = <String, RoleUserAssignment>{};
  for (final role in roles) {
    for (final user in role.assignedUsers) {
      users[user.id] = user;
    }
  }
  return users.values.toList(growable: false);
}

String? _stringValue(dynamic value) {
  final resolved = value?.toString().trim();
  if (resolved == null ||
      resolved.isEmpty ||
      resolved.toLowerCase() == 'null') {
    return null;
  }
  return resolved;
}
