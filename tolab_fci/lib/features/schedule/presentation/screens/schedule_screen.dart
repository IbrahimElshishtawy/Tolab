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
        title: Text('جدول الحضور',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          padding: EdgeInsets.zero,
          tabAlignment: TabAlignment.start,
          labelColor: Color(0xFF000000),
          labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          indicatorWeight: 1,
          indicator: BoxDecoration(
            boxShadow:  [
              BoxShadow(
                color: Color(0xFF023EC5),
                blurRadius: 55,
              ),
            ],
          ),
          tabs: [
            Tab(text: 'السبت',),
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
