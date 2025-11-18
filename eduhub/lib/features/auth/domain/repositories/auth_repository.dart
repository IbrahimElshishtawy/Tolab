// features/auth/domain/repositories/auth_repository.dart

import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> refreshProfile();
}
