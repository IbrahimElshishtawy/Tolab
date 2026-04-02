import '../../../core/models/notification_models.dart';
import '../../../core/network/api_client.dart';

class NotificationsRepository {
  NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await _apiClient.get<List<NotificationModel>>(
      '/staff-portal/notifications',
      parser: (value) => (value as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList(),
    );

    return response.data ?? const <NotificationModel>[];
  }

  Future<void> markRead(int notificationId) async {
    await _apiClient.patch<Object?>(
      '/staff-portal/notifications/$notificationId/read',
      parser: (_) => null,
    );
  }
}
