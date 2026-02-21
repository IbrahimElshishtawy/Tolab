import 'package:flutter/material.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/lectures_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/quizzes_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/sections_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/summaries_screen.dart';
import 'package:tolab_fci/features/subjects/presentation/screens/tasks_screen.dart';

class SubjectDetailsScreen extends StatefulWidget {
  const SubjectDetailsScreen({super.key});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> titles = [
    "محاضرات",
    "سكاشن",
    "ملخصات",
    "مهام",
    "اختبارات",
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: titles.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            titles[currentIndex],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F3F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: "محاضرات"),
                    Tab(text: "سكاشن"),
                    Tab(text: "ملخصات"),
                    Tab(text: "مهام"),
                    Tab(text: "اختبارات"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  LecturesScreen(),
                  SectionsScreen(),
                  SummariesScreen(),
                  TasksScreen(),
                  QuizzesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
