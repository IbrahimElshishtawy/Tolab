import 'package:flutter/widgets.dart';

import 'responsive_breakpoints.dart';

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        if (width >= ResponsiveBreakpoints.tablet) {
          return desktop ?? tablet ?? mobile;
        }
        if (width >= ResponsiveBreakpoints.mobile) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
