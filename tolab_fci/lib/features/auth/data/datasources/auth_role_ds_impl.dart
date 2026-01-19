import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_role_ds.dart';

class AuthRoleDataSourceImpl implements AuthRoleDataSource {
  final FirebaseFirestore _firestore;

  AuthRoleDataSourceImpl(this._firestore);

  @override
  Future<String> resolveUserRole(User user, String selectedRole) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnap = await docRef.get();

    final safeSelectedRole = _normalizeRole(selectedRole);

    if (!docSnap.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'role': safeSelectedRole,
        'faculty': _extractFacultyFromEmail(user.email),
        'permissions': _defaultPermissionsForRole(safeSelectedRole),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return safeSelectedRole;
    }

    final data = docSnap.data() ?? {};
    await docRef.update({'lastLoginAt': FieldValue.serverTimestamp()});

    final role = (data['role'] as String?)?.trim();
    if (role == null || role.isEmpty) {
      await docRef.update({'role': 'student'});
      return 'student';
    }

    return _normalizeRole(role);
  }

  // ===============================
  // Helpers
  // ===============================

  String _normalizeRole(String role) {
    final r = role.trim().toLowerCase();
    const allowed = ['student', 'doctor', 'ta', 'it'];
    return allowed.contains(r) ? r : 'student';
  }

  Map<String, bool> _defaultPermissionsForRole(String role) {
    switch (role) {
      case 'doctor':
        return {
          'canRead': true,
          'canWrite': true,
          'canApprove': true,
          'isAdmin': false,
        };
      case 'ta':
        return {
          'canRead': true,
          'canWrite': true,
          'canApprove': false,
          'isAdmin': false,
        };
      case 'it':
        return {
          'canRead': true,
          'canWrite': true,
          'canApprove': true,
          'isAdmin': true,
        };
      case 'student':
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
