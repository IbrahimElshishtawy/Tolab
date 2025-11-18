import 'package:eduhub/features/auth/data/datasources/auth_fake_datasource.dart';
import 'package:eduhub/features/auth/data/models/user_model.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl(
    AuthFakeDataSource authFakeDataSource, {
    required this.remote,
    required this.local,
  });

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final model = await remote.login(email: email, password: password);
    await local.saveUser(model);
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    await local.clearUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await local.getCurrentUser();
    return user?.toEntity();
  }

  @override
  Future<UserEntity> refreshProfile() async {
    final user = await local.getCurrentUser();
    if (user == null) throw Exception('No user logged in');
    return user.toEntity();
  }
}
