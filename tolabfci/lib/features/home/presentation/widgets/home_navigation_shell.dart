import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

class HomeNavigationShell extends ConsumerWidget {
  const HomeNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isStaff = ref.watch(isStaffUserProvider);
    final palette = context.appColors;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: isStaff
            ? context.tr('لوحة التحكم', 'Dashboard')
            : context.tr('الرئيسية', 'Home'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book_rounded),
        label: isStaff
            ? context.tr('المقررات', 'Courses')
            : context.tr('المواد', 'Subjects'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month_rounded),
        label: context.tr('الجدول', 'Schedule'),
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
        label: context.tr('التنبيهات', 'Alerts'),
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: context.tr('الملف الشخصي', 'Profile'),
      ),
    ];

    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 112,
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
