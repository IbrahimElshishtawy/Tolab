import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../responsive/app_breakpoints.dart';
import '../spacing/app_spacing.dart';
import '../../shared/widgets/status_badge.dart';

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

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.child,
    required this.location,
    required this.destinations,
    required this.userName,
    required this.userRole,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final Widget child;
  final String location;
  final List<NavigationDestinationItem> destinations;
  final String userName;
  final String userRole;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  int _selectedIndex() {
    final index = destinations.indexWhere(
      (item) => location == item.route || location.startsWith('${item.route}/'),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final screenType = AppBreakpoints.resolve(context);
    final selectedIndex = _selectedIndex();
    final selected = destinations[selectedIndex];

    final navigation = screenType == DeviceScreenType.mobile
        ? null
        : _Sidebar(
            screenType: screenType,
            destinations: destinations,
            selectedIndex: selectedIndex,
          );

    return Scaffold(
      drawer: screenType == DeviceScreenType.mobile
          ? Drawer(
              child: _Sidebar(
                screenType: screenType,
                destinations: destinations,
                selectedIndex: selectedIndex,
              ),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).cardColor.withValues(alpha: 0.92),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (navigation != null) navigation,
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      title: selected.label,
                      userName: userName,
                      userRole: userRole,
                      onToggleTheme: onToggleTheme,
                      onLogout: onLogout,
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppConstants.shellMaxContentWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: child,
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
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.screenType,
    required this.destinations,
    required this.selectedIndex,
  });

  final DeviceScreenType screenType;
  final List<NavigationDestinationItem> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isCompact = screenType == DeviceScreenType.tablet;
    final width = isCompact
        ? AppConstants.tabletSidebarWidth
        : AppConstants.desktopSidebarWidth;

    return Container(
      width: width,
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_mosaic_rounded,
                    color: Colors.white,
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tolab',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text('University Admin'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected = index == selectedIndex;
                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  tileColor: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  leading: Icon(item.icon),
                  title: isCompact ? null : Text(item.label),
                  onTap: () => context.go(item.route),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemCount: destinations.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.userName,
    required this.userRole,
    required this.onToggleTheme,
    required this.onLogout,
  });

  final String title;
  final String userName;
  final String userRole;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        0,
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              if (!AppBreakpoints.isMobile(context)) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: Scaffold.of(context).openDrawer,
                icon: const Icon(Icons.menu_rounded),
              );
            },
          ),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          IconButton(
            onPressed: onToggleTheme,
            icon: const Icon(Icons.contrast_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
          const StatusBadge('Live'),
          const SizedBox(width: AppSpacing.md),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.14),
                  child: Text(userName.characters.first),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      userRole,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
