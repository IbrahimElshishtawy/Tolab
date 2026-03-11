import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tolab_fci/core/localization/localization_manager.dart';

class StudentShell extends StatelessWidget {
  final Widget child;

  const StudentShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: NavigationBar(
              selectedIndex: _getSelectedIndex(location),
              onDestinationSelected: (index) => _onItemTapped(index, context),
              height: 76,
              backgroundColor: const Color(0xEAF8FBFF),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorColor: const Color(0xFFDEEBFF),
              destinations: [
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.house),
                  selectedIcon: const Icon(CupertinoIcons.house_fill),
                  label: 'home_nav'.tr(),
                ),
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.book),
                  selectedIcon: const Icon(CupertinoIcons.book_fill),
                  label: 'subjects_nav'.tr(),
                ),
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.calendar),
                  selectedIcon: const Icon(CupertinoIcons.calendar_today),
                  label: 'schedule_nav'.tr(),
                ),
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.bubble_left_bubble_right),
                  selectedIcon:
                      const Icon(CupertinoIcons.bubble_left_bubble_right_fill),
                  label: 'community_nav'.tr(),
                ),
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.square_grid_2x2),
                  selectedIcon:
                      const Icon(CupertinoIcons.square_grid_2x2_fill),
                  label: 'more_nav'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/subjects')) return 1;
    if (location.startsWith('/calendar')) return 2;
    if (location.startsWith('/community')) return 3;
    if (location.startsWith('/more') ||
        location.startsWith('/profile') ||
        location.startsWith('/notifications')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/subjects');
        break;
      case 2:
        context.go('/calendar');
        break;
      case 3:
        context.go('/community');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }
}
