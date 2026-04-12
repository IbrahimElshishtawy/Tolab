import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../quizzes/presentation/providers/quizzes_providers.dart';
import '../../../quizzes/presentation/widgets/quiz_list_tile.dart';

class QuizzesTab extends ConsumerWidget {
  const QuizzesTab({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider(subjectId));

    return quizzesAsync.when(
      data: (quizzes) => quizzes.isEmpty
          ? const EmptyStateWidget(
              title: 'No quizzes scheduled',
              subtitle: 'Online and offline quizzes will appear here.',
            )
          : Column(
              children: quizzes
                  .map(
                    (quiz) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuizListTile(quiz: quiz),
                    ),
                  )
                  .toList(),
            ),
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}
