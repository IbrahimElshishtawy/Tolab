// lib/features/subject/presentation/subject_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/page/subject/ui/subject/Subject_View_Model.dart';

import 'tabs/lectures_tab.dart';
import 'tabs/details_tab.dart';
import 'tabs/exams_tab.dart';
import 'tabs/links_tab.dart';

class SubjectPage extends StatefulWidget {
  final String subjectId;
  const SubjectPage({super.key, required this.subjectId});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SubjectViewModel>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? Colors.blueAccent : Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text('محتوى المادة')),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'محاضرات'),
            Tab(text: 'شرح مفصل'),
            Tab(text: 'اختبارات سابقة'),
            Tab(text: 'روابط مفيدة'),
          ],
          indicatorColor: accent,
          labelColor: accent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LecturesTab(subjectId: widget.subjectId),
          DetailsTab(subjectId: widget.subjectId),
          ExamsTab(subjectId: widget.subjectId),
          LinksTab(subjectId: widget.subjectId),
        ],
      ),
    );
  }
}
