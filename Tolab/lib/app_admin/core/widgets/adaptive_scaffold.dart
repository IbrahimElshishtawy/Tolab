import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/localization/widgets/language_toggle_button.dart';
import '../../shared/widgets/status_badge.dart';
import '../animations/app_motion.dart';
import '../colors/app_colors.dart';
import '../constants/app_constants.dart';
import '../routing/route_paths.dart';
import '../responsive/app_breakpoints.dart';
import '../spacing/app_spacing.dart';
import 'app_card.dart';

class NavigationDestinationItem {
  const NavigationDestinationItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({
    super.key,
    required this.child,
    required this.location,
    required this.destinations,
    required this.userName,
    required this.userRole,
    required this.unreadNotifications,
    required this.notificationStatus,
    required this.notificationRoute,
    required this.onToggleTheme,
    required this.languageCode,
    required this.onLanguageSelected,
    required this.onLogout,
  });

  final Widget child;
  final String location;
  final List<NavigationDestinationItem> destinations;
  final String userName;
  final String userRole;
  final int unreadNotifications;
  final String notificationStatus;
  final String notificationRoute;
  final VoidCallback onToggleTheme;
  final String languageCode;
  final ValueChanged<String> onLanguageSelected;
  final VoidCallback onLogout;

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  bool _isSidebarCollapsed = false;
  DeviceScreenType? _lastScreenType;

  int _selectedIndex() {
    final index = widget.destinations.indexWhere(
      (item) =>
          widget.location == item.route ||
          widget.location.startsWith('${item.route}/'),
    );
    return index < 0 ? 0 : index;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenType = AppBreakpoints.resolve(context);
    if (_lastScreenType == screenType) return;

    _lastScreenType = screenType;
    if (screenType == DeviceScreenType.desktop) {
      _isSidebarCollapsed = false;
    } else if (screenType == DeviceScreenType.tablet) {
      _isSidebarCollapsed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenType = AppBreakpoints.resolve(context);
    final selectedIndex = _selectedIndex();
    final selected = widget.destinations[selectedIndex];
    final selectedLabel = context.l10n.t(selected.label);
    final isMobile = screenType == DeviceScreenType.mobile;
    final sidebarWidth = _isSidebarCollapsed
        ? AppConstants.collapsedSidebarWidth
        : AppConstants.desktopSidebarWidth;

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _Sidebar(
                    destinations: widget.destinations,
                    selectedIndex: selectedIndex,
                    isCollapsed: false,
                    unreadNotifications: widget.unreadNotifications,
                    notificationStatus: widget.notificationStatus,
                    onSelected: (route) {
                      Navigator.of(context).pop();
                      context.go(route);
                    },
                  ),
                ),
              ),
            )
          : null,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).cardColor.withValues(alpha: 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -40,
              child: _BackdropOrb(
                color: AppColors.primary.withValues(alpha: 0.10),
                size: 320,
              ),
            ),
            Positioned(
              bottom: -180,
              left: -80,
              child: _BackdropOrb(
                color: AppColors.info.withValues(alpha: 0.10),
                size: 380,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile)
                      AnimatedContainer(
                        duration: AppMotion.medium,
                        curve: AppMotion.emphasized,
                        width: sidebarWidth,
                        child: _Sidebar(
                          destinations: widget.destinations,
                          selectedIndex: selectedIndex,
                          isCollapsed: _isSidebarCollapsed,
                          unreadNotifications: widget.unreadNotifications,
                          notificationStatus: widget.notificationStatus,
                          onSelected: (route) => context.go(route),
                        ),
                      ),
                    if (!isMobile) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        children: [
                          _TopBar(
                            title: selectedLabel,
                            subtitle: _subtitleFor(context, selected.label),
                            userName: widget.userName,
                            userRole: widget.userRole,
                            unreadNotifications: widget.unreadNotifications,
                            notificationStatus: widget.notificationStatus,
                            notificationRoute: widget.notificationRoute,
                            isMobile: isMobile,
                            onMenuPressed: () => setState(
                              () => _isSidebarCollapsed = !_isSidebarCollapsed,
                            ),
                            onToggleTheme: widget.onToggleTheme,
                            languageCode: widget.languageCode,
                            onLanguageSelected: widget.onLanguageSelected,
                            onLogout: widget.onLogout,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: AppConstants.shellMaxContentWidth,
                                ),
                                child: TweenAnimationBuilder<double>(
                                  key: ValueKey(widget.location),
                                  tween: Tween(begin: 0, end: 1),
                                  duration: AppMotion.medium,
                                  curve: AppMotion.entrance,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset((1 - value) * 24, 0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: widget.child,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(BuildContext context, String titleKey) =>
      switch (titleKey) {
        'layout.admin.nav.dashboard' => context.l10n.t(
          'layout.admin.subtitle.dashboard',
        ),
        'layout.admin.nav.students' => context.l10n.t(
          'layout.admin.subtitle.students',
        ),
        'layout.admin.nav.staff' => context.l10n.t(
          'layout.admin.subtitle.staff',
        ),
        'layout.admin.nav.departments' => context.l10n.t(
          'layout.admin.subtitle.departments',
        ),
        'layout.admin.nav.schedule' => context.l10n.t(
          'layout.admin.subtitle.schedule',
        ),
        'layout.admin.nav.moderation' => context.l10n.t(
          'layout.admin.subtitle.moderation',
        ),
        'layout.admin.nav.settings' => context.l10n.t(
          'layout.admin.subtitle.settings',
        ),
        _ => context.l10n.t('layout.admin.subtitle.default'),
      };
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destinations,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.unreadNotifications,
    required this.notificationStatus,
    required this.onSelected,
  });

  final List<NavigationDestinationItem> destinations;
  final int selectedIndex;
  final bool isCollapsed;
  final int unreadNotifications;
  final String notificationStatus;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: isDark ? AppColors.sidebarDark : AppColors.sidebarLight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showBrandText = !isCollapsed && constraints.maxWidth > 168;
          final showLiveStatus =
              !isCollapsed &&
              constraints.maxHeight > 560 &&
              constraints.maxWidth > 184;
          final showSeasonCard =
              !isCollapsed &&
              constraints.maxHeight > 720 &&
              constraints.maxWidth > 220;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: isCollapsed ? 40 : 44,
                    width: isCollapsed ? 40 : 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.info],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (showBrandText) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.t('layout.admin.brand.title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.t('layout.admin.brand.subtitle'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (showLiveStatus) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusBadge('Live', icon: Icons.bolt_rounded),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notificationStatus,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
              if (!isCollapsed) const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.separated(
                  itemCount: destinations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = destinations[index];
                    return _SidebarNavTile(
                      item: item,
                      selected: index == selectedIndex,
                      collapsed: isCollapsed,
                      badgeCount: item.route == RoutePaths.notifications
                          ? unreadNotifications
                          : 0,
                      onTap: () => onSelected(item.route),
                    );
                  },
                ),
              ),
              if (showSeasonCard) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                    border: Border.all(
                      color: isDark
                          ? AppColors.strokeDark
                          : AppColors.strokeLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.t('layout.admin.season.title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.t('layout.admin.season.subtitle'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SidebarNavTile extends StatefulWidget {
  const _SidebarNavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.badgeCount,
    required this.onTap,
  });

  final NavigationDestinationItem item;
  final bool selected;
  final bool collapsed;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  State<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<_SidebarNavTile> {
  static const double _expandedTileWidthThreshold = 164;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selected;
    final backgroundColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.12)
        : _hovered
        ? AppColors.primary.withValues(alpha: 0.06)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.transparent,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showExpandedTile =
                !widget.collapsed &&
                constraints.maxWidth >= _expandedTileWidthThreshold;

            if (!showExpandedTile) {
              return _CompactSidebarNavTile(
                icon: widget.item.icon,
                label: context.l10n.t(widget.item.label),
                isSelected: isSelected,
                badgeCount: widget.badgeCount,
                onTap: widget.onTap,
              );
            }

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 2,
              ),
              onTap: widget.onTap,
              leading: Icon(
                widget.item.icon,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).iconTheme.color,
              ),
              title: Text(context.l10n.t(widget.item.label)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.badgeCount > 0)
                    _NotificationCountBadge(count: widget.badgeCount),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompactSidebarNavTile extends StatelessWidget {
  const _CompactSidebarNavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected
        ? AppColors.primary
        : Theme.of(context).iconTheme.color;

    return Tooltip(
      message: context.l10n.byValue(label),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: iconColor),
                  if (badgeCount > 0)
                    Positioned(
                      top: -3,
                      right: -4,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.userName,
    required this.userRole,
    required this.unreadNotifications,
    required this.notificationStatus,
    required this.notificationRoute,
    required this.isMobile,
    required this.onMenuPressed,
    required this.onToggleTheme,
    required this.languageCode,
    required this.onLanguageSelected,
    required this.onLogout,
  });

  final String title;
  final String subtitle;
  final String userName;
  final String userRole;
  final int unreadNotifications;
  final String notificationStatus;
  final String notificationRoute;
  final bool isMobile;
  final VoidCallback onMenuPressed;
  final VoidCallback onToggleTheme;
  final String languageCode;
  final ValueChanged<String> onLanguageSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showContextStrip = constraints.maxWidth > 860;
          final compactTopBar = constraints.maxWidth < (isMobile ? 460 : 720);
          final showStatusBadge = !isMobile && constraints.maxWidth > 960;
          final showUserMeta = !isMobile && constraints.maxWidth > 780;

          final profileChip = Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    userName.characters.first.toUpperCase(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
                if (showUserMeta) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        context.l10n.byValue(userRole.replaceAll('_', ' ')),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );

          return Column(
            children: [
              if (compactTopBar)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (isMobile) {
                              Scaffold.maybeOf(context)?.openDrawer();
                            } else {
                              onMenuPressed();
                            }
                          },
                          icon: Icon(
                            isMobile
                                ? Icons.menu_rounded
                                : Icons.menu_open_rounded,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.end,
                        children: [
                          if (showStatusBadge)
                            StatusBadge(
                              notificationStatus,
                              icon: Icons.radio_button_checked,
                            ),
                          LanguageToggleButton(
                            languageCode: languageCode,
                            onSelected: onLanguageSelected,
                          ),
                          IconButton(
                            onPressed: onToggleTheme,
                            tooltip: context.l10n.t(
                              'common.actions.toggle_theme',
                            ),
                            icon: const Icon(Icons.contrast_rounded),
                          ),
                          _NotificationBellButton(
                            count: unreadNotifications,
                            onPressed: () => context.go(notificationRoute),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'logout') onLogout();
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'logout',
                                child: Text(
                                  context.l10n.t('common.actions.logout'),
                                ),
                              ),
                            ],
                            child: profileChip,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (isMobile) {
                          Scaffold.maybeOf(context)?.openDrawer();
                        } else {
                          onMenuPressed();
                        }
                      },
                      icon: Icon(
                        isMobile ? Icons.menu_rounded : Icons.menu_open_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (showStatusBadge) ...[
                      StatusBadge(
                        notificationStatus,
                        icon: Icons.radio_button_checked,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    LanguageToggleButton(
                      languageCode: languageCode,
                      onSelected: onLanguageSelected,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: onToggleTheme,
                      tooltip: context.l10n.t('common.actions.toggle_theme'),
                      icon: const Icon(Icons.contrast_rounded),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _NotificationBellButton(
                      count: unreadNotifications,
                      onPressed: () => context.go(notificationRoute),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') onLogout();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'logout',
                          child: Text(context.l10n.t('common.actions.logout')),
                        ),
                      ],
                      child: profileChip,
                    ),
                  ],
                ),
              if (showContextStrip) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppConstants.mediumRadius,
                        ),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            context.l10n.t('layout.admin.context.workspace'),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.mediumRadius,
                        ),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            notificationStatus,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          AppConstants.mediumRadius,
                        ),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        if (count > 0)
          Positioned(
            top: -2,
            right: -2,
            child: _NotificationCountBadge(count: count),
          ),
      ],
    );
  }
}

class _NotificationCountBadge extends StatelessWidget {
  const _NotificationCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
