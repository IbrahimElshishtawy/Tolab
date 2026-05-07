import 'package:tolab_fci/domain/entities/student_entity.dart';

class StudentModel {
  final String id;
  final String userId;
  final String studentId;
  final String departmentId;
  final int academicYear;
  final String status;
  final double gpa;
  final int totalCreditsCompleted;
  final DateTime enrollmentDate;
  final String? advisorId;
  final List<String> enrolledCourseIds;

  StudentModel({
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

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      studentId: json['studentId'] as String,
      departmentId: json['departmentId'] as String,
      academicYear: json['academicYear'] as int,
      status: json['status'] as String,
      gpa: (json['gpa'] as num).toDouble(),
      totalCreditsCompleted: json['totalCreditsCompleted'] as int? ?? 0,
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      advisorId: json['advisorId'] as String?,
      enrolledCourseIds:
          List<String>.from(json['enrolledCourseIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'studentId': studentId,
      'departmentId': departmentId,
      'academicYear': academicYear,
      'status': status,
      'gpa': gpa,
      'totalCreditsCompleted': totalCreditsCompleted,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'advisorId': advisorId,
      'enrolledCourseIds': enrolledCourseIds,
    };
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      userId: userId,
      studentId: studentId,
      departmentId: departmentId,
      academicYear: academicYear,
      status: _parseStatus(status),
      gpa: gpa,
      totalCreditsCompleted: totalCreditsCompleted,
      enrollmentDate: enrollmentDate,
      advisorId: advisorId,
      enrolledCourseIds: enrolledCourseIds,
    );
  }

  static StudentStatus _parseStatus(String status) {
    return StudentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => StudentStatus.active,
    );
  }
}
