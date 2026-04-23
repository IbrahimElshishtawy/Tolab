import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';

class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({
    super.key,
    required this.languageCode,
    required this.themeMode,
    required this.compactMode,
    required this.phone,
    required this.onLanguageChanged,
    required this.onThemeModeChanged,
    required this.onCompactModeChanged,
    required this.onPhoneChanged,
  });

  final String languageCode;
  final String themeMode;
  final bool compactMode;
  final String phone;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onThemeModeChanged;
  final ValueChanged<bool> onCompactModeChanged;
  final ValueChanged<String> onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Appearance',
      subtitle:
          'Adjust theme, language, contact fallback, and density without leaving the faculty control panel.',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: languageCode,
            decoration: const InputDecoration(labelText: 'Language'),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ar', child: Text('Arabic')),
            ],
            onChanged: (value) {
              if (value != null) {
                onLanguageChanged(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: themeMode,
            decoration: const InputDecoration(labelText: 'Theme'),
            items: const [
              DropdownMenuItem(value: 'system', child: Text('System')),
              DropdownMenuItem(value: 'light', child: Text('Light')),
              DropdownMenuItem(value: 'dark', child: Text('Dark')),
            ],
            onChanged: (value) {
              if (value != null) {
                onThemeModeChanged(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: phone,
            decoration: const InputDecoration(labelText: 'Contact phone'),
            onChanged: onPhoneChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: compactMode,
            title: const Text('Compact density mode'),
            subtitle: const Text('Increase information density for staff-heavy operational work.'),
            onChanged: onCompactModeChanged,
          ),
        ],
      ),
    );
  }
}
