import 'package:flutter/material.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final int subjectId;
  final String subjectName;

  const SubjectDetailsScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(subjectName),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Lectures'),
              Tab(text: 'Sections'),
              Tab(text: 'Quizzes'),
              Tab(text: 'Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent('Lectures'),
            _buildTabContent('Sections'),
            _buildTabContent('Quizzes'),
            _buildTabContent('Tasks'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String type) {
    return const Center(child: Text('Content Placeholder'));
  }
}
