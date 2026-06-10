import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/notification_models.dart';
import '../../../state/app_state.dart';
import '../models/settings_models.dart';
import '../state/settings_actions.dart';
import '../state/settings_state.dart';
import '../../../../app/core/app_scope.dart';
import '../../../../app/localization/app_localizations.dart';
import '../widgets/settings_primitives.dart';
import 'widgets/settings_sections/settings_backup_section.dart';
import 'widgets/settings_sections/settings_calendar_section.dart';
import 'widgets/settings_sections/settings_general_section.dart';
import 'widgets/settings_sections/settings_notifications_section.dart';
import 'widgets/settings_sections/settings_security_section.dart';
import 'widgets/settings_sections/settings_theme_section.dart';
import 'widgets/settings_sections/settings_system_section.dart';
import 'widgets/settings_sections/settings_upload_rules_section.dart';
import 'widgets/settings_sections/settings_user_management_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SettingsViewModel>(
      onInit: (store) {
        if (store.state.settingsState.loadStatus == LoadStatus.initial) {
          store.dispatch(const LoadSettingsAction());
        }
      },
      converter: (store) => SettingsViewModel(
        settingsState: store.state.settingsState,
        unreadCount: store.state.notificationsState.unreadCount,
        notificationStatus:
            store.state.notificationsState.connectionStatus.label,
      ),
      onDidChange: (previous, current) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final state = current.settingsState;
        final wasSaving = previous?.settingsState.saveStatus == LoadStatus.loading;
        if (state.saveStatus == LoadStatus.success && wasSaving) {
          final languageCode = state.bundle.general.languageCode;
          AppScope.locale(context).setLanguage(languageCode);
          if (state.successMessage != null) {
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(context.l10n.byValue(state.successMessage!))));
          }
        } else if (state.saveStatus == LoadStatus.failure &&
            state.errorMessage != null &&
            wasSaving) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(context.l10n.byValue(state.errorMessage!))));
        }
      },
      builder: (context, vm) {
        final state = vm.settingsState;
        final bundle = state.bundle;
        final isBusy = state.saveStatus == LoadStatus.loading;

        final header = PageHeader(
          title: 'Settings',
          subtitle:
              'Production-ready academy configuration for branding, security, realtime operations, backend integrations, and backup control.',
          breadcrumbs: const ['Admin', 'Preferences'],
          actions: [
            FilledButton.icon(
              onPressed: isBusy
                  ? null
                  : () => _dispatch(
                      context,
                      const CreateSettingsBackupRequestedAction(),
                    ),
              icon: const Icon(Icons.backup_rounded),
              label: Text(
                context.l10n.byValue(
                  state.saveStatus == LoadStatus.loading
                      ? 'Working...'
                      : 'Create Backup',
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: state.hasPendingChanges && !isBusy
                  ? () =>
                        _dispatch(context, const RevertSettingsChangesAction())
                  : null,
              icon: const Icon(Icons.undo_rounded),
              label: Text(context.l10n.byValue('Revert')),
            ),
            FilledButton.icon(
              onPressed: state.hasPendingChanges && !isBusy
                  ? () =>
                        _dispatch(context, const SaveSettingsRequestedAction())
                  : null,
              icon: const Icon(Icons.save_rounded),
              label: Text(context.l10n.byValue('Save Changes')),
            ),
          ],
        );

        final hero = SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SettingsStatChip(
                    label: 'Workspace',
                    value: bundle.general.academyName,
                    icon: Icons.apartment_rounded,
                  ),
                  SettingsStatChip(
                    label: 'Notifications',
                    value: '${vm.unreadCount} unread',
                    icon: Icons.notifications_active_rounded,
                  ),
                  SettingsStatChip(
                    label: 'Connection',
                    value: vm.notificationStatus,
                    icon: Icons.wifi_tethering_rounded,
                  ),
                  SettingsStatChip(
                    label: 'Sync',
                    value: bundle.isSynced ? 'Synced' : 'Local only',
                    icon: bundle.isSynced
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.byValue(bundle.general.appName),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  Chip(label: Text(context.l10n.byValue('Security'))),
                  Chip(label: Text(context.l10n.byValue('Notifications'))),
                  Chip(label: Text(context.l10n.byValue('Backup'))),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${context.l10n.byValue('Last updated')} ${_formatDateTime(bundle.updatedAt)} | ${context.l10n.byValue('Theme')} ${context.l10n.byValue(bundle.themeMode.name)} | ${bundle.general.timezone}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );

        final body = Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1120;
              final nav = _buildSectionNavigation(
                context,
                selected: state.selectedSection,
                wide: isWide,
              );
              final content = AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: KeyedSubtree(
                  key: ValueKey(state.selectedSection),
                  child: _buildSectionContent(
                    context,
                    vm,
                    constraints.maxWidth - (isWide ? 340 : 0),
                  ),
                ),
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    nav,
                    const SizedBox(height: AppSpacing.md),
                    Expanded(child: content),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320, child: nav),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: content),
                ],
              );
            },
          ),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight < 720) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  header,
                  const SizedBox(height: AppSpacing.lg),
                  hero,
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: constraints.maxHeight * 0.78,
                    child: LayoutBuilder(
                      builder: (context, inner) {
                        final isWide = inner.maxWidth >= 1120;
                        final nav = _buildSectionNavigation(
                          context,
                          selected: state.selectedSection,
                          wide: isWide,
                        );
                        final content = AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: KeyedSubtree(
                            key: ValueKey(state.selectedSection),
                            child: _buildSectionContent(
                              context,
                              vm,
                              inner.maxWidth - (isWide ? 340 : 0),
                            ),
                          ),
                        );

                        if (!isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nav,
                              const SizedBox(height: AppSpacing.md),
                              Expanded(child: content),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 320, child: nav),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: content),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: AppSpacing.lg),
                hero,
                const SizedBox(height: AppSpacing.lg),
                body,
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionNavigation(
    BuildContext context, {
    required SettingsSection selected,
    required bool wide,
  }) {
    if (!wide) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final section in SettingsSection.values) ...[
              ChoiceChip(
                avatar: Icon(section.icon, size: 18),
                label: Text(section.label),
                selected: selected == section,
                onSelected: (_) =>
                    _dispatch(context, SelectSettingsSectionAction(section)),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      );
    }

    return SettingsGlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: ListView.separated(
        itemCount: SettingsSection.values.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, index) {
          final section = SettingsSection.values[index];
          return SettingsSectionButton(
            section: section,
            selected: selected == section,
            onTap: () =>
                _dispatch(context, SelectSettingsSectionAction(section)),
          );
        },
      ),
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    SettingsViewModel vm,
    double width,
  ) {
    final state = vm.settingsState;
    void onUpdate(SettingsBundle Function(SettingsBundle) update) {
      _updateBundle(context, vm, update);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: switch (state.selectedSection) {
        SettingsSection.general => SettingsGeneralSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.theme => SettingsThemeSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.notifications => SettingsNotificationsSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.security => SettingsSecuritySection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.userManagement => SettingsUserManagementSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.uploadRules => SettingsUploadRulesSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.calendar => SettingsCalendarSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.system => SettingsSystemSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
        SettingsSection.backupRestore => SettingsBackupSection(
            vm: vm,
            width: width,
            onUpdateBundle: onUpdate,
          ),
      },
    );
  }

  void _updateBundle(
    BuildContext context,
    SettingsViewModel vm,
    SettingsBundle Function(SettingsBundle bundle) update,
  ) {
    _dispatch(
      context,
      UpdateSettingsBundleAction(update(vm.settingsState.bundle)),
    );
  }

  void _dispatch(BuildContext context, dynamic action) {
    StoreProvider.of<AppState>(context, listen: false).dispatch(action);
  }

  String _formatDateTime(DateTime date) =>
      DateFormat('MMM d, yyyy | HH:mm').format(date);
}

class SettingsViewModel {
  const SettingsViewModel({
    required this.settingsState,
    required this.unreadCount,
    required this.notificationStatus,
  });

  final SettingsState settingsState;
  final int unreadCount;
  final String notificationStatus;
}
