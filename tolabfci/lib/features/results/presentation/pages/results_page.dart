import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/result_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_segmented_control.dart';
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
  String _view = 'overview';

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
    final profile = profileAsync.value;

    if (results.isEmpty || profile == null) {
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
            _OverviewStrip(
              gpa: profile.gpa.toStringAsFixed(2),
              strongest: strongest.first.subjectName,
              weakest: weakest.first.subjectName,
              passedLabel: '$passed / ${results.length}',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSegmentedControl<String>(
              groupValue: _view,
              onValueChanged: (value) => setState(() => _view = value),
              children: const {
                'overview': Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('نظرة عامة'),
                ),
                'details': Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('تفاصيل المواد'),
                ),
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_view == 'overview') ...[
              _InsightCard(
                title: 'أفضل أداء',
                body: strongest.first.subjectName,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightCard(
                title: 'تحتاج تحسينًا في',
                body: weakest.first.subjectName,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightCard(
                title: 'تحليل أكاديمي',
                body: profile.gpa >= 3.0
                    ? 'مستواك جيد، حافظي على نفس الوتيرة في المواد الأساسية.'
                    : 'ركزي أكثر على المواد الأضعف وابدئي بالمهمات القصيرة أولًا.',
                color: AppColors.primary,
              ),
            ] else
              ...results.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ResultCard(result: result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({
    required this.gpa,
    required this.strongest,
    required this.weakest,
    required this.passedLabel,
  });

  final String gpa;
  final String strongest;
  final String weakest;
  final String passedLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _MetricCard(label: 'GPA', value: gpa),
        _MetricCard(label: 'أعلى مادة', value: strongest),
        _MetricCard(label: 'أقل مادة', value: weakest),
        _MetricCard(label: 'مواد ناجحة', value: passedLabel),
      ],
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
    final palette = context.appColors;

    return SizedBox(
      width: 170,
      child: AppCard(
        backgroundColor: palette.surfaceElevated,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
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
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final SubjectResult result;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return AppCard(
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
              AppBadge(
                label: result.letterGrade,
                backgroundColor: palette.primarySoft,
                foregroundColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _GradeTile(label: 'الإجمالي', value: '${result.totalGrade}'),
              _GradeTile(label: 'الكويزات', value: '${result.quizGrade}'),
              _GradeTile(label: 'الشيتات', value: '${result.assignmentGrade}'),
              if (result.midtermGrade != null)
                _GradeTile(label: 'الميدترم', value: '${result.midtermGrade}'),
              if (result.finalGrade != null)
                _GradeTile(label: 'الفاينل', value: '${result.finalGrade}'),
            ],
          ),
          if (result.notes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(result.notes!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _GradeTile extends StatelessWidget {
  const _GradeTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('$label: $value', style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
