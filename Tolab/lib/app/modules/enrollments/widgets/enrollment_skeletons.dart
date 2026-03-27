import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class EnrollmentSkeletons extends StatelessWidget {
  const EnrollmentSkeletons({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: List<Widget>.generate(
            4,
            (_) => const SizedBox(width: 280, child: _Block(height: 120)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _Block(height: 86),
        const SizedBox(height: AppSpacing.lg),
        const _Block(height: 420),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Shimmer.fromColors(
        baseColor: AppColors.slateSoft.withValues(alpha: 0.65),
        highlightColor: Colors.white.withValues(alpha: 0.92),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
