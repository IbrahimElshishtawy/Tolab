import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/results_providers.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(resultsProvider);
    final profileAsync = ref.watch(profileProvider);

    if (resultsAsync.isLoading || profileAsync.isLoading) {
      return const SafeArea(
        child: AdaptivePageContainer(
          child: LoadingWidget(label: 'جارٍ تحميل النتائج...'),
        ),
      );
    }

    if (resultsAsync.hasError || profileAsync.hasError) {
      return SafeArea(
        child: AdaptivePageContainer(
          child: ErrorStateWidget(
            message:
                resultsAsync.error?.toString() ?? profileAsync.error.toString(),
          ),
        ),
      );
    }

    final results = resultsAsync.value ?? const <SubjectResult>[];
    final profile = profileAsync.value;

    if (results.isEmpty || profile == null) {
      return const SafeArea(
        child: AdaptivePageContainer(
          child: ErrorStateWidget(message: 'لا توجد نتائج متاحة حاليًا.'),
        ),
      );
    }

    final strongest = [...results]
      ..sort((a, b) => b.totalGrade.compareTo(a.totalGrade));
    final weakest = [...results]
      ..sort((a, b) => a.totalGrade.compareTo(b.totalGrade));
    final passed = results.where((item) => item.totalGrade >= 60).length;

    return SafeArea(
      child: AdaptivePageContainer(
        child: ListView(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'النتائج والتحليل',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'تحليل أكاديمي واضح يجمع GPA، أقوى وأضعف مادة، وتفصيل الأداء داخل كل مادة.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ResponsiveWrapGrid(
                    minItemWidth: 180,
                    spacing: AppSpacing.sm,
                    children: [
                      _OverviewMetric(
                        label: 'GPA',
                        value: profile.gpa.toStringAsFixed(2),
                      ),
                      _OverviewMetric(
                        label: 'أعلى مادة',
                        value: strongest.first.subjectName,
                      ),
                      _OverviewMetric(
                        label: 'أضعف مادة',
                        value: weakest.first.subjectName,
                      ),
                      _OverviewMetric(
                        label: 'مواد ناجحة',
                        value: '$passed / ${results.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ResponsiveWrapGrid(
              minItemWidth: 320,
              children: [
                _InsightPanel(
                  title: 'Academic Insights',
                  lines: [
                    'أداؤك قوي في ${strongest.first.subjectName}.',
                    'تحتاج تحسينًا أكبر في ${weakest.first.subjectName}.',
                    profile.gpa >= 3.5
                        ? 'مستواك العام ممتاز ومستقر هذا الفصل.'
                        : 'هناك فرصة واضحة لرفع المعدل عبر التركيز على المواد الأضعف.',
                  ],
                  accent: AppColors.primary,
                ),
                _TrendPanel(results: results),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'تفاصيل المواد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ...results.map(
              (result) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _SubjectResultCard(result: result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.title,
    required this.lines,
    required this.accent,
  });

  final String title;
  final List<String> lines;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.insights_rounded,
                      size: 16,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(line)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPanel extends StatelessWidget {
  const _TrendPanel({required this.results});

  final List<SubjectResult> results;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اتجاه الأداء', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...results.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(result.subjectName)),
                      Text('${result.totalGrade}%'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: result.totalGrade / 100,
                      minHeight: 8,
                      color: result.totalGrade >= 85
                          ? AppColors.success
                          : result.totalGrade >= 70
                          ? AppColors.warning
                          : AppColors.error,
                      backgroundColor: context.appColors.surfaceAlt,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectResultCard extends StatelessWidget {
  const _SubjectResultCard({required this.result});

  final SubjectResult result;

  @override
  Widget build(BuildContext context) {
    final totalColor = result.totalGrade >= 85
        ? AppColors.success
        : result.totalGrade >= 70
        ? AppColors.warning
        : AppColors.error;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.subjectName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      result.status,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: result.letterGrade,
                backgroundColor: totalColor.withValues(alpha: 0.12),
                foregroundColor: totalColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ResponsiveWrapGrid(
            minItemWidth: 140,
            spacing: AppSpacing.sm,
            children: [
              _GradeTile(label: 'الإجمالي', value: '${result.totalGrade}'),
              _GradeTile(label: 'الكويزات', value: '${result.quizGrade}'),
              _GradeTile(label: 'الشيتات', value: '${result.assignmentGrade}'),
              if (result.midtermGrade != null)
                _GradeTile(label: 'Midterm', value: '${result.midtermGrade}'),
              if (result.finalGrade != null)
                _GradeTile(label: 'Final', value: '${result.finalGrade}'),
            ],
          ),
          if (result.notes != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              result.notes!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: totalColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GradeTile extends StatelessWidget {
  const _GradeTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
