import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import 'settings_notifier.dart';

class NotificationSettingsSection extends ConsumerWidget {
  const NotificationSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);

    return AppCard(
      child: SwitchListTile.adaptive(
        value: state.notificationsEnabled,
        onChanged: (value) =>
            ref.read(settingsNotifierProvider.notifier).updateNotifications(value),
        title: const Text('Notifications'),
        subtitle: const Text('Enable alerts, quiz reminders, and summary updates'),
      ),
    );
  }
}
