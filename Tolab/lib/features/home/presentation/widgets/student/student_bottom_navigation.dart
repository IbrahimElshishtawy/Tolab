import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudentBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const StudentBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            height: 76,
            backgroundColor: const Color(0xDFFFFFFF),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorColor: const Color(0xFFE5EEFF),
            destinations: const [
              NavigationDestination(
                icon: Icon(CupertinoIcons.house),
                selectedIcon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.book),
                selectedIcon: Icon(CupertinoIcons.book_fill),
                label: 'Subjects',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.calendar),
                selectedIcon: Icon(CupertinoIcons.calendar_today),
                label: 'Schedule',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.bubble_left_bubble_right),
                selectedIcon:
                    Icon(CupertinoIcons.bubble_left_bubble_right_fill),
                label: 'Community',
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.person_circle),
                selectedIcon: Icon(CupertinoIcons.person_circle_fill),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
