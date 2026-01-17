import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ===============================
/// Auth Role Data Source
/// Firestore Only
/// ===============================
abstract class AuthRoleDataSource {
  Future<String> resolveUserRole(User user, String selectedRole);
}

/// ===============================
/// Implementation
/// ===============================
class AuthRoleDataSourceImpl implements AuthRoleDataSource {
  final FirebaseFirestore _firestore;

  AuthRoleDataSourceImpl(this._firestore);

  @override
  Future<String> resolveUserRole(User user, String selectedRole) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    // المستخدم موجود
    if (snapshot.exists) {
      final role = snapshot.data()?['role'] as String?;
      if (role == null || role.isEmpty) {
        throw Exception('User role is missing in Firestore');
      }
      return role;
    }

    //  مستخدم جديد
    final roleToSave = _isValidRole(selectedRole) ? selectedRole : 'student';

    await docRef.set({
      'email': user.email,
      'role': roleToSave,
      'faculty': _extractFaculty(user.email),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return roleToSave;
  }

  /// ===============================
  /// Helpers
  /// ===============================

  bool _isValidRole(String role) {
    return const ['student', 'doctor', 'ta', 'it'].contains(role);
  }

  String _extractFaculty(String? email) {
    if (email == null) return '';
    final parts = email.split('@');
    if (parts.length != 2) return '';

    final domainParts = parts[1].split('.');
    return domainParts.isNotEmpty ? domainParts.first : '';
  }
}
