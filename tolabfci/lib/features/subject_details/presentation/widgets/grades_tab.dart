import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_item.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../results/presentation/providers/results_providers.dart';

class GradesTab extends ConsumerWidget {
  const GradesTab({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(resultsProvider);

    return resultsAsync.when(
      data: (results) {
        final result = results.where((item) => item.subjectId == subjectId).firstOrNull;
        if (result == null) {
          return const EmptyStateWidget(
            title: 'لا توجد درجات',
            subtitle: 'ستظهر درجات هذه المادة هنا عند توفرها.',
          );
        }

        return ListView(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.subjectName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      AppBadge(label: result.letterGrade),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('الإجمالي: ${result.totalGrade}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text('الكويزات: ${result.quizGrade}'),
                  Text('الشيتات: ${result.assignmentGrade}'),
                  if (result.midtermGrade != null) Text('الميدترم: ${result.midtermGrade}'),
                  if (result.finalGrade != null) Text('الفاينل: ${result.finalGrade}'),
                  if (result.notes != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(result.notes!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}

extension _FirstOrNull on Iterable<SubjectResult> {
  SubjectResult? get firstOrNull => isEmpty ? null : first;
}
