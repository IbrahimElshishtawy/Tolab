import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_item.dart';
import '../../../../core/theme/app_colors.dart';
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
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(resultsProvider);

    return resultsAsync.when(
      data: (results) {
        final result = results
            .where((item) => item.subjectId == subjectId)
            .firstOrNull;
        if (result == null) {
          return const EmptyStateWidget(
            title: 'لا توجد درجات',
            subtitle: 'ستظهر درجات هذه المادة هنا عند توفرها.',
          );
        }

        final attendanceProgress = (result.totalGrade / 100).clamp(0.55, 0.98);
        final lecturesProgress = (result.assignmentGrade / 30).clamp(0.35, 1.0);
        final quizzesProgress = (result.quizGrade / 20).clamp(0.0, 1.0);
        final tasksProgress = (result.assignmentGrade / 30).clamp(0.0, 1.0);

        return ListView(
          shrinkWrap: usePageScroll,
          physics: usePageScroll ? const NeverScrollableScrollPhysics() : null,
          children: [
            AppCard(
              backgroundColor: context.appColors.surfaceElevated,
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
                      AppBadge(
                        label: result.letterGrade,
                        backgroundColor: AppColors.success.withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressMetric(
                    label: 'Overall progress',
                    valueLabel: '${result.totalGrade}%',
                    value: result.totalGrade / 100,
                    color: AppColors.primary,
                  ),
                  _ProgressMetric(
                    label: 'Attendance progress',
                    valueLabel: '${(attendanceProgress * 100).round()}%',
                    value: attendanceProgress,
                    color: AppColors.teal,
                  ),
                  _ProgressMetric(
                    label: 'Lectures completed',
                    valueLabel: '${(lecturesProgress * 12).round()} / 12',
                    value: lecturesProgress,
                    color: AppColors.indigo,
                  ),
                  _ProgressMetric(
                    label: 'Quizzes score',
                    valueLabel: '${result.quizGrade} / 20',
                    value: quizzesProgress,
                    color: AppColors.warning,
                  ),
                  _ProgressMetric(
                    label: 'Tasks score',
                    valueLabel: '${result.assignmentGrade} / 30',
                    value: tasksProgress,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _GradeBreakdownCard(result: result),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback من الدكتور',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    result.notes ??
                        'مستواك مستقر. راجع نقاط الضعف قبل التقييم النهائي.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                valueLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}

class _GradeBreakdownCard extends StatelessWidget {
  const _GradeBreakdownCard({required this.result});

  final SubjectResult result;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Year work', result.assignmentGrade, 30),
      ('Quizzes', result.quizGrade, 20),
      ('Practical', result.midtermGrade ?? 0, 25),
      ('Final', result.finalGrade ?? 0, 25),
    ];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openBreakdownSheet(context, rows),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Grade breakdown',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_left_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: Text(row.$1)),
                    AppBadge(label: '${row.$2} / ${row.$3}', dense: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBreakdownSheet(
    BuildContext context,
    List<(String, int, int)> rows,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الدرجة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ...rows.map(
              (row) => _ProgressMetric(
                label: row.$1,
                valueLabel: '${row.$2} / ${row.$3}',
                value: row.$3 == 0 ? 0 : row.$2 / row.$3,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull on Iterable<SubjectResult> {
  SubjectResult? get firstOrNull => isEmpty ? null : first;
}
