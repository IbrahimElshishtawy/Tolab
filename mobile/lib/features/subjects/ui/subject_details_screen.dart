import 'package:flutter/material.dart';
import 'widgets/details_tabs.dart';
import 'tasks_screen.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final int subjectId;
  final String title;

  const SubjectDetailsScreen({super.key, required this.subjectId, required this.title});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Lectures'),
              Tab(text: 'Sections'),
              Tab(text: 'Tasks'),
              Tab(text: 'Quizzes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SubjectOverview(subjectId: subjectId),
            LecturesList(subjectId: subjectId),
            SectionsList(subjectId: subjectId),
            TasksScreen(subjectId: subjectId),
            QuizzesList(subjectId: subjectId),
          ],
        ),
      ),
    );
  }
}
