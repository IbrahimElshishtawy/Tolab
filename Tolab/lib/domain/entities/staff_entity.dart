import 'package:equatable/equatable.dart';

enum StaffRole { instructor, lecturer, assistant, coordinator, admin }

class StaffEntity extends Equatable {
  final String id;
  final String userId;
  final String staffId;
  final String departmentId;
  final StaffRole role;
  final String? officeLocation;
  final String? officeHours;
  final List<String> taughtCourseIds;
  final DateTime joinDate;
  final bool isActive;
  final String? specialization;
  final List<String> qualifications;

  const StaffEntity({
    required this.id,
    required this.userId,
    required this.staffId,
    required this.departmentId,
    required this.role,
    this.officeLocation,
    this.officeHours,
    required this.taughtCourseIds,
    required this.joinDate,
    required this.isActive,
    this.specialization,
    required this.qualifications,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        staffId,
        departmentId,
        role,
        officeLocation,
        officeHours,
        taughtCourseIds,
        joinDate,
        isActive,
        specialization,
        qualifications,
      ];
}
