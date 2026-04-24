import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../providers/quizzes_providers.dart';

class StudentQuizzesPage extends ConsumerWidget {
  const StudentQuizzesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider(null));

    return SafeArea(
      child: AdaptivePageContainer(
        child: quizzesAsync.when(
          data: (quizzes) {
            final openNow = quizzes.where(_isOpen).toList();
            final upcoming = quizzes.where(_isUpcoming).toList();
            final submitted = quizzes
                .where((quiz) => quiz.isSubmitted)
                .toList();
            final closed = quizzes.where(_isClosedWithoutSubmit).toList();

            return ListView(
              children: [
                _QuizHero(
                  openCount: openNow.length,
                  upcomingCount: upcoming.length,
                  submittedCount: submitted.length,
                  closedCount: closed.length,
                ),
                const SizedBox(height: AppSpacing.lg),
                _QuizSection(title: 'مفتوح الآن', quizzes: openNow),
                const SizedBox(height: AppSpacing.lg),
                _QuizSection(title: 'قادم', quizzes: upcoming),
                const SizedBox(height: AppSpacing.lg),
                _QuizSection(title: 'تم التسليم', quizzes: submitted),
                const SizedBox(height: AppSpacing.lg),
                _QuizSection(title: 'مغلق', quizzes: closed),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جارٍ تحميل الكويزات...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _QuizHero extends StatelessWidget {
  const _QuizHero({
    required this.openCount,
    required this.upcomingCount,
    required this.submittedCount,
    required this.closedCount,
  });

  final int openCount;
  final int upcomingCount;
  final int submittedCount;
  final int closedCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مركز الكويزات',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'تابع الكويزات المفتوحة والقادمة، وادخل إلى صفحة التفاصيل أو ابدأ المحاولة مباشرة عند الإتاحة.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          ResponsiveWrapGrid(
            minItemWidth: 150,
            spacing: AppSpacing.sm,
            children: [
              _MetricCard(
                label: 'مفتوح الآن',
                value: '$openCount',
                accent: AppColors.error,
              ),
              _MetricCard(
                label: 'قادم',
                value: '$upcomingCount',
                accent: AppColors.warning,
              ),
              _MetricCard(
                label: 'تم التسليم',
                value: '$submittedCount',
                accent: AppColors.success,
              ),
              _MetricCard(
                label: 'مغلق',
                value: '$closedCount',
                accent: AppColors.support,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  const _QuizSection({required this.title, required this.quizzes});

  final String title;
  final List<QuizItem> quizzes;

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ResponsiveWrapGrid(
          minItemWidth: 320,
          spacing: AppSpacing.md,
          children: quizzes
              .map((quiz) => _StudentQuizCard(quiz: quiz))
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _StudentQuizCard extends StatelessWidget {
  const _StudentQuizCard({required this.quiz});

  final QuizItem quiz;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(quiz);
    final color = _statusColor(status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.quiz_outlined, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      quiz.subjectName ?? 'المادة',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: status,
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: quiz.durationLabel),
              AppBadge(label: quiz.startAtLabel),
              if (quiz.endAtLabel != null) AppBadge(label: quiz.endAtLabel!),
              AppBadge(label: _availabilityLabel(quiz)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            quiz.description ??
                'تفاصيل الكويز وتعليماته متاحة داخل صفحة المعاينة.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton(
                onPressed: _isOpen(quiz)
                    ? () => context.goNamed(
                        RouteNames.quizTaking,
                        pathParameters: {
                          'subjectId': quiz.subjectId,
                          'quizId': quiz.id,
                        },
                      )
                    : null,
                child: const Text('دخول الكويز'),
              ),
              FilledButton.tonal(
                onPressed: () => context.goNamed(
                  RouteNames.quizEntry,
                  pathParameters: {
                    'subjectId': quiz.subjectId,
                    'quizId': quiz.id,
                  },
                ),
                child: const Text('عرض التفاصيل'),
              ),
              if (quiz.scoreLabel != null)
                AppBadge(
                  label: 'النتيجة ${quiz.scoreLabel}',
                  backgroundColor: AppColors.success.withValues(alpha: 0.12),
                  foregroundColor: AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

bool _isOpen(QuizItem quiz) {
  final now = DateTime.now();
  return !quiz.isSubmitted &&
      quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now);
}

bool _isUpcoming(QuizItem quiz) {
  return !quiz.isSubmitted &&
      quiz.startsAt != null &&
      quiz.startsAt!.isAfter(DateTime.now());
}

bool _isClosedWithoutSubmit(QuizItem quiz) {
  return !quiz.isSubmitted &&
      quiz.closesAt != null &&
      quiz.closesAt!.isBefore(DateTime.now());
}

String _statusLabel(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return 'تم التسليم';
  }
  if (_isOpen(quiz)) {
    return 'مفتوح';
  }
  if (_isUpcoming(quiz)) {
    return 'قادم';
  }
  return 'مغلق';
}

String _availabilityLabel(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return 'تم الإرسال';
  }
  if (_isOpen(quiz)) {
    return 'متاح حتى ${quiz.closesAt != null ? quiz.closesAt!.hour.toString().padLeft(2, '0') : ''}:${quiz.closesAt != null ? quiz.closesAt!.minute.toString().padLeft(2, '0') : ''}';
  }
  if (_isUpcoming(quiz)) {
    return 'يبدأ لاحقًا';
  }
  return 'انتهى الوقت';
}

Color _statusColor(String status) {
  switch (status) {
    case 'مفتوح':
      return AppColors.error;
    case 'قادم':
      return AppColors.warning;
    case 'تم التسليم':
      return AppColors.success;
    default:
      return AppColors.support;
  }
}
