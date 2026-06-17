import 'package:flutter/material.dart';

import '../../../../core/models/notification_item.dart';
import '../../../../core/theme/app_spacing.dart';
import 'notification_card.dart';

class NotificationGroup extends StatelessWidget {
  const NotificationGroup({
    super.key,
    required this.title,
    required this.items,
    required this.onOpen,
  });

  final String title;
  final List<AppNotificationItem> items;
  final Future<void> Function(BuildContext context, AppNotificationItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onOpen(context, item),
              child: NotificationCard(item: item),
            ),
          ),
        ),
      ],
    );
  }
}
