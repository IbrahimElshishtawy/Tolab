import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'student_adaptive_shell.dart';

class StudentMobileNav extends StatelessWidget {
  const StudentMobileNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<StudentShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppColorsScheme>()!;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(26),
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
          selectedIndex: currentIndex,
          onDestinationSelected: onSelect,
          backgroundColor: Colors.transparent,
          indicatorColor: palette.primarySoft,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: _NavIcon(
                  icon: destination.icon,
                  badgeCount: destination.badgeCount,
                ),
                selectedIcon: _NavIcon(
                  icon: destination.selectedIcon,
                  badgeCount: destination.badgeCount,
                  selected: true,
                ),
                label: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.badgeCount,
    this.selected = false,
  });

  final IconData icon;
  final int badgeCount;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final child = Icon(
      icon,
      size: 22,
      color: selected ? AppColors.primary : null,
    );
    if (badgeCount <= 0) {
      return child;
    }
    return Badge.count(count: badgeCount, child: child);
  }
}
