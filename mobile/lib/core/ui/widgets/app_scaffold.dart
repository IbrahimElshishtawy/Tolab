import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../redux/app_state.dart';
import '../../localization/localization_manager.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.role,
      builder: (context, role) {
        final navItems = _buildNavItems(role);

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _calculateSelectedIndex(context, navItems),
            onTap: (index) => _onItemTapped(index, context, navItems),
            items: navItems.map((e) => e.item).toList(),
          ),
        );
      },
    );
  }

  int _calculateSelectedIndex(BuildContext context, List<_NavItem> items) {
    final String location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) return i;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, List<_NavItem> items) {
    context.go(items[index].route);
  }

  List<_NavItem> _buildNavItems(String? role) {
    // For this task, we focus on Student side
    return [
      _NavItem(Icons.home, 'home_nav'.tr(), '/home'),
      _NavItem(Icons.book, 'subjects_nav'.tr(), '/subjects'),
      _NavItem(Icons.calendar_today, 'schedule_nav'.tr(), '/calendar'),
      _NavItem(Icons.group, 'community_nav'.tr(), '/community'),
      _NavItem(Icons.more_horiz, 'more_nav'.tr(), '/more'),
    ];
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem(this.icon, this.label, this.route);

  BottomNavigationBarItem get item => BottomNavigationBarItem(icon: Icon(icon), label: label);
}
