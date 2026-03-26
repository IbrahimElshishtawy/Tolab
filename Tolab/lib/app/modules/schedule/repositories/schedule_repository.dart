import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/schedule_models.dart';

class ScheduleRepository {
  ScheduleRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<ScheduleEventModel>> fetchSchedule() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    return _demoDataService.scheduleEvents();
  }
}
