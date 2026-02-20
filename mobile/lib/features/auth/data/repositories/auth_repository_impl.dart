import 'package:firebase_auth/firebase_auth.dart';

import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> signInWithMicrosoft(String selectedRole) async {
    await remoteDataSource.signInWithMicrosoft();
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
