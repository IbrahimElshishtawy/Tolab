import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/staff_member.dart';

class StaffRepository {
  StaffRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<StaffMember>> fetchStaff() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    return _demoDataService.staff();
  }
}
