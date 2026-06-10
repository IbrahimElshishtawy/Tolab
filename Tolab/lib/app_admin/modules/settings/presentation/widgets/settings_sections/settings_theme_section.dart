import 'package:flutter/material.dart';

import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsThemeSection extends StatelessWidget {
  const SettingsThemeSection({
    super.key,
    required this.vm,
    required this.width,
    required this.onUpdateBundle,
  });

  final SettingsViewModel vm;
  final double width;
  final void Function(SettingsBundle Function(SettingsBundle) update) onUpdateBundle;

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
                    title: 'Theme Engine',
                    subtitle:
                        'Preview and control light, dark, and system appearance with live accent colors.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsDropdownField<ThemeMode>(
                    value: bundle.theme.themeMode,
                    label: 'Theme mode',
                    items: ThemeMode.values,
                    labelBuilder: (value) => value.name,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        theme: b.theme.copyWith(themeMode: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: SettingsColorField(
                          label: 'Primary color',
                          color: bundle.theme.primaryColor,
                          onChanged: (value) => onUpdateBundle(
                            (b) => b.copyWith(
                              theme: b.theme.copyWith(primaryColor: value),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SettingsColorField(
                          label: 'Secondary color',
                          color: bundle.theme.secondaryColor,
                          onChanged: (value) => onUpdateBundle(
                            (b) => b.copyWith(
                              theme: b.theme.copyWith(
                                secondaryColor: value,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsSwitchTile(
                    title: 'Glassmorphism surfaces',
                    subtitle:
                        'Use blur and translucent cards for a premium iOS/macOS-inspired shell.',
                    value: bundle.theme.glassmorphismEnabled,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        theme: b.theme.copyWith(
                          glassmorphismEnabled: value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Blur intensity',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: bundle.theme.cardBlurSigma,
                    min: 4,
                    max: 28,
                    divisions: 12,
                    label: bundle.theme.cardBlurSigma.toStringAsFixed(0),
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        theme: b.theme.copyWith(cardBlurSigma: value),
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
                    title: 'Preview Panel',
                    subtitle:
                        'A live preview of the current accent pair and shell styling.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          bundle.theme.primaryColor.withValues(alpha: 0.92),
                          bundle.theme.secondaryColor.withValues(alpha: 0.84),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Desktop shell',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: const [
                            Chip(label: Text('Students')),
                            Chip(label: Text('Notifications')),
                            Chip(label: Text('Settings')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
