import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/config/initial_binding.dart';
import 'app/core/localization/app_translations.dart';
import 'app/core/services/app_service.dart';
import 'app/core/services/theme_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

class TolabApp extends StatelessWidget {
  const TolabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    final themeService = Get.find<ThemeService>();

    return Obx(
      () => GetMaterialApp(
        title: 'Tolab',
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        locale: appService.locale.value,
        fallbackLocale: AppTranslations.fallbackLocale,
        translations: AppTranslations(),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeService.themeMode.value,
        defaultTransition: Transition.noTransition,
      ),
    );
  }
}
