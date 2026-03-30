import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class DoctorWorkspaceBanner extends StatelessWidget {
  const DoctorWorkspaceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.secondary.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_rounded, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Doctor tools are optimized for publishing, grading, and course delivery with file uploads and scrollable performance views.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
