import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../../shared/controllers/management_controller.dart';

class StudentsController extends ManagementController<StudentModel> {
  StudentsController(this._repository) : super(_repository);

  final StudentsRepository _repository;

  Future<StudentModel?> findById(String id) => _repository.findById(id);

  Future<void> saveStudent(StudentModel student) async {
    await _repository.save(entity: student, body: student.toJson());
    await load(search: query.value);
  }
}
