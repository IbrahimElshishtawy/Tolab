import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../models/session_user.dart';
import '../responsive/app_breakpoints.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.user,
    required this.title,
    required this.activePath,
    required this.body,
    required this.items,
    this.trailing,
  });

  final SessionUser user;
  final String title;
  final String activePath;
  final Widget body;
  final List<ShellNavItem> items;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final selectedIndex = items.indexWhere((item) => activePath == item.path);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${user.fullName} • ${user.roleType.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    final content = SafeArea(
      child: Column(
        children: [
          header,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: body,
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 280,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tolab',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Academic staff workspace',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: .8),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        selected: item.path == activePath,
                        selectedTileColor: AppColors.white.withValues(alpha: .12),
                        leading: Icon(item.icon, color: AppColors.white),
                        title: Text(
                          item.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.white,
                              ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        onTap: () => context.go(item.path),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ],
      );
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
        onDestinationSelected: (index) => context.go(items[index].path),
      ),
    );
  }
}

class ShellNavItem {
  const ShellNavItem({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}
