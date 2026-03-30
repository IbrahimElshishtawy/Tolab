import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';

class StudentsBulkActionBar extends StatelessWidget {
  const StudentsBulkActionBar({
    super.key,
    required this.count,
    required this.onClear,
  });

  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$count selected',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
          ),
          const PremiumButton(
            label: 'Send registration',
            icon: Icons.send_rounded,
          ),
          const PremiumButton(
            label: 'Export selection',
            icon: Icons.download_rounded,
            isSecondary: true,
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
