import 'package:tolab_fci/data/repositories/course_repository.dart';
import 'package:tolab_fci/data/repositories/student_repository.dart';
import 'package:tolab_fci/data/repositories/user_repository.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();

  late final UserRepository userRepository;
  late final CourseRepository courseRepository;
  late final StudentRepository studentRepository;

  MockDataService._internal() {
    _initializeRepositories();
  }

  factory MockDataService() {
    return _instance;
  }

  void _initializeRepositories() {
    userRepository = MockUserRepository();
    courseRepository = MockCourseRepository();
    studentRepository = MockStudentRepository();
  }

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void reset() {
    _initializeRepositories();
  }
}
