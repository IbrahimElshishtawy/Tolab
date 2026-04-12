import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_list_tile.dart';

class QuizListTile extends StatelessWidget {
  const QuizListTile({
    super.key,
    required this.quiz,
  });

  final QuizItem quiz;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: quiz.title,
      subtitle: '${quiz.startAtLabel} • ${quiz.durationLabel}',
      leading: Icon(quiz.isOnline ? Icons.laptop_chromebook_rounded : Icons.location_on_outlined),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBadge(label: quiz.typeLabel),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => context.goNamed(
              RouteNames.quizEntry,
              pathParameters: {
                'subjectId': quiz.subjectId,
                'quizId': quiz.id,
              },
            ),
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ),
        ],
      ),
    );
  }
}
