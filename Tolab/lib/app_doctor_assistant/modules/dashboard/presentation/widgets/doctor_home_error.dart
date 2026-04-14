import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class DoctorHomeError extends StatelessWidget {
  const DoctorHomeError({
    super.key,
    required this.title,
    required this.message,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.icon = Icons.wifi_tethering_error_rounded,
    this.primaryActionIcon = Icons.refresh_rounded,
    this.accentColor,
  });

  final String title;
  final String message;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final IconData icon;
  final IconData primaryActionIcon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final tone = accentColor ?? tokens.danger;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.all(DashboardAppSpacing.xxl),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(DashboardAppRadii.xl),
          border: Border.all(color: tokens.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: tone.withValues(alpha: 0.12),
              child: Icon(icon, color: tone),
            ),
            const SizedBox(height: DashboardAppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: DashboardAppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: DashboardAppSpacing.lg),
            FilledButton.icon(
              onPressed: onPrimaryAction,
              icon: Icon(primaryActionIcon),
              label: Text(primaryActionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
