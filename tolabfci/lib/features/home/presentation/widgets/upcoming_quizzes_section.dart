import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';

class UpcomingQuizzesSection extends StatelessWidget {
  const UpcomingQuizzesSection({
    super.key,
    required this.quizzes,
  });

  final List<QuizItem> quizzes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const AppSectionHeader(
            title: 'Upcoming quizzes',
            subtitle: 'Review entry rules before starting',
          ),
          const SizedBox(height: AppSpacing.md),
          ...quizzes.map(
            (quiz) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(quiz.title),
              subtitle: Text('${quiz.startAtLabel} • ${quiz.durationLabel}'),
              trailing: FilledButton.tonal(
                onPressed: () => context.goNamed(
                  RouteNames.quizEntry,
                  pathParameters: {
                    'subjectId': quiz.subjectId,
                    'quizId': quiz.id,
                  },
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

