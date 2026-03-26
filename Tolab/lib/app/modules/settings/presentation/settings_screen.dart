import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../state/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SettingsState>(
      converter: (store) => store.state.settingsState,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Settings',
              subtitle:
                  'Tune theme, security, notifications, sessions, and platform preferences from one place.',
              breadcrumbs: const ['Admin', 'Preferences'],
              actions: [
                PremiumButton(
                  label: 'Toggle theme',
                  icon: Icons.contrast_rounded,
                  onPressed: () => StoreProvider.of<AppState>(
                    context,
                  ).dispatch(ToggleThemeModeAction()),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ListView(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Experience',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SwitchListTile.adaptive(
                          value: state.bundle.pushEnabled,
                          onChanged: (_) {},
                          title: const Text(
                            'Push-ready notification architecture',
                          ),
                        ),
                        SwitchListTile.adaptive(
                          value: state.bundle.desktopAlertsEnabled,
                          onChanged: (_) {},
                          title: const Text('Desktop alerts'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Session timeout'),
                          trailing: Text(
                            '${state.bundle.sessionTimeoutMinutes} minutes',
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Upload limit'),
                          trailing: Text('${state.bundle.uploadLimitMb} MB'),
                        ),
                        SwitchListTile.adaptive(
                          value: state.bundle.auditLoggingEnabled,
                          onChanged: (_) {},
                          title: const Text('Audit logging'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
