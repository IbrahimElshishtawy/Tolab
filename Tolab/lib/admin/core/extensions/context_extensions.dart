import 'package:flutter/material.dart';

import '../responsive/responsive_breakpoints.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;
  double get width => MediaQuery.sizeOf(this).width;
  bool get isMobile => width < ResponsiveBreakpoints.mobile;
  bool get isTablet =>
      width >= ResponsiveBreakpoints.mobile &&
      width < ResponsiveBreakpoints.tablet;
  bool get isDesktop => width >= ResponsiveBreakpoints.tablet;
}
