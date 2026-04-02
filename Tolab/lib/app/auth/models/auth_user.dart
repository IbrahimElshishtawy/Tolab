import '../../../app_admin/shared/models/auth_models.dart';
import '../../../app_doctor_assistant/core/models/session_user.dart';
import 'auth_role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    required this.permissions,
    this.avatarUrl,
    this.department,
    this.phone,
    this.notificationEnabled = true,
    this.language = 'en',
  });

  final String id;
  final String fullName;
  final String email;
  final AuthRole role;
  final bool isActive;
  final List<String> permissions;
  final String? avatarUrl;
  final String? department;
  final String? phone;
  final bool notificationEnabled;
  final String language;

  bool get isAdmin => role.isAdmin;

  bool get isDoctorAssistant => role.isDoctorAssistant;

  bool hasPermission(String permission) {
    return isAdmin || permissions.contains(permission);
  }

  factory AuthUser.fromSessionUser(SessionUser user) {
    return AuthUser(
      id: user.id.toString(),
      fullName: user.fullName,
      email: user.universityEmail,
      role: AuthRole.fromValue(user.roleType),
      isActive: user.isActive,
      permissions: List<String>.from(user.permissions),
      avatarUrl: user.avatar,
      phone: user.phone,
      notificationEnabled: user.notificationEnabled,
      language: user.language,
    );
  }

  factory AuthUser.fromAdminProfile(
    UserProfile user, {
    List<String> permissions = const <String>['*'],
  }) {
    return AuthUser(
      id: user.id,
      fullName: user.name,
      email: user.email,
      role: AuthRole.fromValue(user.role),
      isActive: user.status.trim().toLowerCase() != 'inactive',
      permissions: List<String>.from(permissions),
      avatarUrl: user.avatarUrl,
      department: user.department,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: AuthRole.fromValue(json['role']?.toString()),
      isActive: json['is_active'] != false,
      permissions: (json['permissions'] as List? ?? const <Object>[])
          .map((item) => item.toString())
          .toList(),
      avatarUrl: json['avatar_url']?.toString(),
      department: json['department']?.toString(),
      phone: json['phone']?.toString(),
      notificationEnabled: json['notification_enabled'] != false,
      language: json['language']?.toString() ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role.value,
      'is_active': isActive,
      'permissions': permissions,
      'avatar_url': avatarUrl,
      'department': department,
      'phone': phone,
      'notification_enabled': notificationEnabled,
      'language': language,
    };
  }

  SessionUser toSessionUser() {
    return SessionUser(
      id: int.tryParse(id) ?? 0,
      fullName: fullName,
      universityEmail: email,
      roleType: role.value,
      isActive: isActive,
      avatar: avatarUrl,
      phone: phone,
      notificationEnabled: notificationEnabled,
      language: language,
      permissions: permissions,
    );
  }

  UserProfile toAdminProfile() {
    return UserProfile(
      id: id,
      name: fullName,
      email: email,
      role: role.value,
      status: isActive ? 'active' : 'inactive',
      department: department,
      avatarUrl: avatarUrl,
    );
  }
}
