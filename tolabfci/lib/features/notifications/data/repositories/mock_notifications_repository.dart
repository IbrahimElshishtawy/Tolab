import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification_item.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return MockNotificationsRepository(ref.watch(mockBackendServiceProvider));
});

class MockNotificationsRepository implements NotificationsRepository {
  const MockNotificationsRepository(this._backendService);

  final MockBackendService _backendService;

  @override
  Future<List<AppNotificationItem>> fetchNotifications() {
    return _backendService.fetchNotifications();
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _backendService.markNotificationAsRead(notificationId);
  }

  @override
  Stream<List<AppNotificationItem>> watchNotifications() {
    return _backendService.watchNotifications();
  }
}
