import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/student.dart';

class StudentsRepository {
  StudentsRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<Student>> fetchStudents() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    return _demoDataService.students();
  }
}
