import 'package:tolab_fci/data/models/course_model.dart';
import 'package:tolab_fci/domain/entities/course_entity.dart';

class MockCourses {
  static final List<CourseModel> courses = [
    // Computer Science Courses
    CourseModel(
      id: 'course_001',
      code: 'CS101',
      name: 'Introduction to Programming',
      description:
          'Learn the fundamentals of programming with Python. This course covers variables, loops, functions, and basic data structures.',
      departmentId: 'dept_001',
      creditHours: 3,
      maxStudents: 40,
      enrolledStudents: 38,
      instructorId: 'user_003',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Introduction to Programming Syllabus',
      prerequisites: [],
    ),
    CourseModel(
      id: 'course_002',
      code: 'CS201',
      name: 'Data Structures',
      description:
          'Master essential data structures including arrays, linked lists, stacks, queues, and trees.',
      departmentId: 'dept_001',
      creditHours: 4,
      maxStudents: 35,
      enrolledStudents: 32,
      instructorId: 'user_004',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Data Structures Syllabus',
      prerequisites: ['CS101'],
    ),
    CourseModel(
      id: 'course_003',
      code: 'CS301',
      name: 'Algorithms',
      description:
          'Study algorithm design, analysis, and optimization techniques. Learn sorting, searching, and graph algorithms.',
      departmentId: 'dept_001',
      creditHours: 4,
      maxStudents: 30,
      enrolledStudents: 28,
      instructorId: 'user_003',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Algorithms Syllabus',
      prerequisites: ['CS201'],
    ),
    CourseModel(
      id: 'course_004',
      code: 'CS401',
      name: 'Web Development',
      description:
          'Build modern web applications using HTML, CSS, JavaScript, and popular frameworks.',
      departmentId: 'dept_001',
      creditHours: 3,
      maxStudents: 40,
      enrolledStudents: 40,
      instructorId: 'user_004',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Web Development Syllabus',
      prerequisites: ['CS101'],
    ),
    CourseModel(
      id: 'course_005',
      code: 'CS501',
      name: 'Database Systems',
      description:
          'Learn database design, SQL, normalization, and transaction management.',
      departmentId: 'dept_001',
      creditHours: 3,
      maxStudents: 35,
      enrolledStudents: 33,
      instructorId: 'user_003',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Database Systems Syllabus',
      prerequisites: ['CS201'],
    ),
    // Mathematics Courses
    CourseModel(
      id: 'course_006',
      code: 'MATH101',
      name: 'Calculus I',
      description:
          'Introduction to differential calculus including limits, derivatives, and applications.',
      departmentId: 'dept_002',
      creditHours: 4,
      maxStudents: 50,
      enrolledStudents: 48,
      instructorId: 'user_005',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Calculus I Syllabus',
      prerequisites: [],
    ),
    CourseModel(
      id: 'course_007',
      code: 'MATH201',
      name: 'Calculus II',
      description:
          'Integral calculus, techniques of integration, and applications of integration.',
      departmentId: 'dept_002',
      creditHours: 4,
      maxStudents: 45,
      enrolledStudents: 42,
      instructorId: 'user_005',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Calculus II Syllabus',
      prerequisites: ['MATH101'],
    ),
    CourseModel(
      id: 'course_008',
      code: 'MATH301',
      name: 'Linear Algebra',
      description:
          'Vectors, matrices, linear transformations, eigenvalues, and applications.',
      departmentId: 'dept_002',
      creditHours: 3,
      maxStudents: 40,
      enrolledStudents: 38,
      instructorId: 'user_005',
      startDate: DateTime(2024, 9, 1),
      endDate: DateTime(2024, 12, 20),
      isActive: true,
      syllabus: 'Linear Algebra Syllabus',
      prerequisites: ['MATH101'],
    ),
  ];

  static CourseEntity getCourseById(String id) {
    return courses.firstWhere((c) => c.id == id).toEntity();
  }

  static List<CourseEntity> getCoursesByDepartment(String departmentId) {
    return courses
        .where((c) => c.departmentId == departmentId)
        .map((c) => c.toEntity())
        .toList();
  }

  static List<CourseEntity> getCoursesByInstructor(String instructorId) {
    return courses
        .where((c) => c.instructorId == instructorId)
        .map((c) => c.toEntity())
        .toList();
  }

  static List<CourseEntity> getActiveCourses() {
    return courses
        .where((c) => c.isActive)
        .map((c) => c.toEntity())
        .toList();
  }

  static List<CourseEntity> getAllCourses() {
    return courses.map((c) => c.toEntity()).toList();
  }
}
