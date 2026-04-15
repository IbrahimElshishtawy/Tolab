import 'package:flutter/widgets.dart';

import 'quiz_builder_page.dart';

class AddQuizPage extends StatelessWidget {
  const AddQuizPage({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context) {
    return QuizBuilderPage(subjectId: subjectId);
  }
}
