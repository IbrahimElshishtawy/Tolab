import '../fake_delay.dart';
import '../mock_data.dart';

class NotificationsFakeRepo {
  Future<List<dynamic>> getNotifications() async {
    await fakeDelay();
    return mockNotificationsData;
  }
}
