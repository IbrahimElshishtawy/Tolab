import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../../shell/controllers/shell_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadDashboard,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingView();
        }
        if (controller.error.value.isNotEmpty &&
            controller.spotlightCourses.isEmpty &&
            controller.todaySchedule.isEmpty) {
          return AppErrorView(
            message: controller.error.value,
            onRetry: controller.loadDashboard,
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMM').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Hello, ${controller.userName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your academic pulse is stable. Here is what needs attention today.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.primary(
                          label: 'Open courses',
                          onPressed: () =>
                              Get.find<ShellController>().changeTab(1),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton.secondary(
                          label: 'Search',
                          onPressed: () => Get.toNamed(AppRoutes.search),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: 'Today',
              subtitle: 'Upcoming classes and quick actions',
              trailing: TextButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.group, arguments: {'groupId': '1'}),
                child: const Text('Open group'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...controller.todaySchedule.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GlassPanel(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          item.startTime,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
                              ),
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
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text('${item.day} · ${item.location ?? 'Campus'}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Course spotlight'),
            const SizedBox(height: AppSpacing.md),
            ...controller.spotlightCourses.map(
              (course) => GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.courseDetails,
                  arguments: {'id': course.id},
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GlassPanel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        NetworkImageView(
                          imageUrl: course.heroImage,
                          height: 140,
                          radius: 28,
                          icon: Icons.menu_book_rounded,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${course.code} · ${course.instructor}',
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
