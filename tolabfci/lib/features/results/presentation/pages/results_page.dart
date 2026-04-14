import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_item.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/results_providers.dart';

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  String _view = 'نظرة عامة';

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(resultsProvider);
    final profileAsync = ref.watch(profileProvider);

    if (resultsAsync.isLoading || profileAsync.isLoading) {
      return const SafeArea(
        child: AdaptivePageContainer(
          child: LoadingWidget(label: 'جاري تحميل النتائج...'),
        ),
      );
    }

    if (resultsAsync.hasError) {
      return SafeArea(
        child: AdaptivePageContainer(
          child: ErrorStateWidget(message: resultsAsync.error.toString()),
        ),
      );
    }

    if (profileAsync.hasError) {
      return SafeArea(
        child: AdaptivePageContainer(
          child: ErrorStateWidget(message: profileAsync.error.toString()),
        ),
      );
    }

    final results = resultsAsync.value ?? const <SubjectResult>[];
    final profile = profileAsync.value!;
    if (results.isEmpty) {
      return const SafeArea(
        child: AdaptivePageContainer(
          child: EmptyStateWidget(
            title: 'لا توجد نتائج',
            subtitle: 'ستظهر نتائجك الأكاديمية هنا فور اعتمادها.',
          ),
        ),
      );
    }
    final strongest = [...results]..sort((a, b) => b.totalGrade.compareTo(a.totalGrade));
    final weakest = [...results]..sort((a, b) => a.totalGrade.compareTo(b.totalGrade));
    final passed = results.where((item) => item.totalGrade >= 60).length;

    return SafeArea(
      child: AdaptivePageContainer(
        child: ListView(
          children: [
            AppSectionHeader(
              title: 'النتائج',
              subtitle: 'الموقف الأكاديمي: ${academicStandingLabel(profile.gpa)}',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              backgroundColor: AppColors.surfaceAlt,
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _MetricCard(label: 'GPA', value: profile.gpa.toStringAsFixed(2)),
                  _MetricCard(label: 'أعلى مادة', value: strongest.first.subjectName),
                  _MetricCard(label: 'أقل مادة', value: weakest.first.subjectName),
                  _MetricCard(label: 'مواد ناجحة', value: '$passed / ${results.length}'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: ['نظرة عامة', 'تفاصيل المواد']
                  .map(
                    (view) => ChoiceChip(
                      label: Text(view),
                      selected: _view == view,
                      onSelected: (_) => setState(() => _view = view),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_view == 'نظرة عامة') ...[
              _InsightCard(
                title: 'أداؤك قوي في',
                body: strongest.first.subjectName,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightCard(
                title: 'تحتاج تحسين في',
                body: weakest.first.subjectName,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightCard(
                title: 'الاتجاه العام',
                body: profile.gpa >= 3.0 ? 'مستواك تحسن هذا الأسبوع.' : 'هناك حاجة لرفع أداء بعض المواد.',
                color: AppColors.primary,
              ),
            ] else
              ...results.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                result.subjectName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            AppBadge(label: result.letterGrade),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('الإجمالي: ${result.totalGrade}'),
                        Text('الكويزات: ${result.quizGrade}'),
                        Text('الشيتات: ${result.assignmentGrade}'),
                        if (result.midtermGrade != null) Text('الميدترم: ${result.midtermGrade}'),
                        if (result.finalGrade != null) Text('الفاينل: ${result.finalGrade}'),
                        if (result.notes != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(result.notes!, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.body,
    required this.color,
  });

  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
