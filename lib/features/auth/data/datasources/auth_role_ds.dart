import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_roles.dart';

/// ===============================
/// Auth Role Data Source
/// Firestore Only
/// ===============================
abstract class AuthRoleDataSource {
  /// 🔍 هل الإيميل موجود في النظام؟
  Future<bool> isEmailRegistered(String email);

  /// 🎭 تحديد / جلب دور المستخدم
  Future<String> resolveUserRole(User user, String selectedRole);
}

/// ===============================
/// Implementation
/// ===============================
class AuthRoleDataSourceImpl implements AuthRoleDataSource {
  final FirebaseFirestore _firestore;

  AuthRoleDataSourceImpl(this._firestore);

  /// ===============================
  /// 🔍 Check if email exists
  /// ===============================
  @override
  Future<bool> isEmailRegistered(String email) async {
    final normalizedEmail = email.toLowerCase().trim();

    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// ===============================
  /// 🎭 Resolve user role
  /// ===============================
  @override
  Future<String> resolveUserRole(User user, String selectedRole) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    final developerRole = AuthRoles.defaultDeveloperRole;

    if (snapshot.exists) {
      await docRef.update({
        'role': developerRole,
        'permissions': _defaultPermissionsForRole(developerRole),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      return developerRole;
    }

    final roleToSave = _isValidRole(selectedRole)
        ? selectedRole.trim().toLowerCase()
        : developerRole;

    await docRef.set({
      'uid': user.uid,
      'email': user.email?.toLowerCase(),
      'role': roleToSave,
      'faculty': _extractFaculty(user.email),
      'permissions': _defaultPermissionsForRole(roleToSave),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });

    return roleToSave;
  }

  /// ===============================
  /// Helpers
  /// ===============================

  bool _isValidRole(String role) {
    return AuthRoles.allowed.contains(role.trim().toLowerCase());
  }

  Map<String, bool> _defaultPermissionsForRole(String role) {
    switch (role) {
      case AuthRoles.doctor:
        return {
          'canRead': true,
          'canWrite': true,
          'canApprove': true,
          'isAdmin': false,
        };
      case AuthRoles.ta:
        return {
          'canRead': true,
          'canWrite': true,
          'canApprove': false,
          'isAdmin': false,
        };
      case AuthRoles.it:
        return {
          'canRead': true,
          'canWrite': true,
          'canApprove': true,
          'isAdmin': true,
        };
      case AuthRoles.student:
      default:
        return {
          'canRead': true,
          'canWrite': false,
          'canApprove': false,
          'isAdmin': false,
        };
    }
  }

  String _extractFaculty(String? email) {
    if (email == null) return '';
    final parts = email.split('@');
    if (parts.length != 2) return '';

    final domainParts = parts[1].split('.');
    return domainParts.isNotEmpty ? domainParts.first : '';
  }
}
