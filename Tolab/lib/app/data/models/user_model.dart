import 'dart:convert';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.role = 'student',
    this.department,
    this.level,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role;
  final String? department;
  final String? level;
  final bool isActive;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final studentProfile = json['student_profile'] as Map<String, dynamic>?;
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['username'] ?? 'Unknown User') as String,
      email: (json['email'] ?? '') as String,
      avatar: json['avatar_url'] as String? ?? json['avatar'] as String?,
      role: (json['role'] ?? 'student') as String,
      department:
          studentProfile?['department_name'] as String? ??
          json['department_name'] as String?,
      level: studentProfile?['level']?.toString() ?? json['level']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatar,
    'role': role,
    'department_name': department,
    'level': level,
    'is_active': isActive,
  };

  String toRawJson() => jsonEncode(toJson());

  factory UserModel.fromRawJson(String raw) =>
      UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
