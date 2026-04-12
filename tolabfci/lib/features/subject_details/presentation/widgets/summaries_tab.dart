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
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(summariesControllerProvider(subjectId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          label: 'Add summary',
          onPressed: () => context.goNamed(
            RouteNames.addSummary,
            pathParameters: {'subjectId': subjectId},
          ),
          isExpanded: false,
        ),
        const SizedBox(height: 16),
        summariesAsync.when(
          data: (summaries) => summaries.isEmpty
              ? const EmptyStateWidget(
                  title: 'No summaries yet',
                  subtitle: 'Start the collection with a concise summary or media attachment.',
                )
              : Column(
                  children: summaries
                      .map(
                        (summary) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SummaryTile(summary: summary),
                        ),
                      )
                      .toList(),
                ),
          loading: () => const LoadingWidget(),
          error: (error, stackTrace) => Text(error.toString()),
        ),
      ],
    );
  }
}
