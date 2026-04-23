import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/localization/widgets/language_toggle_button.dart';
import '../../../app_admin/core/animations/app_motion.dart';
import '../../../app_admin/core/colors/app_colors.dart';
import '../../../app_admin/core/constants/app_constants.dart';
import '../../../app_admin/core/responsive/app_breakpoints.dart';
import '../../../app_admin/core/spacing/app_spacing.dart';
import '../../../app_admin/core/widgets/app_card.dart';
import '../../core/navigation/navigation_items.dart';
import 'adaptive_navigation.dart';
import 'desktop_sidebar.dart';
import 'mobile_bottom_nav.dart';

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.location,
    required this.navigation,
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
  final DoctorAssistantNavigationConfig navigation;
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
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  bool _isSidebarCollapsed = false;
  DeviceScreenType? _lastScreenType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenType = AppBreakpoints.resolve(context);
    if (_lastScreenType == screenType) {
      return;
    }

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
    final isMobile = screenType == DeviceScreenType.mobile;
    final titleLabel = widget.navigation.labelForLocation(widget.location);
    final sidebarWidth = _isSidebarCollapsed
        ? AppConstants.collapsedSidebarWidth
        : AppConstants.desktopSidebarWidth;

    return Scaffold(
      drawer: isMobile ? _buildMobileDrawer(context) : null,
      bottomNavigationBar: isMobile
          ? DoctorAssistantMobileBottomNav(
              items: widget.navigation.mobilePrimaryItems,
              selectedIndex: widget.navigation.mobileSelectedIndex(
                widget.location,
              ),
              onSelected: (item) {
                if (item.opensMoreMenu) {
                  _openMoreSheet(context);
                  return;
                }
                context.go(item.path);
              },
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
                        child: DoctorAssistantDesktopSidebar(
                          items: widget.navigation.sidebarItems,
                          location: widget.location,
                          isCollapsed: _isSidebarCollapsed,
                          notificationRoute: widget.notificationRoute,
                          unreadNotifications: widget.unreadNotifications,
                          notificationStatus: widget.notificationStatus,
                          onSelected: (item) => context.go(item.path),
                        ),
                      ),
                    if (!isMobile) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        children: [
                          _ResponsiveTopBar(
                            title: context.l10n.byValue(titleLabel),
                            subtitle: _subtitleFor(titleLabel),
                            userName: widget.userName,
                            userRole: widget.userRole,
                            unreadNotifications: widget.unreadNotifications,
                            notificationRoute: widget.notificationRoute,
                            languageCode: widget.languageCode,
                            notificationStatus: widget.notificationStatus,
                            isMobile: isMobile,
                            onMenuPressed: () {
                              if (isMobile) {
                                Scaffold.maybeOf(context)?.openDrawer();
                              } else {
                                setState(
                                  () => _isSidebarCollapsed =
                                      !_isSidebarCollapsed,
                                );
                              }
                            },
                            onToggleTheme: widget.onToggleTheme,
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
                                child: widget.child,
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

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AdaptiveNavigationMenu(
            title: context.l10n.byValue('المزيد'),
            subtitle:
                'روابط إضافية وإعدادات الحساب بدون تزاحم شريط التنقل السفلي.',
            items: widget.navigation.mobileMoreItems,
            location: widget.location,
            onSelected: (item) {
              Navigator.of(context).pop();
              context.go(item.path);
            },
            footer: AdaptiveNavigationFooter(
              userName: widget.userName,
              userRole: widget.userRole,
              onLogout: widget.onLogout,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMoreSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: AdaptiveNavigationMenu(
              title: context.l10n.byValue('المزيد'),
              subtitle:
                  'التنقلات الثانوية تبقى هنا حتى يظل الشريط السفلي سريعًا وواضحًا.',
              items: widget.navigation.mobileMoreItems,
              location: widget.location,
              onSelected: (item) {
                Navigator.of(context).pop();
                context.go(item.path);
              },
            ),
          ),
        );
      },
    );
  }

  String _subtitleFor(String label) {
    switch (label) {
      case 'layout.doctor.nav.home':
        return 'Teaching overview, urgent actions, and course health in one place.';
      case 'layout.doctor.nav.subjects':
        return 'Course planning, sections, and materials for every subject you teach.';
      case 'layout.doctor.nav.schedule':
        return 'Weekly planning, calendar review, and conflict follow-up.';
      case 'الطلاب':
      case 'Students':
        return 'Student roster, engagement signals, and academic follow-up.';
      case 'المزيد':
        return 'Secondary tools, alerts, and settings.';
      default:
        return 'Academic workspace designed for focused teaching operations.';
    }
  }
}

class _ResponsiveTopBar extends StatelessWidget {
  const _ResponsiveTopBar({
    required this.title,
    required this.subtitle,
    required this.userName,
    required this.userRole,
    required this.unreadNotifications,
    required this.notificationRoute,
    required this.notificationStatus,
    required this.languageCode,
    required this.isMobile,
    required this.onMenuPressed,
    required this.onToggleTheme,
    required this.onLanguageSelected,
    required this.onLogout,
  });

  final String title;
  final String subtitle;
  final String userName;
  final String userRole;
  final int unreadNotifications;
  final String notificationRoute;
  final String notificationStatus;
  final String languageCode;
  final bool isMobile;
  final VoidCallback onMenuPressed;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onLanguageSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < (isMobile ? 460 : 780);

    final profileChip = PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          onLogout();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'logout',
          child: Text(context.l10n.t('common.actions.logout')),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
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
            if (!compact) ...[
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
      ),
    );

    final actionStrip = Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.end,
      children: [
        if (!compact && !isMobile)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              border: Border.all(color: Theme.of(context).dividerColor),
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
        LanguageToggleButton(
          languageCode: languageCode,
          onSelected: onLanguageSelected,
        ),
        IconButton(
          onPressed: onToggleTheme,
          tooltip: context.l10n.t('common.actions.toggle_theme'),
          icon: const Icon(Icons.contrast_rounded),
        ),
        _NotificationButton(
          count: unreadNotifications,
          onPressed: () => context.go(notificationRoute),
        ),
        profileChip,
      ],
    );

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onMenuPressed,
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(alignment: Alignment.centerRight, child: actionStrip),
              ],
            )
          : Row(
              children: [
                IconButton(
                  onPressed: onMenuPressed,
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
                actionStrip,
              ],
            ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onPressed});

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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
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
