import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tolab_fci/core/localization/localization_manager.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

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
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: const Icon(Icons.upload_file_outlined),
            selectedIcon: const Icon(Icons.upload_file),
            label: 'Content',
          ),
          NavigationDestination(
            icon: const Icon(Icons.gavel_outlined),
            selectedIcon: const Icon(Icons.gavel),
            label: 'Moderation',
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/admin/users')) return 0;
    if (location.startsWith('/admin/subjects')) return 1;
    if (location.startsWith('/admin/content')) return 2;
    if (location.startsWith('/admin/moderation')) return 3;
    if (location.startsWith('/admin/broadcast')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin/users');
        break;
      case 1:
        context.go('/admin/subjects');
        break;
      case 2:
        context.go('/admin/content');
        break;
      case 3:
        context.go('/admin/moderation');
        break;
      case 4:
        context.go('/admin/broadcast');
        break;
    }
  }
}
