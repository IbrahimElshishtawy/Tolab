import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/quizzes_providers.dart';
import '../widgets/quiz_rules_card.dart';

class QuizEntryPage extends ConsumerWidget {
  const QuizEntryPage({
    super.key,
    required this.subjectId,
    required this.quizId,
  });

  final String subjectId;
  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider(subjectId));

    return SafeArea(
      child: AdaptivePageContainer(
        child: quizzesAsync.when(
          data: (quizzes) {
            final quiz = quizzes.firstWhere((item) => item.id == quizId);
            return ListView(
              children: [
                QuizRulesCard(quiz: quiz),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Start quiz',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quiz attempt wiring is ready for backend connection.'),
                      ),
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'Loading quiz...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
