import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_role_ds.dart';

class AuthRoleDataSourceImpl implements AuthRoleDataSource {
  final FirebaseFirestore _firestore;

  AuthRoleDataSourceImpl(this._firestore);

  @override
  Future<String> resolveUserRole(User user, String selectedRole) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return selectedRole;
    }

    return doc.data()!['role'] as String;
  }
}
