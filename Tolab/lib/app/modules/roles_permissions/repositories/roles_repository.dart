import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/moderation_models.dart';

class RolesRepository {
  RolesRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<RolePermission>> fetchRoles() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _demoDataService.roles();
  }
}
