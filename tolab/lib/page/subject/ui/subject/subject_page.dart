import 'package:flutter/material.dart';
import 'package:tolab/page/subject/ui/subject/tabs/details_tab.dart';
import 'package:tolab/page/subject/ui/subject/tabs/exams_tab.dart';
import 'package:tolab/page/subject/ui/subject/tabs/lectures_tab.dart';
import 'package:tolab/page/subject/ui/subject/tabs/links_tab.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('محتوى المادة'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'محاضرات'),
            Tab(text: 'شرح مفصل'),
            Tab(text: 'اختبارات سابقة'),
            Tab(text: 'روابط مفيدة'),
          ],
          indicatorColor: Colors.white,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark
            ? Colors.blueAccent
            : Theme.of(context).primaryColor,
        onPressed: () {
          // تنفيذ حسب التبويب الحالي
          final index = _tabController.index;
          if (index == 0) {
            // رفع محاضرة
          } else if (index == 1) {
            // رفع شرح
          } else if (index == 2) {
            // رفع امتحان
          } else if (index == 3) {
            // رفع رابط
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
