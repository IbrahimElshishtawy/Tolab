import 'package:flutter/material.dart';
import 'lectures_screen.dart';
import 'sections_screen.dart';
import 'tasks_screen.dart';
import 'quizzes_screen.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final int subjectId;
  final String title;

  const SubjectDetailsScreen({super.key, required this.subjectId, required this.title});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Lectures'),
              Tab(text: 'Sections'),
              Tab(text: 'Tasks'),
              Tab(text: 'Quizzes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LecturesScreen(subjectId: subjectId),
            SectionsScreen(subjectId: subjectId),
            TasksScreen(subjectId: subjectId),
            QuizzesScreen(subjectId: subjectId),
          ],
        ),
      ),
    );
  }
}
