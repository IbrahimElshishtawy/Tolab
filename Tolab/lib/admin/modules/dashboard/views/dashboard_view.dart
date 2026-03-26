import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/states/state_views.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/activity_list.dart';
import '../widgets/metric_card.dart';
import '../widgets/trend_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value || controller.summary.value == null) {
        return const LoadingStateView();
      }
      final summary = controller.summary.value!;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                MetricCard(
                  title: 'Students',
                  value: summary.totalStudents.toString(),
                  icon: Icons.people_alt_rounded,
                ),
                MetricCard(
                  title: 'Doctors',
                  value: summary.totalDoctors.toString(),
                  icon: Icons.medical_services_rounded,
                ),
                MetricCard(
                  title: 'Subjects',
                  value: summary.totalSubjects.toString(),
                  icon: Icons.menu_book_rounded,
                ),
                MetricCard(
                  title: 'Pending Assignments',
                  value: summary.pendingAssignments.toString(),
                  icon: Icons.assignment_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 1080;
                if (stacked) {
                  return Column(
                    children: [
                      TrendCard(values: summary.trendValues),
                      const SizedBox(height: AppSpacing.lg),
                      ActivityList(items: summary.activities),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TrendCard(values: summary.trendValues),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 2,
                      child: ActivityList(items: summary.activities),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
