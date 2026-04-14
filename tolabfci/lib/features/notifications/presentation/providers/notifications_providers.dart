import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification_item.dart';
import '../../data/repositories/mock_notifications_repository.dart';

final notificationsStreamProvider = StreamProvider<List<AppNotificationItem>>((ref) {
  return ref.watch(notificationsRepositoryProvider).watchNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider).value ?? const [];
  return notifications.where((item) => !item.isRead).length;
});
