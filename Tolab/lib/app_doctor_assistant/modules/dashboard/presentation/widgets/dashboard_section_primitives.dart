import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_view_helpers.dart';

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.isHero = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: isHero ? tokens.panelGradient : null,
        color: isHero ? null : tokens.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: tokens.border),
        boxShadow: DashboardAppShadows.soft(tokens.shadow),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DashboardAppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: DashboardAppSpacing.xs),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: tokens.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: DashboardAppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class DashboardToneBadge extends StatelessWidget {
  const DashboardToneBadge({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final color = dashboardToneColor(tokens, tone);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardAppSpacing.sm,
        vertical: DashboardAppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class DashboardSectionEmpty extends StatelessWidget {
  const DashboardSectionEmpty({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DashboardAppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
      ),
    );
  }
}

class DashboardMetricWrap extends StatelessWidget {
  const DashboardMetricWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DashboardAppSpacing.sm,
      runSpacing: DashboardAppSpacing.sm,
      children: children,
    );
  }
}

class DashboardMiniMetricCard extends StatelessWidget {
  const DashboardMiniMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.tone,
    this.caption,
  });

  final String label;
  final String value;
  final String tone;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final color = dashboardToneColor(tokens, tone);
    return Container(
      constraints: const BoxConstraints(minWidth: 122),
      padding: const EdgeInsets.all(DashboardAppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: DashboardAppSpacing.xs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: color),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: DashboardAppSpacing.xs),
            Text(
              caption!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class DashboardInlineAction extends StatelessWidget {
  const DashboardInlineAction({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: tokens.primary,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}
