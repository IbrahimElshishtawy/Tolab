import 'package:eduhub/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String fullname;
  final String email;
  final String role;
  UserModel({
    required this.id,
    required this.fullname,
    required this.email,
    required this.role,
  });
}

// mdel user using dart

extension UserModelMapper on UserModel {
  UserEntity toEntity() {
    return UserEntity(id: id, fullName: fullname, email: email, role: role);
  }
}
//3.1. Mapper لـ Entity