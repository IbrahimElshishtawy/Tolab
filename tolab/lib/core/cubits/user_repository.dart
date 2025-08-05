// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tolab/models/user_model.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// جلب بيانات المستخدم
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print("خطأ في جلب بيانات المستخدم: $e");
    }
    return null;
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUserDetails(String uid, UserModel user) async {
    try {
      await _firestore.collection('users').doc(uid).update(user.toJson());
    } catch (e) {
      print("خطأ في تحديث بيانات المستخدم: $e");
    }
  }

  /// حذف حساب المستخدم
  Future<void> deleteUserAccount(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      await _auth.currentUser?.delete();
    } catch (e) {
      print("خطأ في حذف الحساب: $e");
    }
  }
}
