import 'package:flutter/material.dart';

class QuizzesScreen extends StatelessWidget {
  final int subjectId;
  const QuizzesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Quizzes List'));
  }
}
