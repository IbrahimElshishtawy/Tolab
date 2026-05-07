import 'package:tolab_fci/domain/entities/user_entity.dart';
import 'package:tolab_fci/mock/fixtures/mock_users.dart';

abstract class UserRepository {
  Future<UserEntity> getUserById(String id);
  Future<List<UserEntity>> getUsersByRole(UserRole role);
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUser(UserEntity user);
}

class MockUserRepository implements UserRepository {
  @override
  Future<UserEntity> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockUsers.getUserById(id);
  }

  @override
  Future<List<UserEntity>> getUsersByRole(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockUsers.getUsersByRole(role);
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockUsers.getAllUsers();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockUsers.getUserById('user_008');
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
