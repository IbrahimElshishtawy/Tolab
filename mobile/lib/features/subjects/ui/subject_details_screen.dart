import 'package:flutter/material.dart';

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
            _buildTabContent('Lectures'),
            _buildTabContent('Sections'),
            _buildTabContent('Tasks'),
            _buildTabContent('Quizzes'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String type) {
    return Center(child: Text('$type content for subject $subjectId'));
  }
}
