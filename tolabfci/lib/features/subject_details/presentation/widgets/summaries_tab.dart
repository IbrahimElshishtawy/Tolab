import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../summaries/presentation/providers/summaries_providers.dart';
import '../../../summaries/presentation/widgets/summary_tile.dart';

class SummariesTab extends ConsumerWidget {
  const SummariesTab({
    super.key,
    required this.subjectId,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(summariesControllerProvider(subjectId));

    final actionButton = AppButton(
      label: 'إضافة ملخص',
      onPressed: () => context.goNamed(
        RouteNames.addSummary,
        pathParameters: {'subjectId': subjectId},
      ),
      isExpanded: false,
    );

    final content = summariesAsync.when(
      data: (summaries) => summaries.isEmpty
          ? const EmptyStateWidget(
              title: 'لا توجد ملخصات',
              subtitle: 'ابدأ بإضافة أول ملخص مختصر أو ملف مساعد للمادة.',
            )
          : ListView.separated(
              shrinkWrap: usePageScroll,
              physics: usePageScroll
                  ? const NeverScrollableScrollPhysics()
                  : null,
              itemCount: summaries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  SummaryTile(summary: summaries[index]),
            ),
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text(error.toString()),
    );

    if (usePageScroll) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [actionButton, const SizedBox(height: 12), content],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        actionButton,
        const SizedBox(height: 12),
        Expanded(child: content),
      ],
    );
  }
}
