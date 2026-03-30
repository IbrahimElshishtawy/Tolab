import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/core/animations/app_motion.dart';
import '../../app/core/colors/app_colors.dart';
import '../../app/core/constants/app_constants.dart';
import '../../app/core/spacing/app_spacing.dart';
import '../../app/core/widgets/app_card.dart';
import '../models/academy_models.dart';

class AcademyShell extends StatefulWidget {
  const AcademyShell({
    super.key,
    required this.role,
    required this.currentPageKey,
    required this.navigationItems,
    required this.user,
    required this.unreadCount,
    required this.onLogout,
    required this.onToggleTheme,
    required this.child,
  });

  final AcademyRole role;
  final String currentPageKey;
  final List<RoleNavItem> navigationItems;
  final AcademyUser user;
  final int unreadCount;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final Widget child;

  @override
  State<AcademyShell> createState() => _AcademyShellState();
}

class _AcademyShellState extends State<AcademyShell> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 1024;
    return Scaffold(
      drawer: isCompact
          ? Drawer(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _Sidebar(
                  role: widget.role,
                  currentPageKey: widget.currentPageKey,
                  navigationItems: widget.navigationItems,
                  unreadCount: widget.unreadCount,
                  collapsed: false,
                ),
              ),
            )
          : null,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                if (!isCompact)
                  AnimatedContainer(
                    duration: AppMotion.medium,
                    width: _collapsed ? 104 : 292,
                    child: _Sidebar(
                      role: widget.role,
                      currentPageKey: widget.currentPageKey,
                      navigationItems: widget.navigationItems,
                      unreadCount: widget.unreadCount,
                      collapsed: _collapsed,
                    ),
                  ),
                if (!isCompact) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    children: [
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Builder(
                              builder: (innerContext) {
                                return IconButton(
                                  onPressed: () {
                                    if (isCompact) {
                                      Scaffold.maybeOf(
                                        innerContext,
                                      )?.openDrawer();
                                    } else {
                                      setState(() => _collapsed = !_collapsed);
                                    }
                                  },
                                  icon: Icon(
                                    isCompact
                                        ? Icons.menu_rounded
                                        : Icons.menu_open_rounded,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.role.shellTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.user.department ?? widget.role.label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (!isCompact)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('Unread: ${widget.unreadCount}'),
                              ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              onPressed: widget.onToggleTheme,
                              icon: const Icon(Icons.contrast_rounded),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'logout') {
                                  widget.onLogout();
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'logout',
                                  child: Text('Logout'),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.mediumRadius,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        widget.user.name.characters.first
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (!isCompact) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.user.name),
                                          Text(widget.role.label),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.role,
    required this.currentPageKey,
    required this.navigationItems,
    required this.unreadCount,
    required this.collapsed,
  });

  final AcademyRole role;
  final String currentPageKey;
  final List<RoleNavItem> navigationItems;
  final int unreadCount;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.info],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(switch (role) {
                  AcademyRole.admin => Icons.admin_panel_settings_rounded,
                  AcademyRole.student => Icons.school_rounded,
                  AcademyRole.doctor => Icons.cast_for_education_rounded,
                }, color: Colors.white),
              ),
              if (!collapsed) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(switch (role) {
                        AcademyRole.admin =>
                          'Operations, governance, and delivery',
                        AcademyRole.student =>
                          'Learning, planning, and progress',
                        AcademyRole.doctor =>
                          'Teaching, publishing, and feedback',
                      }, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView.separated(
              itemCount: navigationItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = navigationItems[index];
                final selected = item.key == currentPageKey;
                return AnimatedContainer(
                  duration: AppMotion.fast,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallRadius,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: selected ? AppColors.primary : null,
                    ),
                    title: collapsed ? null : Text(item.title),
                    subtitle: collapsed ? null : Text(item.description),
                    trailing: collapsed
                        ? null
                        : (item.key == 'notifications' && unreadCount > 0)
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go(item.route),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
