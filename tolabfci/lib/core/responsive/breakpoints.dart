enum DeviceType { mobile, tablet, desktop }

class AppBreakpoints {
  static const tablet = 720.0;
  static const desktop = 1100.0;

  static DeviceType fromWidth(double width) {
    if (width >= desktop) {
      return DeviceType.desktop;
    }
    if (width >= tablet) {
      return DeviceType.tablet;
    }
    return DeviceType.mobile;
  }
}
