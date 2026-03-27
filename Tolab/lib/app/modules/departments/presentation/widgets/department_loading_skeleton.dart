import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class DepartmentLoadingSkeleton extends StatelessWidget {
  const DepartmentLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).dividerColor.withValues(alpha: 0.45),
      highlightColor: AppColors.surfaceElevatedLight.withValues(alpha: 0.65),
      child: Column(
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: List.generate(
              4,
              (index) => const SizedBox(
                width: 250,
                child: AppCard(child: SizedBox(height: 108)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppCard(child: SizedBox(height: 420)),
        ],
      ),
    );
  }
}
