import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../../../app/localization/app_localizations.dart';

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
      title: context.l10n.byValue('Appearance'),
      subtitle: context.l10n.byValue(
          'Adjust theme, language, contact fallback, and density without leaving the faculty control panel.'),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: languageCode,
            decoration: InputDecoration(labelText: context.l10n.byValue('Language')),
            items: [
              DropdownMenuItem(value: 'en', child: Text(context.l10n.byValue('English'))),
              DropdownMenuItem(value: 'ar', child: Text(context.l10n.byValue('Arabic'))),
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
            decoration: InputDecoration(labelText: context.l10n.byValue('Theme')),
            items: [
              DropdownMenuItem(value: 'system', child: Text(context.l10n.byValue('System'))),
              DropdownMenuItem(value: 'light', child: Text(context.l10n.byValue('Light'))),
              DropdownMenuItem(value: 'dark', child: Text(context.l10n.byValue('Dark'))),
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
            decoration: InputDecoration(labelText: context.l10n.byValue('Contact phone')),
            onChanged: onPhoneChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: compactMode,
            title: Text(context.l10n.byValue('Compact density mode')),
            subtitle: Text(context.l10n.byValue('Increase information density for staff-heavy operational work.')),
            onChanged: onCompactModeChanged,
          ),
        ],
      ),
    );
  }
}
