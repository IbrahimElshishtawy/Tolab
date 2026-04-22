import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/settings_actions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _compactMode = true;
  String _language = 'English';
  int? _hydratedUserId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SettingsVm>(
      converter: (store) => _SettingsVm.fromStore(store),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();
        if (_hydratedUserId != user.id) {
          _hydratedUserId = user.id;
          _notificationsEnabled = user.notificationEnabled;
          _language = user.language.toLowerCase() == 'ar' ? 'Arabic' : 'English';
        }

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.settings,
          unreadNotifications: DoctorAssistantMockRepository.instance
              .unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Settings',
            subtitle:
                'Section cards, toggles, and action buttons stay aligned with the admin control surface.',
            breadcrumbs: const ['Workspace', 'Settings'],
            child: Column(
              children: [
                DoctorAssistantPanel(
                  title: 'Preferences',
                  subtitle:
                      'Tune local behavior without leaving the shared design system.',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _language,
                        decoration: const InputDecoration(
                          labelText: 'Language',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'English',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'Arabic',
                            child: Text('Arabic'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _language = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _notificationsEnabled,
                        title: const Text('Enable notifications'),
                        subtitle: const Text(
                          'Keep live reminders and delivery updates visible in the workspace.',
                        ),
                        onChanged: (value) =>
                            setState(() => _notificationsEnabled = value),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _compactMode,
                        title: const Text('Compact layout density'),
                        subtitle: const Text(
                          'Match the tighter admin spacing and information density.',
                        ),
                        onChanged: (value) =>
                            setState(() => _compactMode = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DoctorAssistantPanel(
                  title: 'Actions',
                  subtitle:
                      'Primary and secondary actions reuse the admin button treatment.',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      PremiumButton(
                        label: 'Save settings',
                        icon: Icons.check_rounded,
                        onPressed: vm.isSaving
                            ? null
                            : () {
                                vm.save(<String, dynamic>{
                                  'language':
                                      _language == 'Arabic' ? 'ar' : 'en',
                                  'notification_enabled':
                                      _notificationsEnabled,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Settings saved to the local mock session.',
                                    ),
                                  ),
                                );
                              },
                      ),
                      PremiumButton(
                        label: 'Reset',
                        icon: Icons.refresh_rounded,
                        isSecondary: true,
                        onPressed: vm.isSaving
                            ? null
                            : () {
                                setState(() {
                                  _notificationsEnabled = true;
                                  _compactMode = true;
                                  _language = 'English';
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsVm {
  const _SettingsVm({
    required this.user,
    required this.isSaving,
    required this.save,
  });

  final SessionUser? user;
  final bool isSaving;
  final void Function(Map<String, dynamic> payload) save;

  factory _SettingsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _SettingsVm(
      user: getCurrentUser(store.state),
      isSaving: store.state.settingsState.status.name == 'loading',
      save: (payload) => store.dispatch(UpdateSettingsAction(payload)),
    );
  }
}
