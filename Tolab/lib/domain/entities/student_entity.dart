import 'package:equatable/equatable.dart';

enum StudentStatus { active, inactive, graduated, suspended }

class StudentEntity extends Equatable {
  final String id;
  final String userId;
  final String studentId;
  final String departmentId;
  final int academicYear;
  final StudentStatus status;
  final double gpa;
  final int totalCreditsCompleted;
  final DateTime enrollmentDate;
  final String? advisorId;
  final List<String> enrolledCourseIds;

  const StudentEntity({
    required this.id,
    required this.userId,
    required this.studentId,
    required this.departmentId,
    required this.academicYear,
    required this.status,
    required this.gpa,
    required this.totalCreditsCompleted,
    required this.enrollmentDate,
    this.advisorId,
    required this.enrolledCourseIds,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        studentId,
        departmentId,
        academicYear,
        status,
        gpa,
        totalCreditsCompleted,
        enrollmentDate,
        advisorId,
        enrolledCourseIds,
      ];
}
