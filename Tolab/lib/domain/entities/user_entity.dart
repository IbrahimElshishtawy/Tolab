import 'package:equatable/equatable.dart';

enum UserRole { student, staff, doctor, admin, superAdmin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? departmentId;
  final String? bio;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.departmentId,
    this.bio,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        profileImageUrl,
        role,
        isActive,
        createdAt,
        lastLoginAt,
        departmentId,
        bio,
      ];
}