import 'package:flutter/material.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/business_widgets.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class SubjectDetailsScreen extends StatelessWidget {
  final int subjectId;
  final String title;

  const SubjectDetailsScreen({super.key, required this.subjectId, required this.title});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Grades'),
              Tab(text: 'Lectures'),
              Tab(text: 'Sections'),
              Tab(text: 'Summaries'),
              Tab(text: 'Tasks'),
              Tab(text: 'Exams'),
              Tab(text: 'Group'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PlaceholderList(title: 'Grades'),
            _PlaceholderList(title: 'Lectures'),
            _PlaceholderList(title: 'Sections'),
            _PlaceholderList(title: 'Summaries'),
            _PlaceholderList(title: 'Tasks'),
            _PlaceholderList(title: 'Exams'),
            _GroupView(),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderList extends StatelessWidget {
  final String title;
  const _PlaceholderList({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: 5,
      itemBuilder: (context, index) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          padding: EdgeInsets.zero,
          child: FileTile(
            fileName: '$title Item ${index + 1}',
            subtitle: 'Uploaded on Oct 12, 2023',
            fileType: index % 2 == 0 ? 'pdf' : 'doc',
            onOpen: () {},
            onDownload: () {},
          ),
        );
      },
    );
  }
}

class _GroupView extends StatelessWidget {
  const _GroupView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Subject Group Feed'));
  }
}
