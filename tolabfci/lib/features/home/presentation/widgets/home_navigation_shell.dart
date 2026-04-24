import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import 'student_adaptive_shell.dart';

class HomeNavigationShell extends ConsumerWidget {
  const HomeNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isStaff = ref.watch(isStaffUserProvider);

    final destinations = [
      StudentShellDestination(
        index: 0,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: isStaff
            ? context.tr('لوحة التحكم', 'Dashboard')
            : context.tr('الرئيسية', 'Home'),
      ),
      StudentShellDestination(
        index: 1,
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
        label: isStaff
            ? context.tr('المقررات', 'Courses')
            : context.tr('المواد', 'Subjects'),
      ),
      StudentShellDestination(
        index: 2,
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: context.tr('الجدول', 'Schedule'),
      ),
      StudentShellDestination(
        index: 3,
        icon: Icons.notifications_none_rounded,
        selectedIcon: Icons.notifications_rounded,
        label: context.tr('التنبيهات', 'Alerts'),
        badgeCount: unreadCount,
      ),
      StudentShellDestination(
        index: 4,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: context.tr('الملف الشخصي', 'Profile'),
      ),
    ];

    return StudentAdaptiveShell(
      navigationShell: navigationShell,
      destinations: destinations,
      isStaff: isStaff,
      onSelect: _onTap,
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
