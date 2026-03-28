import '../../../core/helpers/json_types.dart';

enum PermissionActionKind {
  view,
  create,
  update,
  delete,
  manage,
  export,
  approve,
  configure,
  unknown,
}

extension PermissionActionKindX on PermissionActionKind {
  String get label => switch (this) {
    PermissionActionKind.view => 'View',
    PermissionActionKind.create => 'Create',
    PermissionActionKind.update => 'Update',
    PermissionActionKind.delete => 'Delete',
    PermissionActionKind.manage => 'Manage',
    PermissionActionKind.export => 'Export',
    PermissionActionKind.approve => 'Approve',
    PermissionActionKind.configure => 'Configure',
    PermissionActionKind.unknown => 'Access',
  };

  String get apiValue => switch (this) {
    PermissionActionKind.view => 'view',
    PermissionActionKind.create => 'create',
    PermissionActionKind.update => 'update',
    PermissionActionKind.delete => 'delete',
    PermissionActionKind.manage => 'manage',
    PermissionActionKind.export => 'export',
    PermissionActionKind.approve => 'approve',
    PermissionActionKind.configure => 'configure',
    PermissionActionKind.unknown => 'access',
  };

  static PermissionActionKind fromValue(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'view' || 'read' || 'list' => PermissionActionKind.view,
      'create' || 'store' => PermissionActionKind.create,
      'update' || 'edit' => PermissionActionKind.update,
      'delete' || 'remove' => PermissionActionKind.delete,
      'manage' || 'assign' => PermissionActionKind.manage,
      'export' => PermissionActionKind.export,
      'approve' => PermissionActionKind.approve,
      'configure' || 'settings' => PermissionActionKind.configure,
      _ => PermissionActionKind.unknown,
    };
  }
}

class PermissionModel {
  const PermissionModel({
    required this.id,
    required this.name,
    required this.key,
    required this.module,
    required this.action,
    required this.description,
    required this.isCore,
    required this.updatedAt,
    this.roleIds = const <String>[],
  });

  final String id;
  final String name;
  final String key;
  final String module;
  final PermissionActionKind action;
  final String description;
  final bool isCore;
  final DateTime updatedAt;
  final List<String> roleIds;

  PermissionModel copyWith({
    String? id,
    String? name,
    String? key,
    String? module,
    PermissionActionKind? action,
    String? description,
    bool? isCore,
    DateTime? updatedAt,
    List<String>? roleIds,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      module: module ?? this.module,
      action: action ?? this.action,
      description: description ?? this.description,
      isCore: isCore ?? this.isCore,
      updatedAt: updatedAt ?? this.updatedAt,
      roleIds: List<String>.unmodifiable(roleIds ?? this.roleIds),
    );
  }

  factory PermissionModel.fromJson(JsonMap json, {PermissionModel? fallback}) {
    final resolvedName = _stringValue(
      json['name'] ?? json['label'] ?? json['permission'],
      fallback?.name ?? 'Permission',
    );
    final resolvedModule = _stringValue(
      json['module'] ??
          json['group'] ??
          _moduleFromKey(json['slug'] ?? json['key'] ?? json['name']),
      fallback?.module ?? 'General',
    );
    return PermissionModel(
      id: _stringValue(json['id'], fallback?.id ?? 'permission'),
      name: resolvedName,
      key: _stringValue(
        json['slug'] ?? json['key'] ?? json['name'],
        fallback?.key ?? _slugify(resolvedName),
      ),
      module: resolvedModule,
      action: PermissionActionKindX.fromValue(
        _nullableString(json['action']) ??
            _actionFromKey(json['slug'] ?? json['key'] ?? json['name']),
      ),
      description: _stringValue(
        json['description'] ?? json['summary'],
        fallback?.description ?? 'Permission details are not available.',
      ),
      isCore: _boolValue(
        json['is_core'] ?? json['system'],
        fallback: fallback?.isCore ?? false,
      ),
      updatedAt: _dateValue(
        json['updated_at'],
        fallback?.updatedAt ?? DateTime.now(),
      ),
      roleIds: List<String>.unmodifiable(
        _stringList(json['role_ids'] ?? json['roles']),
      ),
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'slug': key,
    'module': module,
    'action': action.apiValue,
    'description': description,
    'is_core': isCore,
    'updated_at': updatedAt.toIso8601String(),
    'role_ids': roleIds,
  };
}

class PermissionUpsertPayload {
  const PermissionUpsertPayload({
    required this.name,
    required this.module,
    required this.action,
    required this.description,
    this.key,
    this.isCore = false,
  });

  final String name;
  final String? key;
  final String module;
  final PermissionActionKind action;
  final String description;
  final bool isCore;

  factory PermissionUpsertPayload.fromPermission(PermissionModel permission) {
    return PermissionUpsertPayload(
      name: permission.name,
      key: permission.key,
      module: permission.module,
      action: permission.action,
      description: permission.description,
      isCore: permission.isCore,
    );
  }

  JsonMap toJson() => <String, dynamic>{
    'name': name.trim(),
    'slug': (key == null || key!.trim().isEmpty) ? _slugify(name) : key!.trim(),
    'module': module.trim(),
    'action': action.apiValue,
    'description': description.trim(),
    'is_core': isCore,
  };
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is JsonMap) {
            return _nullableString(item['id'] ?? item['slug'] ?? item['name']);
          }
          return _nullableString(item);
        })
        .whereType<String>()
        .toList(growable: false);
  }
  return const <String>[];
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

String _stringValue(dynamic value, String fallback) {
  return _nullableString(value) ?? fallback;
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

DateTime _dateValue(dynamic value, DateTime fallback) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ?? fallback;
}

String _moduleFromKey(dynamic value) {
  final key = _nullableString(value);
  if (key == null || !key.contains('.')) return 'General';
  return key.split('.').first.replaceAll('_', ' ');
}

String? _actionFromKey(dynamic value) {
  final key = _nullableString(value);
  if (key == null) return null;
  final normalized = key.replaceAll(':', '.');
  if (!normalized.contains('.')) return null;
  return normalized.split('.').last;
}

String _slugify(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
