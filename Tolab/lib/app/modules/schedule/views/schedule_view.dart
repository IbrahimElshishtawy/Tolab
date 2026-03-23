import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/state_views.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'odd', 'even'].map((week) {
                final selected = controller.selectedWeek.value == week;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(week.toUpperCase()),
                    onSelected: (_) => controller.load(week: week),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.events.isEmpty) {
              return const AppLoadingView(lines: 5);
            }
            if (controller.error.value.isNotEmpty &&
                controller.events.isEmpty) {
              return AppErrorView(
                message: controller.error.value,
                onRetry: controller.load,
              );
            }

            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.events.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final event = controller.events[index];
                  return GlassPanel(
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 74,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${event.day} · ${event.startTime} - ${event.endTime}',
                              ),
                              Text(event.location ?? 'Campus'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
