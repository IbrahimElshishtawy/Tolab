import 'package:flutter/widgets.dart';

import '../../../../core/responsive/app_breakpoints.dart';

enum SubjectsViewMode { table, grouped }

class SubjectsLayout {
  const SubjectsLayout._();

  static bool showDesktopTable(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 980;

  static bool showSidePanel(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1360;

  static int analyticsColumns(BuildContext context) {
    final type = AppBreakpoints.resolve(context);
    return switch (type) {
      DeviceScreenType.mobile => 1,
      DeviceScreenType.tablet => 2,
      DeviceScreenType.desktop => 4,
    };
  }
}
