import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';

class SmartHeaderSection extends StatelessWidget {
  const SmartHeaderSection({
    super.key,
    required this.header,
    required this.onRefresh,
    required this.onToggleStyle,
  });

  final DashboardHeader header;
  final VoidCallback onRefresh;
  final VoidCallback onToggleStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DashboardAppSpacing.xl),
      decoration: BoxDecoration(
        gradient: tokens.heroGradient,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: tokens.primary.withValues(alpha: .18),
                child: Text(
                  header.user.name.isEmpty ? '?' : header.user.name[0],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: DashboardAppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      header.user.greeting,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: DashboardAppSpacing.xs),
                    Text(
                      header.user.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              DashboardToneBadge(
                label: '${header.notificationBadge} alerts',
                tone: header.notificationBadge > 0 ? 'danger' : 'success',
              ),
            ],
          ),
          const SizedBox(height: DashboardAppSpacing.lg),
          Wrap(
            spacing: DashboardAppSpacing.sm,
            runSpacing: DashboardAppSpacing.sm,
            children: [
              DashboardToneBadge(label: header.user.role, tone: 'secondary'),
              for (final item in header.user.departments)
                DashboardToneBadge(label: item, tone: 'primary'),
              for (final item in header.user.academicYears)
                DashboardToneBadge(label: item, tone: 'success'),
            ],
          ),
          const SizedBox(height: DashboardAppSpacing.lg),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: DashboardAppSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: onToggleStyle,
                icon: const Icon(Icons.palette_outlined),
                label: Text(tokens.styleName),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
