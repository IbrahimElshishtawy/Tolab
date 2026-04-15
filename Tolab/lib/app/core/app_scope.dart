import 'package:flutter/widgets.dart';

import '../auth/state/auth_controller.dart';
import '../bootstrap/app_bootstrap.dart';
import '../localization/locale_controller.dart';
import '../shared/theme_mode_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.bootstrap, required super.child});

  final UnifiedAppBootstrap bootstrap;

  static UnifiedAppBootstrap read(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree.');
    return scope!.bootstrap;
  }

  static AuthController auth(BuildContext context) =>
      read(context).authController;

  static ThemeModeController theme(BuildContext context) =>
      read(context).themeController;

  static LocaleController locale(BuildContext context) =>
      read(context).localeController;

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return oldWidget.bootstrap != bootstrap;
  }
}
