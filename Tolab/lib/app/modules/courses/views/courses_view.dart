import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../controllers/courses_controller.dart';

class CoursesView extends GetView<CoursesController> {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.loadCourses(refresh: true),
      child: Obx(() {
        if (controller.isLoading.value && controller.courses.isEmpty) {
          return const AppLoadingView(lines: 6);
        }
        if (controller.error.value.isNotEmpty && controller.courses.isEmpty) {
          return AppErrorView(
            message: controller.error.value,
            onRetry: () => controller.loadCourses(refresh: true),
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          itemCount:
              controller.courses.length +
              (controller.isFetchingMore.value ? 1 : 0),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemBuilder: (context, index) {
            if (index >= controller.courses.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final course = controller.courses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GestureDetector(
                onTap: () => Get.toNamed(
                  AppRoutes.courseDetails,
                  arguments: {'id': course.id},
                ),
                child: GlassPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      NetworkImageView(
                        imageUrl: course.heroImage,
                        height: 138,
                        icon: Icons.school_rounded,
                        radius: 28,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    course.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Text(course.code),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${course.instructor} · ${course.section ?? 'Main section'}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
