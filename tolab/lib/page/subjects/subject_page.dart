import 'package:flutter/material.dart';
import 'package:tolab/page/subjects/presentation/tabs/details_tab.dart';
import 'package:tolab/page/subjects/presentation/tabs/exams_tab.dart';
import 'package:tolab/page/subjects/presentation/tabs/lectures_tab.dart';
import 'package:tolab/page/subjects/presentation/tabs/links_tab.dart';

class SubjectPage extends StatefulWidget {
  final String subjectId;
  const SubjectPage({super.key, required this.subjectId});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("صفحة المادة"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "المحاضرات"),
            Tab(text: "التفاصيل"),
            Tab(text: "الامتحانات"),
            Tab(text: "الروابط"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [LecturesTab(), DetailsTab(), ExamsTab(), LinksTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: إضافة ملف جديد
          debugPrint("إضافة عنصر جديد");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
