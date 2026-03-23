import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/network_image_view.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../controllers/course_detail_controller.dart';

class CourseDetailView extends GetView<CourseDetailController> {
  const CourseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const PremiumAppBar(title: 'Course details'),
      body: Obx(() {
        if (controller.isLoading.value && controller.course.value == null) {
          return const AppLoadingView(lines: 3);
        }
        if (controller.error.value.isNotEmpty &&
            controller.course.value == null) {
          return AppErrorView(
            message: controller.error.value,
            onRetry: controller.load,
          );
        }

        final course = controller.course.value!;
        return ListView(
          children: [
            GlassPanel(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetworkImageView(
                    imageUrl: course.heroImage,
                    height: 180,
                    radius: 28,
                    icon: Icons.menu_book_rounded,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('${course.code} - ${course.instructor}'),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.primary(
                                label: 'Content',
                                onPressed: () => Get.toNamed(
                                  AppRoutes.courseContent,
                                  arguments: {'id': course.id},
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton.secondary(
                                label: 'Grades',
                                onPressed: () => Get.toNamed(
                                  AppRoutes.grades,
                                  arguments: {'id': course.id},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
