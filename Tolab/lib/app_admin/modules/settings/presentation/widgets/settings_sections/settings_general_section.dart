import 'package:flutter/material.dart';

import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsGeneralSection extends StatelessWidget {
  const SettingsGeneralSection({
    super.key,
    required this.vm,
    required this.width,
    required this.onUpdateBundle,
  });

  final SettingsViewModel vm;
  final double width;
  final void Function(SettingsBundle Function(SettingsBundle) update) onUpdateBundle;

  static const List<String> timezones = [
    'Africa/Cairo',
    'UTC',
    'Europe/London',
    'Asia/Riyadh',
    'America/New_York',
  ];

  static const Map<String, String> languages = {
    'en': 'English',
    'ar': 'Arabic',
    'fr': 'French',
  };

  @override
  Widget build(BuildContext context) {
    final bundle = vm.settingsState.bundle;
    return Column(
      children: [
        _fieldWrap(
          width: width,
          children: [
            SettingsGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsBlockHeader(
                    title: 'Branding',
                    subtitle:
                        'Control the academy identity used across mobile and desktop admin surfaces.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsTextInput(
                    value: bundle.general.appName,
                    label: 'App name',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        general: b.general.copyWith(appName: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsTextInput(
                    value: bundle.general.academyName,
                    label: 'Academy name',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        general: b.general.copyWith(academyName: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsTextInput(
                    value: bundle.general.logoUrl,
                    label: 'Logo path or URL',
                    hintText: 'assets/icons/iconapp.png',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        general: b.general.copyWith(logoUrl: value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SettingsGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsBlockHeader(
                    title: 'Localization',
                    subtitle:
                        'Set the timezone and language used for schedules, notifications, and system timestamps.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsDropdownField<String>(
                    value: bundle.general.timezone,
                    label: 'Timezone',
                    items: timezones,
                    labelBuilder: (value) => value,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        general: b.general.copyWith(timezone: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsDropdownField<String>(
                    value: bundle.general.languageCode,
                    label: 'Language',
                    items: languages.keys.toList(growable: false),
                    labelBuilder: (value) => languages[value] ?? value,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        general: b.general.copyWith(languageCode: value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Live Preview',
                subtitle:
                    'Preview how the current academy identity will appear in the admin panel shell.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bundle.theme.primaryColor,
                      bundle.theme.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.general.appName,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      bundle.general.academyName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${bundle.general.timezone} | ${languages[bundle.general.languageCode]}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldWrap({required double width, required List<Widget> children}) {
    final tileWidth = width >= 920 ? (width - AppSpacing.md) / 2 : width;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final child in children)
          SizedBox(width: tileWidth.clamp(280, 640).toDouble(), child: child),
      ],
    );
  }
}
