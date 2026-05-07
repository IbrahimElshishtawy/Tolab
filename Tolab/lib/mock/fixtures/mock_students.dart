import 'package:tolab_fci/data/models/student_model.dart';
import 'package:tolab_fci/domain/entities/student_entity.dart';

class MockStudents {
  static final List<StudentModel> students = [
    StudentModel(
      id: 'student_001',
      userId: 'user_008',
      studentId: 'STU001',
      departmentId: 'dept_001',
      academicYear: 2,
      status: 'active',
      gpa: 3.75,
      totalCreditsCompleted: 45,
      enrollmentDate: DateTime(2023, 9, 1),
      advisorId: 'user_003',
      enrolledCourseIds: ['course_001', 'course_002', 'course_004'],
    ),
    StudentModel(
      id: 'student_002',
      userId: 'user_009',
      studentId: 'STU002',
      departmentId: 'dept_001',
      academicYear: 1,
      status: 'active',
      gpa: 3.45,
      totalCreditsCompleted: 30,
      enrollmentDate: DateTime(2024, 9, 1),
      advisorId: 'user_004',
      enrolledCourseIds: ['course_001', 'course_002'],
    ),
    StudentModel(
      id: 'student_003',
      userId: 'user_010',
      studentId: 'STU003',
      departmentId: 'dept_002',
      academicYear: 3,
      status: 'active',
      gpa: 3.85,
      totalCreditsCompleted: 75,
      enrollmentDate: DateTime(2022, 9, 1),
      advisorId: 'user_005',
      enrolledCourseIds: ['course_006', 'course_007', 'course_008'],
    ),
    StudentModel(
      id: 'student_004',
      userId: 'user_011',
      studentId: 'STU004',
      departmentId: 'dept_001',
      academicYear: 2,
      status: 'active',
      gpa: 3.55,
      totalCreditsCompleted: 48,
      enrollmentDate: DateTime(2023, 9, 1),
      advisorId: 'user_003',
      enrolledCourseIds: ['course_001', 'course_003', 'course_005'],
    ),
    StudentModel(
      id: 'student_005',
      userId: 'user_012',
      studentId: 'STU005',
      departmentId: 'dept_002',
      academicYear: 1,
      status: 'active',
      gpa: 3.65,
      totalCreditsCompleted: 28,
      enrollmentDate: DateTime(2024, 9, 1),
      advisorId: 'user_005',
      enrolledCourseIds: ['course_006', 'course_008'],
    ),
  ];

  static StudentEntity getStudentById(String id) {
    return students.firstWhere((s) => s.id == id).toEntity();
  }

  static StudentEntity getStudentByUserId(String userId) {
    return students.firstWhere((s) => s.userId == userId).toEntity();
  }

  static List<StudentEntity> getStudentsByDepartment(String departmentId) {
    return students
        .where((s) => s.departmentId == departmentId)
        .map((s) => s.toEntity())
        .toList();
  }

  static List<StudentEntity> getStudentsByAcademicYear(int year) {
    return students
        .where((s) => s.academicYear == year)
        .map((s) => s.toEntity())
        .toList();
  }

  static List<StudentEntity> getActiveStudents() {
    return students
        .where((s) => s.status == 'active')
        .map((s) => s.toEntity())
        .toList();
  }

  static List<StudentEntity> getAllStudents() {
    return students.map((s) => s.toEntity()).toList();
  }
}
