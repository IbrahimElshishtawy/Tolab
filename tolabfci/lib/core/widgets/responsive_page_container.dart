import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../responsive/responsive_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ResponsivePageContainer extends StatelessWidget {
  const ResponsivePageContainer({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.maxWidth,
    this.padding,
    this.includeBackground = true,
  });

  final Widget child;
  final Alignment alignment;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool includeBackground;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final resolvedMaxWidth =
        maxWidth ??
        context.responsiveValue(
          mobile: AppConstants.mobileContentWidth,
          tablet: AppConstants.tabletContentWidth,
          desktop: AppConstants.desktopContentWidth,
        );
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: context.responsiveValue(
            mobile: AppSpacing.md,
            tablet: AppSpacing.lg,
            desktop: AppSpacing.xl,
          ),
          vertical: context.responsiveValue(
            mobile: AppSpacing.md,
            tablet: AppSpacing.lg,
            desktop: AppSpacing.xl,
          ),
        );

    Widget content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
        child: Padding(padding: resolvedPadding, child: child),
      ),
    );

    if (!includeBackground) {
      return content;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.background,
            palette.surfaceAlt.withValues(alpha: 0.78),
            palette.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -40,
            child: IgnorePointer(
              child: _AmbientOrb(
                size: context.responsiveValue(
                  mobile: 180,
                  tablet: 240,
                  desktop: 320,
                ),
                color: AppColors.primary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -30,
            child: IgnorePointer(
              child: _AmbientOrb(
                size: context.responsiveValue(
                  mobile: 160,
                  tablet: 220,
                  desktop: 280,
                ),
                color: AppColors.teal.withValues(alpha: 0.08),
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}
