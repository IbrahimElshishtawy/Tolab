// lib/logic/role_logic.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleLogic {
  static Future<void> saveDetails({
    required String role,
    required String nationalId,
    String? name,
    String? year,
    String? department,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("لم يتم العثور على المستخدم");
    }

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'role': role.toLowerCase(),
      'nationalId': nationalId,
      if (name != null && name.isNotEmpty) 'name': name,
      if (role.toLowerCase() == 'student') 'year': year,
      if (role.toLowerCase() == 'student') 'department': department,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userData, SetOptions(merge: true));
  }
}
