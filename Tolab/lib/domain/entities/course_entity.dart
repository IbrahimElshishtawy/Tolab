import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String description;
  final String departmentId;
  final int creditHours;
  final int maxStudents;
  final int enrolledStudents;
  final String instructorId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? syllabus;
  final List<String> prerequisites;

  const CourseEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.departmentId,
    required this.creditHours,
    required this.maxStudents,
    required this.enrolledStudents,
    required this.instructorId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.syllabus,
    required this.prerequisites,
  });

  bool get isFull => enrolledStudents >= maxStudents;
  bool get hasAvailableSeats => enrolledStudents < maxStudents;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        departmentId,
        creditHours,
        maxStudents,
        enrolledStudents,
        instructorId,
        startDate,
        endDate,
        isActive,
        syllabus,
        prerequisites,
      ];
}
