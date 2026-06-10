import 'package:flutter/material.dart';

import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';
import 'package:tolab_fci/app_admin/shared/models/notification_models.dart';

class SettingsNotificationsSection extends StatelessWidget {
  const SettingsNotificationsSection({
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
    final notifications = vm.settingsState.bundle.notifications;
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
                    title: 'Delivery Controls',
                    subtitle:
                        'Configure push, local, desktop, sound, email digest, and toast behavior.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsSwitchTile(
                    title: 'Push notifications',
                    subtitle:
                        'Use Firebase or backend push tokens when available.',
                    value: notifications.pushEnabled,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        notifications: notifications.copyWith(pushEnabled: value),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Desktop alerts',
                    subtitle:
                        'Show desktop-native notifications on macOS and Windows.',
                    value: notifications.desktopAlertsEnabled,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        notifications: notifications.copyWith(desktopAlertsEnabled: value),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Local alerts',
                    subtitle:
                        'Use local notification surfaces for realtime events.',
                    value: notifications.localAlertsEnabled,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        notifications: notifications.copyWith(localAlertsEnabled: value),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Toast queue',
                    subtitle:
                        'Display FIFO in-app popup toasts for new updates.',
                    value: notifications.toastEnabled,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        notifications: notifications.copyWith(toastEnabled: value),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Email digest',
                    subtitle:
                        'Send a digest for administrators who prefer batched updates.',
                    value: notifications.emailDigestEnabled,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        notifications: notifications.copyWith(emailDigestEnabled: value),
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
                    title: 'Categories',
                    subtitle:
                        'Enable or mute operational categories independently.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final category in AdminNotificationCategory.values)
                    SettingsSwitchTile(
                      title: category.label,
                      subtitle:
                          'Allow ${category.label.toLowerCase()} events to reach the notification center.',
                      value: notifications.categories[category] ?? true,
                      onChanged: (value) {
                        final nextCategories =
                            Map<AdminNotificationCategory, bool>.from(
                              notifications.categories,
                            )..[category] = value;
                        onUpdateBundle(
                          (b) => b.copyWith(
                            notifications: notifications.copyWith(categories: nextCategories),
                          ),
                        );
                      },
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
