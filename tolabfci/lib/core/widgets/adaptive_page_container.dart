import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../responsive/responsive_extensions.dart';
import '../theme/app_spacing.dart';

class AdaptivePageContainer extends StatelessWidget {
  const AdaptivePageContainer({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsiveValue(
      mobile: AppConstants.mobileContentWidth,
      tablet: AppConstants.tabletContentWidth,
      desktop: AppConstants.desktopContentWidth,
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: child,
        ),
      ),
    );
  }
}
