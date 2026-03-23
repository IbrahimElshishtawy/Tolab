import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      if (controller.isLoading.value && user == null) {
        return const AppLoadingView(lines: 3);
      }
      if (controller.error.value.isNotEmpty && user == null) {
        return AppErrorView(
          message: controller.error.value,
          onRetry: controller.load,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            GlassPanel(
              child: Column(
                children: [
                  const NetworkImageView(
                    imageUrl: null,
                    height: 92,
                    width: 92,
                    radius: 46,
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user?.name ?? 'Student',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(user?.email ?? ''),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaTile(
                          label: 'Role',
                          value: user?.role ?? 'student',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _MetaTile(
                          label: 'Department',
                          value: user?.department ?? 'N/A',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton.secondary(
              label: 'Open settings',
              onPressed: () => Get.toNamed(AppRoutes.settings),
            ),
          ],
        ),
      );
    });
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
