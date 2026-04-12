import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/dashboard_theme_tokens.dart';

class DoctorHomeHeader extends StatelessWidget {
  const DoctorHomeHeader({
    super.key,
    required this.user,
    required this.unreadNotifications,
    required this.onRefresh,
    required this.onToggleStyle,
  });

  final DashboardUserSummary user;
  final int unreadNotifications;
  final VoidCallback onRefresh;
  final VoidCallback onToggleStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(DashboardAppSpacing.xl),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(DashboardAppRadii.xl),
        border: Border.all(color: tokens.border),
        boxShadow: DashboardAppShadows.soft(tokens.glow),
        gradient: LinearGradient(
          colors: [tokens.surface, tokens.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: DashboardAppSpacing.sm,
            runSpacing: DashboardAppSpacing.sm,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Chip(
                icon: Icons.auto_awesome_rounded,
                label: tokens.styleName,
                color: tokens.primary,
              ),
              _Chip(
                icon: Icons.notifications_active_rounded,
                label: '$unreadNotifications unread',
                color: tokens.secondary,
              ),
              _Chip(
                icon: Icons.badge_rounded,
                label: user.role,
                color: tokens.warning,
              ),
            ],
          ),
          const SizedBox(height: DashboardAppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: tokens.primary.withValues(alpha: 0.12),
                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                    ? NetworkImage(user.avatar!)
                    : null,
                child: user.avatar == null || user.avatar!.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name.substring(0, 1) : 'U',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: tokens.primary),
                      )
                    : null,
              ),
              const SizedBox(width: DashboardAppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.greeting,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: DashboardAppSpacing.xs),
                    Text(
                      user.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DashboardAppSpacing.md),
              Wrap(
                spacing: DashboardAppSpacing.sm,
                runSpacing: DashboardAppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh'),
                  ),
                  FilledButton.icon(
                    onPressed: onToggleStyle,
                    icon: const Icon(Icons.contrast_rounded),
                    label: const Text('Switch style'),
                  ),
                ],
              ),
            ],
          ),
          if (user.departments.isNotEmpty || user.academicYears.isNotEmpty) ...[
            const SizedBox(height: DashboardAppSpacing.lg),
            Wrap(
              spacing: DashboardAppSpacing.sm,
              runSpacing: DashboardAppSpacing.sm,
              children: [
                for (final department in user.departments)
                  _MetaPill(label: department, color: tokens.primary),
                for (final year in user.academicYears)
                  _MetaPill(label: year, color: tokens.secondary),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardAppSpacing.sm,
        vertical: DashboardAppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DashboardAppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: DashboardAppSpacing.xs),
          Text(label, style: DashboardAppTypography.eyebrow(context, color)),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardAppSpacing.sm,
        vertical: DashboardAppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DashboardAppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
