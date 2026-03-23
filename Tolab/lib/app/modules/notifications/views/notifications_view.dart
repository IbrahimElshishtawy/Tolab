import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return const AppLoadingView(lines: 6);
      }
      if (controller.error.value.isNotEmpty && controller.items.isEmpty) {
        return AppErrorView(
          message: controller.error.value,
          onRetry: controller.load,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.items.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return GlassPanel(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(
                      item.isRead
                          ? Icons.notifications_none_rounded
                          : Icons.notifications_active_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(item.body),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('MMM d, h:mm a').format(item.createdAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
