import '../models/user_model.dart';

class AuthFakeDataSource {
  // داتا ثابتة تمثل Users في النظام
  final List<_FakeUserRecord> _users = [
    _FakeUserRecord(
      email: 'admin@center.com',
      password: '123456',
      user: UserModel(
        id: '1',
        fullname: 'Owner / Admin',
        email: 'admin@center.com',
        role: 'admin',
      ),
    ),
    _FakeUserRecord(
      email: 'teacher@center.com',
      password: '123456',
      user: UserModel(
        id: '2',
        fullname: 'Math Teacher',
        email: 'teacher@center.com',
        role: 'teacher',
      ),
    ),
    _FakeUserRecord(
      email: 'student@center.com',
      password: '123456',
      user: UserModel(
        id: '3',
        fullname: 'Student One',
        email: 'student@center.com',
        role: 'student',
      ),
    ),
    _FakeUserRecord(
      email: 'parent@center.com',
      password: '123456',
      user: UserModel(
        id: '4',
        fullname: 'Parent One',
        email: 'parent@center.com',
        role: 'parent',
      ),
    ),
  ];

  UserModel? _currentUser;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final record = _users.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => throw Exception('Invalid email or password'),
    );

    _currentUser = record.user;
    return record.user;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  Future<UserModel> refreshProfile() async {
    if (_currentUser == null) {
      throw Exception('No current user');
    }
    return _currentUser!;
  }
}

class _FakeUserRecord {
  final String email;
  final String password;
  final UserModel user;

  _FakeUserRecord({
    required this.email,
    required this.password,
    required this.user,
  });
}
