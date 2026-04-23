import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app_admin/core/constants/app_constants.dart';
import '../../../app_admin/core/spacing/app_spacing.dart';
import '../../../app_admin/core/widgets/app_card.dart';
import '../../core/navigation/navigation_items.dart';

class AdaptiveNavigationMenu extends StatelessWidget {
  const AdaptiveNavigationMenu({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.location,
    required this.onSelected,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<DoctorAssistantNavigationItem> items;
  final String location;
  final ValueChanged<DoctorAssistantNavigationItem> onSelected;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final item = items[index];
              final selected =
                  location == item.path || location.startsWith('${item.path}/');
              return _AdaptiveNavigationTile(
                item: item,
                selected: selected,
                onTap: () => onSelected(item),
              );
            },
          ),
        ),
        if (footer != null) ...[const SizedBox(height: AppSpacing.md), footer!],
      ],
    );
  }
}

class AdaptiveNavigationFooter extends StatelessWidget {
  const AdaptiveNavigationFooter({
    super.key,
    required this.userName,
    required this.userRole,
    required this.onLogout,
  });

  final String userName;
  final String userRole;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.byValue(userRole.replaceAll('_', ' ')),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.l10n.t('common.actions.logout')),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveNavigationTile extends StatelessWidget {
  const _AdaptiveNavigationTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DoctorAssistantNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colorScheme.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(item.icon, color: selected ? colorScheme.primary : null),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.l10n.byValue(item.label),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: selected ? colorScheme.primary : null,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
