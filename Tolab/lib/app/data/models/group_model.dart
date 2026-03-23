class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.memberCount = 0,
  });

  final String id;
  final String name;
  final String? description;
  final int memberCount;

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Group') as String,
      description: json['description'] as String?,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
    );
  }
}
