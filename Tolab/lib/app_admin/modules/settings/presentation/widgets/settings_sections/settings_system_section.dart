import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsSystemSection extends StatelessWidget {
  const SettingsSystemSection({
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
    final system = vm.settingsState.bundle.system;
    return Column(
      children: [
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Backend Integration',
                subtitle:
                    'Connect the admin panel to Laravel APIs, websocket delivery, logs, and maintenance controls.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _fieldWrap(
                width: width,
                children: [
                  SettingsTextInput(
                    value: system.apiBaseUrl,
                    label: 'API base URL',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        system: system.copyWith(apiBaseUrl: value),
                      ),
                    ),
                  ),
                  SettingsTextInput(
                    value: system.websocketUrl,
                    label: 'WebSocket URL',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        system: system.copyWith(websocketUrl: value),
                      ),
                    ),
                  ),
                  SettingsNumberInput(
                    value: system.logRetentionDays,
                    label: 'Log retention (days)',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        system: system.copyWith(logRetentionDays: value),
                      ),
                    ),
                  ),
                  SettingsTextInput(
                    value: system.integrationStatus,
                    label: 'Integration status',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        system: system.copyWith(integrationStatus: value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsSwitchTile(
                title: 'Maintenance mode',
                subtitle:
                  'Pause admin operations while backend maintenance is active.',
                value: system.maintenanceMode,
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    system: system.copyWith(maintenanceMode: value),
                  ),
                ),
              ),
              SettingsSwitchTile(
                title: 'Audit logging',
                subtitle:
                  'Record sensitive administrative actions for later review.',
                value: system.auditLoggingEnabled,
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    system: system.copyWith(auditLoggingEnabled: value),
                  ),
                ),
              ),
              SettingsSwitchTile(
                title: 'Laravel broadcasting',
                subtitle:
                  'Use Laravel broadcast events for realtime notifications.',
                value: system.enableLaravelBroadcasting,
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    system: system.copyWith(enableLaravelBroadcasting: value),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'API Credentials',
                subtitle:
                  'Review configured integrations and toggle individual credentials.',
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var index = 0; index < system.apiKeys.length; index++) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              system.apiKeys[index].label,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(system.apiKeys[index].valueMasked),
                            const SizedBox(height: 2),
                            Text(
                              '${system.apiKeys[index].scope} | rotated ${_formatDateTime(system.apiKeys[index].lastRotatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: system.apiKeys[index].isEnabled,
                        onChanged: (value) {
                          final next = [...system.apiKeys];
                          next[index] = system.apiKeys[index].copyWith(
                            isEnabled: value,
                          );
                          onUpdateBundle(
                            (b) => b.copyWith(
                              system: system.copyWith(apiKeys: next),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) =>
      DateFormat('MMM d, yyyy | HH:mm').format(date);

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
