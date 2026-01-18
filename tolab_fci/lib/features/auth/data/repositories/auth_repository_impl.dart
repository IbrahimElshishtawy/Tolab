import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';

import '../datasources/auth_remote_ds.dart';
import '../datasources/auth_role_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthRoleDataSource roleDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.roleDataSource,
  });

  @override
  Future<AuthUser> signInWithMicrosoft(String selectedRole) async {
    final userCredential = await remoteDataSource.signInWithMicrosoft();
    final user = userCredential.user;

    if (user == null || user.email == null) {
      throw Exception('Authentication failed');
    }

    final role = await roleDataSource.resolveUserRole(user, selectedRole);

    return AuthUser(uid: user.uid, email: user.email!, role: role);
  }

  @override
  User? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
