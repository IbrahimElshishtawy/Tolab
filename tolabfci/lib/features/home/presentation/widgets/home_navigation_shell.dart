import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/router/route_names.dart';
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
      _ShellDestination(
        index: 0,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: isStaff
            ? context.tr('لوحة التحكم', 'Dashboard')
            : context.tr('الرئيسية', 'Home'),
      ),
      _ShellDestination(
        index: 1,
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
        label: isStaff
            ? context.tr('المقررات', 'Courses')
            : context.tr('المواد', 'Subjects'),
      ),
      _ShellDestination(
        index: 2,
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: context.tr('الجدول', 'Schedule'),
      ),
      _ShellDestination(
        index: 3,
        icon: Icons.notifications_none_rounded,
        selectedIcon: Icons.notifications_rounded,
        label: context.tr('التنبيهات', 'Alerts'),
        badgeCount: unreadCount,
      ),
      _ShellDestination(
        index: 4,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: context.tr('الملف الشخصي', 'Profile'),
      ),
    ];

    if (context.isDesktop) {
      return Scaffold(
        backgroundColor: palette.background,
        body: Row(
          children: [
            _DesktopSidebar(
              destinations: destinations,
              currentIndex: navigationShell.currentIndex,
              isStaff: isStaff,
              onSelect: _onTap,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      body: navigationShell,
      floatingActionButton: isStaff ? null : const _MoreMenuButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: palette.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.24
                      : 0.08,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  icon: _NavigationIcon(
                    icon: destination.icon,
                    badgeCount: destination.badgeCount,
                  ),
                  selectedIcon: _NavigationIcon(
                    icon: destination.selectedIcon,
                    badgeCount: destination.badgeCount,
                  ),
                  label: destination.label,
                ),
            ],
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

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.destinations,
    required this.currentIndex,
    required this.isStaff,
    required this.onSelect,
  });

  final List<_ShellDestination> destinations;
  final int currentIndex;
  final bool isStaff;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      width: 286,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tolab Student OS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isStaff
                            ? 'Workspace with fast academic control'
                            : 'Academic assistant with live priorities',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final destination in destinations) ...[
                  _SidebarDestinationTile(
                    destination: destination,
                    isSelected: currentIndex == destination.index,
                    onTap: () => onSelect(destination.index),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (!isStaff) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Shortcuts',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SidebarShortcut(
                    icon: Icons.quiz_outlined,
                    title: 'Quizzes',
                    subtitle: 'Open and upcoming',
                    onTap: () => context.goNamed(RouteNames.quizzes),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SidebarShortcut(
                    icon: Icons.assignment_outlined,
                    title: 'Assignments',
                    subtitle: 'Uploads and deadlines',
                    onTap: () => context.goNamed(RouteNames.assignments),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SidebarShortcut(
                    icon: Icons.bar_chart_rounded,
                    title: 'Results',
                    subtitle: 'Grades and analysis',
                    onTap: () => context.goNamed(RouteNames.results),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarDestinationTile extends StatelessWidget {
  const _SidebarDestinationTile({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final iconData = isSelected ? destination.selectedIcon : destination.icon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? palette.primarySoft : palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : palette.border,
          ),
        ),
        child: Row(
          children: [
            _NavigationIcon(
              icon: iconData,
              badgeCount: destination.badgeCount,
              forceSelectedColor: isSelected,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                destination.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarShortcut extends StatelessWidget {
  const _SidebarShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenuButton extends StatelessWidget {
  const _MoreMenuButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MoreAction>(
      tooltip: 'المزيد',
      onSelected: (value) {
        switch (value) {
          case _MoreAction.quizzes:
            context.goNamed(RouteNames.quizzes);
          case _MoreAction.assignments:
            context.goNamed(RouteNames.assignments);
          case _MoreAction.results:
            context.goNamed(RouteNames.results);
          case _MoreAction.settings:
            context.goNamed(RouteNames.settings);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _MoreAction.quizzes,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.quiz_outlined),
            title: Text('الكويزات'),
          ),
        ),
        PopupMenuItem(
          value: _MoreAction.assignments,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.assignment_outlined),
            title: Text('التكليفات'),
          ),
        ),
        PopupMenuItem(
          value: _MoreAction.results,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.bar_chart_rounded),
            title: Text('النتائج'),
          ),
        ),
        PopupMenuItem(
          value: _MoreAction.settings,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined),
            title: Text('الإعدادات'),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.grid_view_rounded, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'المزيد',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.icon,
    this.badgeCount = 0,
    this.forceSelectedColor = false,
  });

  final IconData icon;
  final int badgeCount;
  final bool forceSelectedColor;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      color: forceSelectedColor ? AppColors.primary : null,
    );

    if (badgeCount <= 0) {
      return iconWidget;
    }

    return Badge.count(
      count: badgeCount,
      isLabelVisible: badgeCount > 0,
      child: iconWidget,
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;
}

enum _MoreAction { quizzes, assignments, results, settings }
