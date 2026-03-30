import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';

class DepartmentBulkActionBar extends StatelessWidget {
  const DepartmentBulkActionBar({
    super.key,
    required this.count,
    required this.onActivate,
    required this.onDeactivate,
    required this.onArchive,
    required this.onClear,
  });

  final int count;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onArchive;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$count selected',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          PremiumButton(
            label: 'Activate',
            icon: Icons.check_circle_outline_rounded,
            isSecondary: true,
            onPressed: onActivate,
          ),
          PremiumButton(
            label: 'Deactivate',
            icon: Icons.pause_circle_outline_rounded,
            isSecondary: true,
            onPressed: onDeactivate,
          ),
          PremiumButton(
            label: 'Archive',
            icon: Icons.archive_outlined,
            isSecondary: true,
            onPressed: onArchive,
          ),
          PremiumButton(
            label: 'Clear',
            icon: Icons.close_rounded,
            isSecondary: true,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
