import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/academic_models.dart';

class EnrollmentsRepository {
  EnrollmentsRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<EnrollmentRecord>> fetchEnrollments() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return _demoDataService.enrollments();
  }
}
