import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) return const SizedBox.shrink();
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(profile.role),
              const SizedBox(height: AppSpacing.xl),
              Text('Email: ${profile.email}'),
              const SizedBox(height: AppSpacing.sm),
              Text('Phone: ${profile.phone}'),
              const SizedBox(height: AppSpacing.sm),
              Text('Department: ${profile.department}'),
            ],
          ),
        ),
      );
    });
  }
}
