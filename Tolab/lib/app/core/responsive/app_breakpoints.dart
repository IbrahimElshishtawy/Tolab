import 'package:flutter/widgets.dart';

enum DeviceScreenType { mobile, tablet, desktop }

class AppBreakpoints {
  const AppBreakpoints._();

  static const double mobileMax = 720;
  static const double tabletMax = 1200;

  static DeviceScreenType resolve(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return DeviceScreenType.mobile;
    if (width < tabletMax) return DeviceScreenType.tablet;
    return DeviceScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      resolve(context) == DeviceScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      resolve(context) == DeviceScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      resolve(context) == DeviceScreenType.desktop;
}
