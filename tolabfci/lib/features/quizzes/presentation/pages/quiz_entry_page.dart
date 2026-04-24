import 'package:flutter/material.dart';

import 'quiz_details_page.dart';

class QuizEntryPage extends StatelessWidget {
  const QuizEntryPage({
    super.key,
    required this.subjectId,
    required this.quizId,
  });

  final String subjectId;
  final String quizId;

  @override
  Widget build(BuildContext context) {
    return QuizDetailsPage(subjectId: subjectId, quizId: quizId);
  }
}
