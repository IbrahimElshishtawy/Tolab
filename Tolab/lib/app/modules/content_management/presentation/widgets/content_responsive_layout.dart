import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';

class ContentResponsiveLayout extends StatelessWidget {
  const ContentResponsiveLayout({
    super.key,
    required this.primary,
    required this.secondary,
  });

  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return Column(
        children: [
          primary,
          const SizedBox(height: AppSpacing.lg),
          secondary,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: primary),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(width: 390, child: secondary),
      ],
    );
  }
}
