import 'package:flutter/material.dart';

import '../../../app/core/colors/app_colors.dart';
import '../../../app/core/spacing/app_spacing.dart';
import '../../../app/core/widgets/app_card.dart';

class AdminWorkspaceBanner extends StatelessWidget {
  const AdminWorkspaceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Admin workspace keeps management pages vertically scrollable, tables sticky, and realtime delivery visible in one premium shell.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
