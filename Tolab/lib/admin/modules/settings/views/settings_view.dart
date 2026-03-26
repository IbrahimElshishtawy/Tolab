import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/theme_service.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final settings = controller.settings.value;
      if (settings == null) return const SizedBox.shrink();
      return SingleChildScrollView(
        child: Card(
          child: Column(
            children: [
              SwitchListTile(
                value: settings.pushNotifications,
                title: const Text('Push Notifications'),
                onChanged: (value) => controller.save(
                  settings.copyWith(pushNotifications: value),
                ),
              ),
              SwitchListTile(
                value: settings.emailNotifications,
                title: const Text('Email Notifications'),
                onChanged: (value) => controller.save(
                  settings.copyWith(emailNotifications: value),
                ),
              ),
              SwitchListTile(
                value: settings.compactSidebar,
                title: const Text('Compact Sidebar'),
                onChanged: (value) =>
                    controller.save(settings.copyWith(compactSidebar: value)),
              ),
              ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Switch light, dark, or system mode.'),
                trailing: DropdownButton<ThemeMode>(
                  value: Get.find<ThemeService>().themeMode.value,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setThemeMode(value);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
