import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).dividerColor.withValues(alpha: 0.24);
    final highlightColor = Theme.of(context).cardColor;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: List<Widget>.generate(
              4,
              (_) => const _Block(height: 124, width: 280),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _Block(height: 92),
          const SizedBox(height: AppSpacing.lg),
          const _Block(height: 460),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: width,
      padding: EdgeInsets.zero,
      child: SizedBox(height: height),
    );
  }
}
