import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'student_adaptive_shell.dart';

class StudentSidebar extends StatelessWidget {
  const StudentSidebar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.isStaff,
    required this.onSelect,
  });

  final List<StudentShellDestination> destinations;
  final int currentIndex;
  final bool isStaff;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompactDesktop;
    final palette = context.appColors;

    return Container(
      width: compact ? 236 : 252,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tolab',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isStaff ? 'لوحة أكاديمية متقدمة' : 'طالب • تجربة مرنة',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('التنقل الرئيسي', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final destination in destinations) ...[
                  _SidebarTile(
                    destination: destination,
                    isSelected: currentIndex == destination.index,
                    onTap: () => onSelect(destination.index),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                if (!isStaff) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: palette.border),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'اختصارات',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ShortcutTile(
                    icon: Icons.quiz_outlined,
                    title: 'الكويزات',
                    subtitle: 'الاختبارات والنتائج',
                    routeName: RouteNames.quizzes,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ShortcutTile(
                    icon: Icons.report_problem_outlined,
                    title: 'الدعم والشكاوى',
                    subtitle: 'IT والتذاكر',
                    routeName: RouteNames.complaints,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _ShortcutTile(
                    icon: Icons.settings_outlined,
                    title: 'الإعدادات',
                    subtitle: 'الثيم واللغة',
                    routeName: RouteNames.settings,
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

class _SidebarTile extends StatefulWidget {
  const _SidebarTile({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final StudentShellDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isSelected = widget.isSelected;
    final background = isSelected
        ? palette.primarySoft
        : _hovered
        ? palette.surfaceAlt
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.22)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : palette.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isSelected
                        ? widget.destination.selectedIcon
                        : widget.destination.icon,
                    size: 20,
                    color: isSelected ? AppColors.primary : palette.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.destination.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.destination.badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${widget.destination.badgeCount}',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: AppColors.error),
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

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => GoRouter.of(context).goNamed(routeName),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: context.appColors.surfaceAlt,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
