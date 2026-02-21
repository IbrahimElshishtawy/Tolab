import 'package:flutter/material.dart';
import 'package:tolab_fci/features/schedule/presentation/screens/schedule_tab.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
        title: Text(
          'جدول الحضور',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicator: BoxDecoration(
            color: Color(0xFF023EC5).withOpacity(.2),
            borderRadius: BorderRadius.circular(15),
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'السبت'),
            Tab(text: 'الاحد'),
            Tab(text: 'الاثنين'),
            Tab(text: 'الثلاثاء'),
            Tab(text: 'الاربعاء'),
            Tab(text: 'الخميس'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(6, (index) {
          return ScheduleTab();
        }),
      ),
    );
  }
}
