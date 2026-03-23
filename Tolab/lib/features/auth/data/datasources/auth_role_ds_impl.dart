import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_roles.dart';
import 'auth_role_ds.dart';

class AuthRoleDataSourceImpl implements AuthRoleDataSource {
  final FirebaseFirestore _firestore;

  AuthRoleDataSourceImpl(this._firestore);

  /// ===============================
  /// 🔍 Check if email is registered
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
    final docSnap = await docRef.get();
    final safeSelectedRole = _normalizeRole(selectedRole);

    if (docSnap.exists) {
      final data = docSnap.data() ?? {};
      final storedRole = _normalizeRole((data['role'] as String?) ?? '');

      await docRef.update({
        'role': storedRole,
        'permissions': _defaultPermissionsForRole(storedRole),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      return storedRole;
    }

    await docRef.set({
      'uid': user.uid,
      'email': user.email?.toLowerCase(),
      'role': safeSelectedRole,
      'faculty': _extractFacultyFromEmail(user.email),
      'permissions': _defaultPermissionsForRole(safeSelectedRole),
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });

    return safeSelectedRole;
  }

  // ===============================
  // Helpers
  // ===============================

  String _normalizeRole(String role) {
    final normalized = role.trim().toLowerCase();
    return AuthRoles.allowed.contains(normalized)
        ? normalized
        : AuthRoles.defaultRole;
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

  String _extractFacultyFromEmail(String? email) {
    if (email == null) return 'unknown';

    // مثال: name@fci.tanta.edu.eg
    if (email.contains('@fci.')) return 'fci';
    if (email.contains('@eng.')) return 'eng';

    return 'general';
  }
}
