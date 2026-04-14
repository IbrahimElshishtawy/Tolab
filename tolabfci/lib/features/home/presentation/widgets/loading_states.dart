import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class StudentHomeLoadingState extends StatelessWidget {
  const StudentHomeLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _LoadingCard(height: 150),
        SizedBox(height: AppSpacing.lg),
        _LoadingCard(height: 260),
        SizedBox(height: AppSpacing.lg),
        _LoadingCard(height: 176),
        SizedBox(height: AppSpacing.lg),
        _LoadingCard(height: 260),
        SizedBox(height: AppSpacing.lg),
        _LoadingCard(height: 220),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _ShimmerBlock(width: double.infinity, height: height * 0.16),
          const SizedBox(height: AppSpacing.md),
          _ShimmerBlock(width: double.infinity, height: height * 0.38),
          const SizedBox(height: AppSpacing.sm),
          _ShimmerBlock(width: height * 0.7, height: height * 0.12),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
