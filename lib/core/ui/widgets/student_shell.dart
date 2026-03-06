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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(location),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'home_nav'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: 'subjects_nav'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: 'schedule_nav'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: 'community_nav'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: 'more_nav'.tr(),
          ),
        ],
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
