import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/staff_portal_providers.dart';

class StaffSchedulePage extends ConsumerWidget {
  const StaffSchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(staffScheduleProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: scheduleAsync.when(
          data: (events) => ListView(
            children: [
              Text(
                context.tr(
                  'الجدول والمواعيد المهمة',
                  'Schedule and important dates',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.tr(
                  'عرض موحّد للمحاضرات والسكاشن والكويزات والـ deadlines',
                  'Unified view for lectures, sections, quizzes, and deadlines',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...events.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(event.type.name),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(event.description),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${event.startsAt.year}/${event.startsAt.month}/${event.startsAt.day}  ${event.startsAt.hour.toString().padLeft(2, '0')}:${event.startsAt.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const LoadingWidget(label: 'Loading schedule...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
