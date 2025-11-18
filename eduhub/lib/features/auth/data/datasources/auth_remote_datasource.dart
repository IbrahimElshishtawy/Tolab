// features/auth/data/datasources/auth_remote_datasource.dart

import 'dart:async';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  final List<_RemoteUserRecord> _users = [
    _RemoteUserRecord(
      email: 'admin@center.com',
      password: '123456',
      user: UserModel(
        id: '1',
        fullname: 'Admin User',
        email: 'admin@center.com',
        role: 'admin',
      ),
    ),
    _RemoteUserRecord(
      email: 'teacher@center.com',
      password: '123456',
      user: UserModel(
        id: '2',
        fullname: 'Teacher User',
        email: 'teacher@center.com',
        role: 'teacher',
      ),
    ),
    _RemoteUserRecord(
      email: 'student@center.com',
      password: '123456',
      user: UserModel(
        id: '3',
        fullname: 'Student User',
        email: 'student@center.com',
        role: 'student',
      ),
    ),
    _RemoteUserRecord(
      email: 'parent@center.com',
      password: '123456',
      user: UserModel(
        id: '4',
        fullname: 'Parent User',
        email: 'parent@center.com',
        role: 'parent',
      ),
    ),
  ];

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final record = _users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => throw Exception('Invalid credentials'),
    );

    return record.user;
  }
}

class _RemoteUserRecord {
  final String email;
  final String password;
  final UserModel user;

  _RemoteUserRecord({
    required this.email,
    required this.password,
    required this.user,
  });
}
