enum DeviceType { mobile, tablet, desktop }

class AppBreakpoints {
  static const tablet = 600.0;
  static const desktop = 1024.0;

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
