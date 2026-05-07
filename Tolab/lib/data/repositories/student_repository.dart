import 'package:tolab_fci/domain/entities/student_entity.dart';
import 'package:tolab_fci/mock/fixtures/mock_students.dart';

abstract class StudentRepository {
  Future<StudentEntity> getStudentById(String id);
  Future<StudentEntity> getStudentByUserId(String userId);
  Future<List<StudentEntity>> getStudentsByDepartment(String departmentId);
  Future<List<StudentEntity>> getStudentsByAcademicYear(int year);
  Future<List<StudentEntity>> getActiveStudents();
  Future<List<StudentEntity>> getAllStudents();
  Future<void> createStudent(StudentEntity student);
  Future<void> updateStudent(StudentEntity student);
  Future<void> deleteStudent(String id);
}

class MockStudentRepository implements StudentRepository {
  @override
  Future<StudentEntity> getStudentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockStudents.getStudentById(id);
  }

  @override
  Future<StudentEntity> getStudentByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockStudents.getStudentByUserId(userId);
  }

  @override
  Future<List<StudentEntity>> getStudentsByDepartment(
      String departmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockStudents.getStudentsByDepartment(departmentId);
  }

  @override
  Future<List<StudentEntity>> getStudentsByAcademicYear(int year) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockStudents.getStudentsByAcademicYear(year);
  }

  @override
  Future<List<StudentEntity>> getActiveStudents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockStudents.getActiveStudents();
  }

  @override
  Future<List<StudentEntity>> getAllStudents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockStudents.getAllStudents();
  }

  @override
  Future<void> createStudent(StudentEntity student) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> deleteStudent(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
