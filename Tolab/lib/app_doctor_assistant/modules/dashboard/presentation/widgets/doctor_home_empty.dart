import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class DoctorHomeEmpty extends StatelessWidget {
  const DoctorHomeEmpty({
    super.key,
    required this.title,
    required this.message,
    required this.onRefresh,
  });

  final String title;
  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
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
              backgroundColor: tokens.primary.withValues(alpha: 0.12),
              child: Icon(
                Icons.dashboard_customize_rounded,
                color: tokens.primary,
              ),
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
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
