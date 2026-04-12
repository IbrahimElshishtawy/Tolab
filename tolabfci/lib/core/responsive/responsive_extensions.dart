import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

extension ResponsiveContext on BuildContext {
  DeviceType get deviceType =>
      AppBreakpoints.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  double responsiveValue({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
