import 'package:equatable/equatable.dart';

enum EnrollmentStatus { pending, active, completed, dropped, failed }

class EnrollmentEntity extends Equatable {
  final String id;
  final String studentId;
  final String courseId;
  final EnrollmentStatus status;
  final DateTime enrollmentDate;
  final DateTime? completionDate;
  final double? grade;
  final String? letterGrade;
  final int attendancePercentage;
  final bool isDropped;
  final DateTime? dropDate;

  const EnrollmentEntity({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.status,
    required this.enrollmentDate,
    this.completionDate,
    this.grade,
    this.letterGrade,
    required this.attendancePercentage,
    required this.isDropped,
    this.dropDate,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        courseId,
        status,
        enrollmentDate,
        completionDate,
        grade,
        letterGrade,
        attendancePercentage,
        isDropped,
        dropDate,
      ];
}
