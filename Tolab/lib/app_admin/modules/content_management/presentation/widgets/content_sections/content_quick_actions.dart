import 'package:flutter/material.dart';

import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/core/widgets/app_card.dart';
import 'package:tolab_fci/app_admin/shared/widgets/premium_button.dart';

class ContentQuickActionsRow extends StatelessWidget {
  const ContentQuickActionsRow({
    super.key,
    required this.onCreate,
    required this.onPublishSelected,
    required this.onArchiveSelected,
    required this.onDeleteSelected,
  });

  final VoidCallback? onCreate;
  final VoidCallback? onPublishSelected;
  final VoidCallback? onArchiveSelected;
  final VoidCallback? onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          PremiumButton(
            label: 'Create lecture',
            icon: Icons.slideshow_rounded,
            onPressed: onCreate,
          ),
          PremiumButton(
            label: 'Publish selected',
            icon: Icons.publish_rounded,
            isSecondary: true,
            onPressed: onPublishSelected,
          ),
          PremiumButton(
            label: 'Archive selected',
            icon: Icons.archive_rounded,
            isSecondary: true,
            onPressed: onArchiveSelected,
          ),
          PremiumButton(
            label: 'Delete selected',
            icon: Icons.delete_outline_rounded,
            isDestructive: true,
            onPressed: onDeleteSelected,
          ),
        ],
      ),
    );
  }
}
