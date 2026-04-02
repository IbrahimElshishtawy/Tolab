class SessionUser {
  const SessionUser({
    required this.id,
    required this.fullName,
    required this.universityEmail,
    required this.roleType,
    required this.isActive,
    required this.permissions,
    required this.notificationEnabled,
    this.avatar,
    this.phone,
    this.language = 'en',
  });

  final int id;
  final String fullName;
  final String universityEmail;
  final String roleType;
  final bool isActive;
  final String? avatar;
  final String? phone;
  final bool notificationEnabled;
  final String language;
  final List<String> permissions;

  bool get isAdmin => roleType == 'admin';
  bool get isDoctor => roleType == 'doctor';
  bool get isAssistant => roleType == 'assistant';

  bool hasPermission(String permission) {
    return isAdmin || permissions.contains(permission);
  }

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      universityEmail: json['university_email']?.toString() ?? '',
      roleType: json['role_type']?.toString() ?? 'assistant',
      isActive: json['is_active'] == true,
      avatar: json['avatar']?.toString(),
      phone: json['phone']?.toString(),
      notificationEnabled: json['notification_enabled'] != false,
      language: json['language']?.toString() ?? 'en',
      permissions: (json['permissions'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'university_email': universityEmail,
      'role_type': roleType,
      'is_active': isActive,
      'avatar': avatar,
      'phone': phone,
      'notification_enabled': notificationEnabled,
      'language': language,
      'permissions': permissions,
    };
  }
}
