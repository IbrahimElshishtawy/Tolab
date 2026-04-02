import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../app/core/app_scope.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/settings_actions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _languageController;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _languageController = TextEditingController();
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SettingsVm>(
      converter: (store) => _SettingsVm.fromStore(store),
      onWillChange: (previous, current) {
        if (current.user != null) {
          _languageController.text = current.user!.language;
          _notificationsEnabled = current.user!.notificationEnabled;
        }
      },
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Settings',
          activePath: AppRoutes.settings,
          items: buildNavigationItems(user),
          body: ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(user.fullName),
                      subtitle: Text(user.universityEmail),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferences',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _languageController,
                      decoration: const InputDecoration(labelText: 'Language'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _notificationsEnabled,
                      title: const Text('Enable notifications'),
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Save settings',
                      onPressed: () {
                        vm.save({
                          'language': _languageController.text.trim(),
                          'notification_enabled': _notificationsEnabled,
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Logout',
                isSecondary: true,
                onPressed: AppScope.auth(context).logout,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsVm {
  const _SettingsVm({
    required this.user,
    required this.save,
  });

  final SessionUser? user;
  final void Function(Map<String, dynamic>) save;

  factory _SettingsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _SettingsVm(
      user: getCurrentUser(store.state),
      save: (payload) => store.dispatch(UpdateSettingsAction(payload)),
    );
  }
}
