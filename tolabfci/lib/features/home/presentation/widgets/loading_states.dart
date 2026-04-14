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
        _LoadingCard(height: 132),
        SizedBox(height: AppSpacing.lg),
        _LoadingCard(height: 156),
        SizedBox(height: AppSpacing.lg),
        _LoadingCard(height: 220),
        SizedBox(height: AppSpacing.lg),
        _LoadingGrid(),
      ],
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LoadingCard(height: 240),
        SizedBox(height: AppSpacing.lg),
        _LoadingCard(height: 240),
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
          _ShimmerBlock(width: double.infinity, height: height * 0.18),
          const SizedBox(height: AppSpacing.md),
          _ShimmerBlock(width: double.infinity, height: height * 0.26),
          const SizedBox(height: AppSpacing.sm),
          _ShimmerBlock(width: height * 0.85, height: height * 0.16),
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
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
