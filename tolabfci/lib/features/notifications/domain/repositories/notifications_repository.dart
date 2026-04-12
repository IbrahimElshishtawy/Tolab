import '../../../../core/models/notification_item.dart';

abstract class NotificationsRepository {
  Stream<List<AppNotificationItem>> watchNotifications();

  Future<List<AppNotificationItem>> fetchNotifications();

  Future<void> markAsRead(String notificationId);
}
