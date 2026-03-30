import '../../../core/helpers/json_types.dart';

class RoleUserAssignment {
  const RoleUserAssignment({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    this.avatarLabel,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String email;
  final String department;
  final String? avatarLabel;
  final bool isActive;

  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
        .toUpperCase();
  }

  factory RoleUserAssignment.fromJson(JsonMap json) {
    return RoleUserAssignment(
      id: _stringValue(json['id'], 'user'),
      name: _stringValue(
        json['name'] ?? json['full_name'] ?? json['username'],
        'University user',
      ),
      email: _stringValue(json['email'], 'user@tolab.edu'),
      department: _stringValue(
        json['department'] ??
            json['department_name'] ??
            json['faculty'] ??
            json['unit'],
        'Administration',
      ),
      avatarLabel: _nullableString(json['avatar_label']),
      isActive: _boolValue(json['is_active'], fallback: true),
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'department': department,
    'avatar_label': avatarLabel,
    'is_active': isActive,
  };
}

class RoleModel {
  const RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.isSystem,
    required this.permissionIds,
    required this.userIds,
    required this.assignedUsers,
    required this.membersCount,
    required this.createdAt,
    required this.updatedAt,
    this.colorHex = '2563EB',
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final bool isSystem;
  final List<String> permissionIds;
  final List<String> userIds;
  final List<RoleUserAssignment> assignedUsers;
  final int membersCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String colorHex;

  String get membersLabel =>
      membersCount == 1 ? '1 member' : '$membersCount members';

  RoleModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    bool? isSystem,
    List<String>? permissionIds,
    List<String>? userIds,
    List<RoleUserAssignment>? assignedUsers,
    int? membersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? colorHex,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      isSystem: isSystem ?? this.isSystem,
      permissionIds: List<String>.unmodifiable(
        permissionIds ?? this.permissionIds,
      ),
      userIds: List<String>.unmodifiable(userIds ?? this.userIds),
      assignedUsers: List<RoleUserAssignment>.unmodifiable(
        assignedUsers ?? this.assignedUsers,
      ),
      membersCount: membersCount ?? this.membersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  factory RoleModel.fromJson(
    JsonMap json, {
    RoleModel? fallback,
    List<RoleUserAssignment> fallbackUsers = const <RoleUserAssignment>[],
  }) {
    final users = _mapList(
      json['users'],
    ).map(RoleUserAssignment.fromJson).toList(growable: false);
    final permissions = _stringList(
      json['permission_ids'] ?? json['permissions'] ?? json['permission_names'],
    );

    return RoleModel(
      id: _stringValue(json['id'], fallback?.id ?? 'role'),
      name: _stringValue(
        json['name'] ?? json['title'],
        fallback?.name ?? 'Role',
      ),
      slug: _stringValue(
        json['slug'] ?? json['key'] ?? json['guard_name'],
        fallback?.slug ?? _slugify(_stringValue(json['name'], 'role')),
      ),
      description: _stringValue(
        json['description'] ?? json['summary'],
        fallback?.description ?? 'Role description is not available yet.',
      ),
      isSystem: _boolValue(
        json['is_system'] ?? json['system'],
        fallback: fallback?.isSystem ?? false,
      ),
      permissionIds: permissions.isEmpty
          ? List<String>.unmodifiable(
              fallback?.permissionIds ?? const <String>[],
            )
          : List<String>.unmodifiable(permissions),
      userIds: users.isNotEmpty
          ? List<String>.unmodifiable(users.map((user) => user.id))
          : List<String>.unmodifiable(
              _stringList(json['user_ids']).isNotEmpty
                  ? _stringList(json['user_ids'])
                  : fallback?.userIds ??
                        fallbackUsers
                            .map((user) => user.id)
                            .toList(growable: false),
            ),
      assignedUsers: List<RoleUserAssignment>.unmodifiable(
        users.isNotEmpty
            ? users
            : fallback?.assignedUsers.isNotEmpty == true
            ? fallback!.assignedUsers
            : fallbackUsers,
      ),
      membersCount: _intValue(
        json['members_count'] ?? json['users_count'] ?? json['member_count'],
        fallback:
            fallback?.membersCount ??
            (users.isNotEmpty ? users.length : fallbackUsers.length),
      ),
      createdAt: _dateValue(
        json['created_at'],
        fallback?.createdAt ?? DateTime.now(),
      ),
      updatedAt: _dateValue(
        json['updated_at'],
        fallback?.updatedAt ?? DateTime.now(),
      ),
      colorHex: _stringValue(
        json['color_hex'] ?? json['color'] ?? json['accent_color'],
        fallback?.colorHex ?? '2563EB',
      ).replaceAll('#', ''),
    );
  }
}

class RoleUpsertPayload {
  const RoleUpsertPayload({
    required this.name,
    required this.description,
    required this.colorHex,
    this.slug,
    this.isSystem = false,
  });

  final String name;
  final String? slug;
  final String description;
  final String colorHex;
  final bool isSystem;

  factory RoleUpsertPayload.fromRole(RoleModel role) {
    return RoleUpsertPayload(
      name: role.name,
      slug: role.slug,
      description: role.description,
      colorHex: role.colorHex,
      isSystem: role.isSystem,
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'name': name.trim(),
    'slug': (slug == null || slug!.trim().isEmpty)
        ? _slugify(name)
        : slug!.trim(),
    'description': description.trim(),
    'color_hex': colorHex.replaceAll('#', '').trim(),
    'is_system': isSystem,
  };
}

List<JsonMap> _mapList(dynamic value) {
  if (value is List) {
    return value.whereType<JsonMap>().toList(growable: false);
  }
  return const <JsonMap>[];
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is JsonMap) {
            return _nullableString(item['id'] ?? item['name'] ?? item['slug']);
          }
          return _nullableString(item);
        })
        .whereType<String>()
        .toList(growable: false);
  }
  final stringValue = _nullableString(value);
  if (stringValue == null) return const <String>[];
  if (!stringValue.contains(',')) return <String>[stringValue];
  return stringValue
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

String _stringValue(dynamic value, String fallback) {
  final resolved = _nullableString(value);
  return resolved ?? fallback;
}

String? _nullableString(dynamic value) {
  final resolved = value?.toString().trim();
  if (resolved == null ||
      resolved.isEmpty ||
      resolved.toLowerCase() == 'null') {
    return null;
  }
  return resolved;
}

bool _boolValue(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  final resolved = _nullableString(value)?.toLowerCase();
  return switch (resolved) {
    '1' || 'true' || 'yes' => true,
    '0' || 'false' || 'no' => false,
    _ => fallback,
  };
}

int _intValue(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime _dateValue(dynamic value, DateTime fallback) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ?? fallback;
}

String _slugify(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
