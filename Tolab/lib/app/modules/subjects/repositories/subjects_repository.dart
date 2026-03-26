import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/academic_models.dart';

class SubjectsRepository {
  SubjectsRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<SubjectModel>> fetchSubjects() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return _demoDataService.subjects();
  }
}
