import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/upload/upload_panel.dart';
import '../controllers/notifications_controller.dart';

class BroadcastNotificationView extends GetView<NotificationsController> {
  const BroadcastNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Broadcast Notification',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: controller.titleController,
                labelText: 'Title',
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: controller.bodyController,
                labelText: 'Message',
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              UploadPanel(
                title: 'Optional Attachment',
                allowedExtensions: const ['png', 'jpg', 'pdf'],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Send Broadcast',
                icon: Icons.send_rounded,
                onPressed: () async {
                  await controller.broadcast();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
