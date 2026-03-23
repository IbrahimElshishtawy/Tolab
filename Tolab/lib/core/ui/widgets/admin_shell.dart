import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

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
              destinations: const [
                NavigationDestination(
                  icon: Icon(CupertinoIcons.person_2),
                  selectedIcon: Icon(CupertinoIcons.person_2_fill),
                  label: 'Users',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.book),
                  selectedIcon: Icon(CupertinoIcons.book_fill),
                  label: 'Subjects',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.doc_text),
                  selectedIcon: Icon(CupertinoIcons.doc_text_fill),
                  label: 'Content',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.shield),
                  selectedIcon: Icon(CupertinoIcons.shield_fill),
                  label: 'Moderation',
                ),
                NavigationDestination(
                  icon: Icon(CupertinoIcons.ellipsis_circle),
                  selectedIcon: Icon(CupertinoIcons.ellipsis_circle_fill),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/admin/users')) return 0;
    if (location.startsWith('/admin/subjects')) return 1;
    if (location.startsWith('/admin/content')) return 2;
    if (location.startsWith('/admin/moderation')) return 3;
    if (location.startsWith('/admin/offerings') ||
        location.startsWith('/admin/schedule') ||
        location.startsWith('/admin/broadcast')) {
      return 4;
    }
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
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assignment_ind),
              title: const Text('Enrollments'),
              onTap: () {
                Navigator.pop(context);
                context.go('/admin/offerings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Schedule'),
              onTap: () {
                Navigator.pop(context);
                context.go('/admin/schedule');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Broadcast'),
              onTap: () {
                Navigator.pop(context);
                context.go('/admin/broadcast');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
