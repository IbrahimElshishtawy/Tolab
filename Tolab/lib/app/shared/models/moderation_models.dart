class ModerationItem {
  const ModerationItem({
    required this.id,
    required this.type,
    required this.author,
    required this.groupName,
    required this.preview,
    required this.reportsCount,
    required this.status,
    required this.createdAtLabel,
  });

  final String id;
  final String type;
  final String author;
  final String groupName;
  final String preview;
  final int reportsCount;
  final String status;
  final String createdAtLabel;
}

class RolePermission {
  const RolePermission({
    required this.id,
    required this.role,
    required this.members,
    required this.permissions,
  });

  final String id;
  final String role;
  final int members;
  final Map<String, bool> permissions;
}
