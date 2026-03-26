import '../../../core/services/demo_data_service.dart';
import '../../../shared/models/notification_models.dart';

class NotificationsRepository {
  NotificationsRepository(this._demoDataService);

  final DemoDataService _demoDataService;

  Future<List<AdminNotification>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return _demoDataService.notifications();
  }
}
