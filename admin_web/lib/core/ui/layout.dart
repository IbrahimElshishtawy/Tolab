import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_web/main.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tolab Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Row(
        children: [
          _Sidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).uri.path;

    return Container(
      width: 250,
      color: Colors.grey.shade100,
      child: ListView(
        children: [
          _SidebarItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/',
            isActive: route == '/',
          ),
          _SidebarItem(
            icon: Icons.people,
            label: 'Students',
            route: '/students',
            isActive: route.startsWith('/students'),
          ),
          _SidebarItem(
            icon: Icons.school,
            label: 'Academic Structure',
            route: '/academic',
            isActive: route.startsWith('/academic'),
          ),
          _SidebarItem(
            icon: Icons.assignment_ind,
            label: 'Staff Assignment',
            route: '/staff',
            isActive: route.startsWith('/staff'),
          ),
          _SidebarItem(
            icon: Icons.calendar_month,
            label: 'Schedule',
            route: '/schedule',
            isActive: route.startsWith('/schedule'),
          ),
          _SidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            route: '/settings',
            isActive: route.startsWith('/settings'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Theme.of(context).primaryColor : null),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Theme.of(context).primaryColor : null,
          fontWeight: isActive ? FontWeight.bold : null,
        ),
      ),
      selected: isActive,
      onTap: () => context.go(route),
    );
  }
}
