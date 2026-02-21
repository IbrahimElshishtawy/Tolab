import 'package:flutter/material.dart';
import 'package:tolab_fci/features/community/presentation/screens/individual_chats_Tab.dart';
import 'package:tolab_fci/features/community/presentation/screens/study_groups_tab.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "المحادثات",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8EEF8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: const Color(0xff0B4CD9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: "محادثات فردية"),
                        Tab(text: "جروبات دراسية"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Expanded(
                  child: TabBarView(
                    children: [IndividualChatsTab(), StudyGroupsTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
