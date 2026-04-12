import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';

class DoctorHomeLoading extends StatelessWidget {
  const DoctorHomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Shimmer.fromColors(
      baseColor: tokens.surfaceAlt,
      highlightColor: tokens.surface,
      child: Column(
        children: [
          _block(height: 168, tokens: tokens),
          const SizedBox(height: DashboardAppSpacing.lg),
          Row(
            children: [
              Expanded(child: _block(height: 110, tokens: tokens)),
              const SizedBox(width: DashboardAppSpacing.md),
              Expanded(child: _block(height: 110, tokens: tokens)),
            ],
          ),
          const SizedBox(height: DashboardAppSpacing.lg),
          _block(height: 250, tokens: tokens),
          const SizedBox(height: DashboardAppSpacing.lg),
          _block(height: 220, tokens: tokens),
        ],
      ),
    );
  }

  Widget _block({
    required double height,
    required DashboardThemeTokens tokens,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(DashboardAppRadii.xl),
      ),
    );
  }
}
