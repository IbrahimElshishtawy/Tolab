import 'package:flutter/material.dart';

import '../../../../core/models/notification_item.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_list_tile.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
  });

  final AppNotificationItem notification;
  final VoidCallback onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: notification.title,
      subtitle: '${notification.body}/n${notification.createdAtLabel}',
      leading: AppBadge(label: notification.category),
      trailing: notification.isRead
          ? const Icon(Icons.done_rounded)
          : TextButton(onPressed: onMarkAsRead, child: const Text('Mark read')),
    );
  }
}
