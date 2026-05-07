import 'package:tolab_fci/domain/entities/course_entity.dart';
import 'package:tolab_fci/mock/fixtures/mock_courses.dart';

abstract class CourseRepository {
  Future<CourseEntity> getCourseById(String id);
  Future<List<CourseEntity>> getCoursesByDepartment(String departmentId);
  Future<List<CourseEntity>> getCoursesByInstructor(String instructorId);
  Future<List<CourseEntity>> getActiveCourses();
  Future<List<CourseEntity>> getAllCourses();
  Future<void> createCourse(CourseEntity course);
  Future<void> updateCourse(CourseEntity course);
  Future<void> deleteCourse(String id);
}

class MockCourseRepository implements CourseRepository {
  @override
  Future<CourseEntity> getCourseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCourses.getCourseById(id);
  }

  @override
  Future<List<CourseEntity>> getCoursesByDepartment(String departmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCourses.getCoursesByDepartment(departmentId);
  }

  @override
  Future<List<CourseEntity>> getCoursesByInstructor(String instructorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCourses.getCoursesByInstructor(instructorId);
  }

  @override
  Future<List<CourseEntity>> getActiveCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCourses.getActiveCourses();
  }

  @override
  Future<List<CourseEntity>> getAllCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockCourses.getAllCourses();
  }

  @override
  Future<void> createCourse(CourseEntity course) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateCourse(CourseEntity course) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> deleteCourse(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
