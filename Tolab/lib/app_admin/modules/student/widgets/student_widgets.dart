import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class StudentWorkspaceBanner extends StatelessWidget {
  const StudentWorkspaceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.info.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_circle_rounded, color: AppColors.info),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Student pages stay focused: clear timelines, responsive learning panels, and calm motion for fast planning.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
