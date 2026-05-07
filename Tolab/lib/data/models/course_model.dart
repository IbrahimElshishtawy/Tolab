import 'package:tolab_fci/domain/entities/course_entity.dart';

class CourseModel {
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

  CourseModel({
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

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      departmentId: json['departmentId'] as String,
      creditHours: json['creditHours'] as int,
      maxStudents: json['maxStudents'] as int,
      enrolledStudents: json['enrolledStudents'] as int? ?? 0,
      instructorId: json['instructorId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      syllabus: json['syllabus'] as String?,
      prerequisites: List<String>.from(json['prerequisites'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'departmentId': departmentId,
      'creditHours': creditHours,
      'maxStudents': maxStudents,
      'enrolledStudents': enrolledStudents,
      'instructorId': instructorId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'syllabus': syllabus,
      'prerequisites': prerequisites,
    };
  }

  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      code: code,
      name: name,
      description: description,
      departmentId: departmentId,
      creditHours: creditHours,
      maxStudents: maxStudents,
      enrolledStudents: enrolledStudents,
      instructorId: instructorId,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      syllabus: syllabus,
      prerequisites: prerequisites,
    );
  }
}
