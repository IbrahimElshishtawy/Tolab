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

    //  مستخدم جديد
    if (!docSnap.exists) {
      final permissions = _defaultPermissionsForRole(selectedRole);

      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'role': selectedRole,
        'faculty': _extractFacultyFromEmail(user.email),
        'permissions': permissions,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return selectedRole;
    }

    // 👤 مستخدم موجود
    await docRef.update({'lastLoginAt': FieldValue.serverTimestamp()});

    final data = docSnap.data()!;
    return data['role'] as String;
  }

  // ===============================
  // Helpers
  // ===============================

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
