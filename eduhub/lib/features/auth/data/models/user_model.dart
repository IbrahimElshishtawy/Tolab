// features/auth/data/models/user_model.dart

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

  /// تحويل الـ Model لـ JSON (اختياري)
  Map<String, dynamic> toJson() {
    return {'id': id, 'fullname': fullname, 'email': email, 'role': role};
  }

  /// Factory لو جبنا داتا من API لاحقاً
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      role: json['role'],
    );
  }
}

extension UserModelMapper on UserModel {
  UserEntity toEntity() {
    return UserEntity(id: id, fullName: fullname, email: email, role: role);
  }
}
