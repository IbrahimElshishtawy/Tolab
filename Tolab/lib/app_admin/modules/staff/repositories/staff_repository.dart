import '../../../core/services/demo_data_service.dart';
import '../models/staff_admin_models.dart';

class StaffRepository {
  StaffRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<StaffAdminRecord>> fetchStaff() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    return _demoDataService.staffDirectory();
  }
}
