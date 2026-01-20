import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';
import '../datasources/auth_role_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthRoleDataSource roleDataSource;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.roleDataSource,
    required this.firestore,
  });

  /// ===============================
  /// 🔍 Check if email is registered
  /// ===============================
  @override
  Future<bool> isEmailRegistered(String email) async {
    final normalizedEmail = email.toLowerCase().trim();

    final query = await firestore
        .collection('users')
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// ===============================
  /// 🔐 Microsoft Sign In
  /// ===============================
  @override
  Future<void> signInWithMicrosoft(String selectedRole) async {
    // ❗ لا نحدد Role هنا
    // ❗ لا نعمل LoginSuccess هنا
    // Firebase Auth Listener هو المسؤول

    await remoteDataSource.signInWithMicrosoft();
  }

  /// ===============================
  /// 👤 Current Firebase User
  /// ===============================
  @override
  User? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  /// ===============================
  /// 🚪 Logout
  /// ===============================
  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
