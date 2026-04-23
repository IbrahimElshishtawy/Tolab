import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app_admin/core/animations/app_motion.dart';
import '../../../app_admin/core/colors/app_colors.dart';
import '../../../app_admin/core/constants/app_constants.dart';
import '../../../app_admin/core/spacing/app_spacing.dart';
import '../../../app_admin/core/widgets/app_card.dart';
import '../../core/navigation/navigation_items.dart';

class DoctorAssistantDesktopSidebar extends StatelessWidget {
  const DoctorAssistantDesktopSidebar({
    super.key,
    required this.items,
    required this.location,
    required this.isCollapsed,
    required this.notificationRoute,
    required this.unreadNotifications,
    required this.notificationStatus,
    required this.onSelected,
  });

  final List<DoctorAssistantNavigationItem> items;
  final String location;
  final bool isCollapsed;
  final String notificationRoute;
  final int unreadNotifications;
  final String notificationStatus;
  final ValueChanged<DoctorAssistantNavigationItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: isDark ? AppColors.sidebarDark : AppColors.sidebarLight,
      child: Column(
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
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.t('layout.doctor.brand.title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.t('layout.doctor.brand.subtitle'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!isCollapsed) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SidebarStatusBadge(),
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
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = items[index];
                return _DesktopSidebarTile(
                  item: item,
                  isCollapsed: isCollapsed,
                  selected:
                      location == item.path ||
                      location.startsWith('${item.path}/'),
                  badgeCount: item.path == notificationRoute
                      ? unreadNotifications
                      : 0,
                  onTap: () => onSelected(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebarTile extends StatefulWidget {
  const _DesktopSidebarTile({
    required this.item,
    required this.isCollapsed,
    required this.selected,
    required this.badgeCount,
    required this.onTap,
  });

  final DoctorAssistantNavigationItem item;
  final bool isCollapsed;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  State<_DesktopSidebarTile> createState() => _DesktopSidebarTileState();
}

class _DesktopSidebarTileState extends State<_DesktopSidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? AppColors.primary.withValues(alpha: 0.12)
        : _hovered
        ? AppColors.primary.withValues(alpha: 0.06)
        : Colors.transparent;

    return Tooltip(
      message: context.l10n.byValue(widget.item.label),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.emphasized,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            border: Border.all(
              color: widget.selected
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : Colors.transparent,
            ),
          ),
          child: widget.isCollapsed
              ? IconButton(
                  onPressed: widget.onTap,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        widget.item.icon,
                        color: widget.selected ? AppColors.primary : null,
                      ),
                      if (widget.badgeCount > 0)
                        Positioned(
                          top: -3,
                          right: -4,
                          child: const _SidebarCounterDot(),
                        ),
                    ],
                  ),
                )
              : ListTile(
                  onTap: widget.onTap,
                  leading: Icon(
                    widget.item.icon,
                    color: widget.selected ? AppColors.primary : null,
                  ),
                  title: Text(context.l10n.byValue(widget.item.label)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.badgeCount > 0)
                        _SidebarCounterBadge(count: widget.badgeCount),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: widget.selected ? AppColors.primary : null,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SidebarStatusBadge extends StatelessWidget {
  const _SidebarStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Text(
        'Live',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SidebarCounterBadge extends StatelessWidget {
  const _SidebarCounterBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _SidebarCounterDot extends StatelessWidget {
  const _SidebarCounterDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
    );
  }
}
