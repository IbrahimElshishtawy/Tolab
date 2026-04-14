import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class SectionsTab extends ConsumerWidget {
  const SectionsTab({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(sectionsProvider(subjectId));

    return sectionsAsync.when(
      data: (sections) => sections.isEmpty
          ? const EmptyStateWidget(
              title: 'لا توجد سكاشن',
              subtitle: 'ستظهر السكاشن العملية هنا عند توفرها.',
            )
          : ListView.separated(
              itemCount: sections.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final section = sections[index];
                return AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.co_present_outlined),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(section.scheduleLabel),
                            const SizedBox(height: AppSpacing.xs),
                            Text('${section.assistantName} - ${section.location}'),
                          ],
                        ),
                      ),
                      AppBadge(label: section.isOnline ? 'أونلاين' : 'حضوري'),
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
