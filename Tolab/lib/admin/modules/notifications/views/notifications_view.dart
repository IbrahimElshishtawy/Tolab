import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../routes/app_routes.dart';
import '../../shared/widgets/status_chip.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Notification Center',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            AppButton(
              label: 'Broadcast',
              icon: Icons.campaign_rounded,
              onPressed: () => Get.toNamed(AppRoutes.broadcastNotifications),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Obx(
            () => ListView.separated(
              itemCount: controller.items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, index) {
                final item = controller.items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(item.body),
                    ),
                    trailing: StatusChip(item.status),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
