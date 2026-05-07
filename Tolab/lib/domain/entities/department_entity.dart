import 'package:equatable/equatable.dart';

class DepartmentEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final String? headId;
  final int totalStudents;
  final int totalStaff;
  final List<String> courseIds;
  final bool isActive;
  final String? location;
  final String? phoneNumber;
  final String? email;

  const DepartmentEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    this.headId,
    required this.totalStudents,
    required this.totalStaff,
    required this.courseIds,
    required this.isActive,
    this.location,
    this.phoneNumber,
    this.email,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        headId,
        totalStudents,
        totalStaff,
        courseIds,
        isActive,
        location,
        phoneNumber,
        email,
      ];
}
