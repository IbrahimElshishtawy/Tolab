import 'package:flutter/material.dart';

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
        children: [
          LecturesTab(subjectId: widget.subjectId),
          DetailsTab(subjectId: widget.subjectId),
          ExamsTab(subjectId: widget.subjectId),
          LinksTab(subjectId: widget.subjectId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // إضافة ملف جديد
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
