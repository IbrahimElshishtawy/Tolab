import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/grades_controller.dart';

class GradesView extends GetView<GradesController> {
  const GradesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const PremiumAppBar(title: 'Grades'),
      body: Obx(() {
        if (controller.isLoading.value && controller.grades.isEmpty) {
          return const AppLoadingView(lines: 5);
        }
        if (controller.error.value.isNotEmpty && controller.grades.isEmpty) {
          return AppErrorView(
            message: controller.error.value,
            onRetry: controller.load,
          );
        }

        return ListView.separated(
          itemCount: controller.grades.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final item = controller.grades[index];
            final ratio = item.total == 0 ? 0.0 : item.score / item.total;
            return GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '${item.score.toStringAsFixed(1)} / ${item.total.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: ratio.clamp(0, 1),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
