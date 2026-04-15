import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/notification_item.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/data/repositories/mock_staff_portal_repository.dart';
import '../../data/repositories/mock_notifications_repository.dart';

final notificationsStreamProvider = StreamProvider<List<AppNotificationItem>>((
  ref,
) {
  final isStaff = ref.watch(isStaffUserProvider);
  if (isStaff) {
    return ref.watch(staffPortalRepositoryProvider).watchNotifications();
  }
  return ref.watch(notificationsRepositoryProvider).watchNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications =
      ref.watch(notificationsStreamProvider).value ?? const [];
  return notifications.where((item) => !item.isRead).length;
});
