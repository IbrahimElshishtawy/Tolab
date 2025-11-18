// features/auth/data/datasources/auth_local_datasource.dart

import '../models/user_model.dart';

class AuthLocalDataSource {
  UserModel? _cachedUser;


  Future<void> saveUser(UserModel user) async {
    _cachedUser = user;
  }

  Future<UserModel?> getCurrentUser() async {
    return _cachedUser;
  }

  Future<void> clearUser() async {
    _cachedUser = null;
  }
}
