import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

class HomeNavigationShell extends ConsumerWidget {
  const HomeNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final palette = context.appColors;

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'الرئيسية',
      ),
      const NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'المواد',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded),
        label: 'الجدول',
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
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'الملف الشخصي',
      ),
    ];

    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 106,
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: palette.border),
              ),
              child: NavigationRail(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onTap,
                labelType: NavigationRailLabelType.all,
                backgroundColor: Colors.transparent,
                leading: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                  ),
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
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.24
                      : 0.08,
                ),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            destinations: destinations,
          ),
        ),
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
