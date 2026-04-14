import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/quizzes_providers.dart';
import '../widgets/quiz_list_tile.dart';

class QuizzesPage extends ConsumerStatefulWidget {
  const QuizzesPage({super.key});

  @override
  ConsumerState<QuizzesPage> createState() => _QuizzesPageState();
}

String _quizStatus(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return 'تم التسليم';
  }
  final now = DateTime.now();
  if (quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now)) {
    return 'مفتوح';
  }
  if (quiz.startsAt != null && quiz.startsAt!.isAfter(now)) {
    return 'قريب';
  }
  return 'منتهي';
}

class _QuizzesPageState extends ConsumerState<QuizzesPage> {
  String _filter = 'الكل';

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider(null));

    return SafeArea(
      child: AdaptivePageContainer(
        child: quizzesAsync.when(
          data: (quizzes) {
            final filtered = quizzes.where((quiz) {
              if (_filter == 'الكل') {
                return true;
              }
              final status = _quizStatus(quiz);
              return status == _filter;
            }).toList();

            return ListView(
              children: [
                const AppSectionHeader(
                  title: 'الكويزات',
                  subtitle: 'تابع الكويزات المفتوحة والقريبة والمنتهية من مكان واحد.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ['الكل', 'مفتوح', 'قريب', 'تم التسليم', 'منتهي']
                      .map(
                        (filter) => ChoiceChip(
                          label: Text(filter),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد كويزات مطابقة',
                    subtitle: 'جرّب تصفية أخرى أو انتظر الكويزات القادمة.',
                    icon: Icons.quiz_outlined,
                  )
                else
                  ...filtered.map(
                    (quiz) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: QuizListTile(quiz: quiz),
                    ),
                  ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جاري تحميل الكويزات...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
