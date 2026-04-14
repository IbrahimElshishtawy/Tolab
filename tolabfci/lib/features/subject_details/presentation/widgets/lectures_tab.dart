import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class LecturesTab extends ConsumerWidget {
  const LecturesTab({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturesAsync = ref.watch(lecturesProvider(subjectId));

    return lecturesAsync.when(
      data: (lectures) => lectures.isEmpty
          ? const EmptyStateWidget(
              title: 'لا توجد محاضرات',
              subtitle: 'ستظهر محاضرات المادة هنا فور إضافتها.',
            )
          : ListView.separated(
              itemCount: lectures.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                return AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_outline_rounded),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lecture.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(lecture.scheduleLabel),
                            const SizedBox(height: AppSpacing.xs),
                            Text(lecture.locationLabel ?? 'قاعة المحاضرة'),
                          ],
                        ),
                      ),
                      AppBadge(label: lecture.isOnline ? 'أونلاين' : 'داخل الجامعة'),
                    ],
                  ),
                );
              },
            ),
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}
