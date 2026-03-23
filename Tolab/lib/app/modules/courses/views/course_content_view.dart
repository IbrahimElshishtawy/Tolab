import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/course_content_controller.dart';

class CourseContentView extends GetView<CourseContentController> {
  const CourseContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const PremiumAppBar(title: 'Course content'),
      body: Obx(() {
        final content = controller.content.value;
        if (controller.isLoading.value && content == null) {
          return const AppLoadingView(lines: 5);
        }
        if (controller.error.value.isNotEmpty && content == null) {
          return AppErrorView(
            message: controller.error.value,
            onRetry: controller.load,
          );
        }

        final sections = {
          'Lectures': content?.lectures ?? const [],
          'Summaries': content?.summaries ?? const [],
          'Assessments': content?.assessments ?? const [],
          'Exams': content?.exams ?? const [],
          'Files': content?.files ?? const [],
        };

        return ListView(
          children: sections.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (entry.value.isEmpty)
                      const Text('No items yet.')
                    else
                      ...entry.value.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_outlined),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: Text(item.title)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
