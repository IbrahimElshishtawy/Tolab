import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin/config/initial_binding.dart';
import 'admin/core/services/app_service.dart';
import 'admin/core/services/theme_service.dart';
import 'admin/core/theme/app_theme.dart';
import 'admin/routes/app_pages.dart';
import 'admin/routes/app_routes.dart';

class TolabApp extends StatelessWidget {
  const TolabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final appService = Get.find<AppService>();

    return Obx(
      () => GetMaterialApp(
        title: 'Tolab Admin',
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeService.themeMode.value,
        locale: appService.locale.value,
        fallbackLocale: const Locale('en'),
        defaultTransition: Transition.noTransition,
      ),
    );
  }
}
