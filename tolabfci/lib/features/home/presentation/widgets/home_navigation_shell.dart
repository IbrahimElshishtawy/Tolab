import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

class HomeNavigationShell extends ConsumerWidget {
  const HomeNavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'الرئيسية',
      ),
      const NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'المواد الدراسية',
      ),
      NavigationDestination(
        icon: Badge.count(
          count: unreadCount,
          isLabelVisible: unreadCount > 0,
          child: const Icon(Icons.notifications_none_rounded),
        ),
        selectedIcon: Badge.count(
          count: unreadCount,
          isLabelVisible: unreadCount > 0,
          child: const Icon(Icons.notifications_rounded),
        ),
        label: 'التنبيهات',
      ),
      const NavigationDestination(
        icon: Icon(Icons.insert_chart_outlined_rounded),
        selectedIcon: Icon(Icons.insert_chart_rounded),
        label: 'النتائج',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'الملف الشخصي',
      ),
    ];

    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: Icon(Icons.school_rounded),
              ),
              destinations: destinations
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: destination.icon,
                      selectedIcon: destination.selectedIcon,
                      label: Text(destination.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: destinations,
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
