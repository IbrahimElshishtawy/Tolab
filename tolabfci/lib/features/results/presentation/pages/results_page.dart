import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/results_providers.dart';
import '../widgets/results_header.dart';
import '../widgets/subject_result_row.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(resultsProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: resultsAsync.when(
          data: (results) => ListView(
            children: [
              const ResultsHeader(),
              const SizedBox(height: AppSpacing.lg),
              if (context.isMobile)
                ...results.map(
                  (result) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SubjectResultRow(result: result),
                  ),
                )
              else
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Subject')),
                    DataColumn(label: Text('Score')),
                    DataColumn(label: Text('Grade')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: results
                      .map(
                        (result) => DataRow(
                          cells: [
                            DataCell(Text(result.subjectName)),
                            DataCell(Text('${result.totalGrade}')),
                            DataCell(Text(result.letterGrade)),
                            DataCell(Text(result.status)),
                          ],
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
          loading: () => const LoadingWidget(label: 'Loading results...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
