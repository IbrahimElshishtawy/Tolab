import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../widgets/language_section.dart';
import '../widgets/logout_tile.dart';
import '../widgets/notification_settings_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: ListView(
            children: const [
              LanguageSection(),
              SizedBox(height: AppSpacing.lg),
              NotificationSettingsSection(),
              SizedBox(height: AppSpacing.lg),
              LogoutTile(),
            ],
          ),
        ),
      ),
    );
  }
}
