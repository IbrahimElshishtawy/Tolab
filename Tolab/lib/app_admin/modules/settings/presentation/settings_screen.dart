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
import '../widgets/settings_primitives.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> _timezones = [
    'Africa/Cairo',
    'UTC',
    'Europe/London',
    'Asia/Riyadh',
    'America/New_York',
  ];

  static const Map<String, String> _languages = {
    'en': 'English',
    'ar': 'Arabic',
    'fr': 'French',
  };

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SettingsViewModel>(
      onInit: (store) {
        if (store.state.settingsState.loadStatus == LoadStatus.initial) {
          store.dispatch(const LoadSettingsAction());
        }
      },
      converter: (store) => _SettingsViewModel(
        settingsState: store.state.settingsState,
        unreadCount: store.state.notificationsState.unreadCount,
        notificationStatus:
            store.state.notificationsState.connectionStatus.label,
      ),
      onDidChange: (_, current) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        final state = current.settingsState;
        if (state.saveStatus == LoadStatus.success &&
            state.successMessage != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.successMessage!)));
        } else if (state.saveStatus == LoadStatus.failure &&
            state.errorMessage != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
                state.saveStatus == LoadStatus.loading
                    ? 'Working...'
                    : 'Create Backup',
              ),
            ),
            OutlinedButton.icon(
              onPressed: state.hasPendingChanges && !isBusy
                  ? () =>
                        _dispatch(context, const RevertSettingsChangesAction())
                  : null,
              icon: const Icon(Icons.undo_rounded),
              label: const Text('Revert'),
            ),
            FilledButton.icon(
              onPressed: state.hasPendingChanges && !isBusy
                  ? () =>
                        _dispatch(context, const SaveSettingsRequestedAction())
                  : null,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Changes'),
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
                bundle.general.appName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: const [
                  Chip(label: Text('Security')),
                  Chip(label: Text('Notifications')),
                  Chip(label: Text('Backup')),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Last updated ${_formatDateTime(bundle.updatedAt)} | Theme ${bundle.themeMode.name} | ${bundle.general.timezone}',
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
    _SettingsViewModel vm,
    double width,
  ) {
    final state = vm.settingsState;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: switch (state.selectedSection) {
        SettingsSection.general => _buildGeneralSection(context, vm, width),
        SettingsSection.theme => _buildThemeSection(context, vm, width),
        SettingsSection.notifications => _buildNotificationsSection(
          context,
          vm,
          width,
        ),
        SettingsSection.security => _buildSecuritySection(context, vm, width),
        SettingsSection.userManagement => _buildUserManagementSection(
          context,
          vm,
          width,
        ),
        SettingsSection.uploadRules => _buildUploadRulesSection(
          context,
          vm,
          width,
        ),
        SettingsSection.calendar => _buildCalendarSection(context, vm, width),
        SettingsSection.system => _buildSystemSection(context, vm, width),
        SettingsSection.backupRestore => _buildBackupSection(
          context,
          vm,
          width,
        ),
      },
    );
  }

  Widget _buildGeneralSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
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
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        general: bundle.general.copyWith(appName: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsTextInput(
                    value: bundle.general.academyName,
                    label: 'Academy name',
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        general: bundle.general.copyWith(academyName: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsTextInput(
                    value: bundle.general.logoUrl,
                    label: 'Logo path or URL',
                    hintText: 'assets/icons/iconapp.png',
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        general: bundle.general.copyWith(logoUrl: value),
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
                    items: _timezones,
                    labelBuilder: (value) => value,
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        general: bundle.general.copyWith(timezone: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsDropdownField<String>(
                    value: bundle.general.languageCode,
                    label: 'Language',
                    items: _languages.keys.toList(growable: false),
                    labelBuilder: (value) => _languages[value] ?? value,
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        general: bundle.general.copyWith(languageCode: value),
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
                      '${bundle.general.timezone} | ${_languages[bundle.general.languageCode]}',
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

  Widget _buildThemeSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
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
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        theme: bundle.theme.copyWith(themeMode: value),
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
                          onChanged: (value) => _updateBundle(
                            context,
                            vm,
                            (bundle) => bundle.copyWith(
                              theme: bundle.theme.copyWith(primaryColor: value),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SettingsColorField(
                          label: 'Secondary color',
                          color: bundle.theme.secondaryColor,
                          onChanged: (value) => _updateBundle(
                            context,
                            vm,
                            (bundle) => bundle.copyWith(
                              theme: bundle.theme.copyWith(
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
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        theme: bundle.theme.copyWith(
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
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        theme: bundle.theme.copyWith(cardBlurSigma: value),
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

  Widget _buildNotificationsSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
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
                    onChanged: (value) => _updateNotifications(
                      context,
                      vm,
                      notifications.copyWith(pushEnabled: value),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Desktop alerts',
                    subtitle:
                        'Show desktop-native notifications on macOS and Windows.',
                    value: notifications.desktopAlertsEnabled,
                    onChanged: (value) => _updateNotifications(
                      context,
                      vm,
                      notifications.copyWith(desktopAlertsEnabled: value),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Local alerts',
                    subtitle:
                        'Use local notification surfaces for realtime events.',
                    value: notifications.localAlertsEnabled,
                    onChanged: (value) => _updateNotifications(
                      context,
                      vm,
                      notifications.copyWith(localAlertsEnabled: value),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Toast queue',
                    subtitle:
                        'Display FIFO in-app popup toasts for new updates.',
                    value: notifications.toastEnabled,
                    onChanged: (value) => _updateNotifications(
                      context,
                      vm,
                      notifications.copyWith(toastEnabled: value),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Email digest',
                    subtitle:
                        'Send a digest for administrators who prefer batched updates.',
                    value: notifications.emailDigestEnabled,
                    onChanged: (value) => _updateNotifications(
                      context,
                      vm,
                      notifications.copyWith(emailDigestEnabled: value),
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
                        _updateNotifications(
                          context,
                          vm,
                          notifications.copyWith(categories: nextCategories),
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

  Widget _buildSecuritySection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
    final security = vm.settingsState.bundle.security;
    final policy = security.passwordPolicy;
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
                    title: 'Password Policy',
                    subtitle:
                        'Enforce production security requirements for admin and staff accounts.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: SettingsNumberInput(
                          value: policy.minLength,
                          label: 'Minimum length',
                          onChanged: (value) => _updateSecurity(
                            context,
                            vm,
                            security.copyWith(
                              passwordPolicy: policy.copyWith(minLength: value),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SettingsNumberInput(
                          value: policy.passwordExpiryDays,
                          label: 'Expiry days',
                          onChanged: (value) => _updateSecurity(
                            context,
                            vm,
                            security.copyWith(
                              passwordPolicy: policy.copyWith(
                                passwordExpiryDays: value,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsNumberInput(
                    value: security.sessionTimeoutMinutes,
                    label: 'Session timeout (minutes)',
                    onChanged: (value) => _updateSecurity(
                      context,
                      vm,
                      security.copyWith(sessionTimeoutMinutes: value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsSwitchTile(
                    title: 'Require uppercase',
                    subtitle:
                        'Passwords must contain at least one uppercase character.',
                    value: policy.requireUppercase,
                    onChanged: (value) => _updateSecurity(
                      context,
                      vm,
                      security.copyWith(
                        passwordPolicy: policy.copyWith(
                          requireUppercase: value,
                        ),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Require special characters',
                    subtitle:
                        'Protect admin credentials from weak password reuse.',
                    value: policy.requireSpecialCharacters,
                    onChanged: (value) => _updateSecurity(
                      context,
                      vm,
                      security.copyWith(
                        passwordPolicy: policy.copyWith(
                          requireSpecialCharacters: value,
                        ),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Force two-factor authentication',
                    subtitle:
                        'Require a second factor for privileged admin roles.',
                    value: security.twoFactorRequired,
                    onChanged: (value) => _updateSecurity(
                      context,
                      vm,
                      security.copyWith(twoFactorRequired: value),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Lock on suspicious activity',
                    subtitle:
                        'Temporarily lock accounts after high-risk sign-in behavior.',
                    value: security.lockOnSuspiciousActivity,
                    onChanged: (value) => _updateSecurity(
                      context,
                      vm,
                      security.copyWith(lockOnSuspiciousActivity: value),
                    ),
                  ),
                ],
              ),
            ),
            SettingsGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsBlockHeader(
                    title: 'Blocked Accounts',
                    subtitle:
                        'Review and unblock accounts that were manually or automatically restricted.',
                    trailing: FilledButton.icon(
                      onPressed: () => _addBlockedAccount(context, vm),
                      icon: const Icon(Icons.person_add_alt_rounded),
                      label: const Text('Block Account'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (security.blockedAccounts.isEmpty)
                    const SettingsEmptyStateCard(
                      title: 'No blocked accounts',
                      subtitle:
                          'Blocked admins and staff members will appear here.',
                    )
                  else
                    Column(
                      children: [
                        for (final account in security.blockedAccounts) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.06),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        account.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _updateSecurity(
                                        context,
                                        vm,
                                        security.copyWith(
                                          blockedAccounts: [
                                            for (final item
                                                in security.blockedAccounts)
                                              if (item.id != account.id) item,
                                          ],
                                        ),
                                      ),
                                      child: const Text('Unblock'),
                                    ),
                                  ],
                                ),
                                Text(account.email),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${account.reason} | ${_formatDateTime(account.blockedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserManagementSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
    final userManagement = vm.settingsState.bundle.userManagement;
    return Column(
      children: [
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Access Defaults',
                subtitle:
                    'Set the default role for new administrators and define how elevated access is approved.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _fieldWrap(
                width: width,
                children: [
                  SettingsDropdownField<String>(
                    value: userManagement.defaultRole,
                    label: 'Default role',
                    items: userManagement.roleTemplates
                        .map((role) => role.name)
                        .toList(growable: false),
                    labelBuilder: (value) => value,
                    onChanged: (value) => _updateUserManagement(
                      context,
                      vm,
                      userManagement.copyWith(defaultRole: value),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Allow staff admin access',
                    subtitle:
                        'Allow staff-facing teams to receive limited admin panel capabilities.',
                    value: userManagement.allowStaffAdminAccess,
                    onChanged: (value) => _updateUserManagement(
                      context,
                      vm,
                      userManagement.copyWith(allowStaffAdminAccess: value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsSwitchTile(
                title: 'Require approval for admin access',
                subtitle:
                    'New admin access changes must be approved by a higher-level role.',
                value: userManagement.requireApprovalForAdminAccess,
                onChanged: (value) => _updateUserManagement(
                  context,
                  vm,
                  userManagement.copyWith(requireApprovalForAdminAccess: value),
                ),
              ),
              SettingsSwitchTile(
                title: 'Allow role cloning',
                subtitle:
                    'Let admins duplicate an existing permission matrix when creating a new role.',
                value: userManagement.allowRoleCloning,
                onChanged: (value) => _updateUserManagement(
                  context,
                  vm,
                  userManagement.copyWith(allowRoleCloning: value),
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
                title: 'Role Permissions',
                subtitle:
                    'Expand each role template to adjust staff access, admin access, and granular permissions.',
              ),
              const SizedBox(height: AppSpacing.lg),
              for (
                var index = 0;
                index < userManagement.roleTemplates.length;
                index++
              )
                _RoleEditorTile(
                  role: userManagement.roleTemplates[index],
                  onRoleChanged: (role) {
                    final nextRoles = [...userManagement.roleTemplates];
                    nextRoles[index] = role;
                    _updateUserManagement(
                      context,
                      vm,
                      userManagement.copyWith(roleTemplates: nextRoles),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadRulesSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
    final uploadRules = vm.settingsState.bundle.uploadRules;
    return SettingsGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsBlockHeader(
            title: 'Upload Controls',
            subtitle:
                'Define file validation, storage target, and upload safeguards for academic assets.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _fieldWrap(
            width: width,
            children: [
              SettingsNumberInput(
                value: uploadRules.maxFileSizeMb,
                label: 'Max file size (MB)',
                onChanged: (value) => _updateBundle(
                  context,
                  vm,
                  (bundle) => bundle.copyWith(
                    uploadRules: uploadRules.copyWith(maxFileSizeMb: value),
                  ),
                ),
              ),
              SettingsDropdownField<StorageLocation>(
                value: uploadRules.storageLocation,
                label: 'Storage location',
                items: StorageLocation.values,
                labelBuilder: (value) => value.label,
                onChanged: (value) => _updateBundle(
                  context,
                  vm,
                  (bundle) => bundle.copyWith(
                    uploadRules: uploadRules.copyWith(storageLocation: value),
                  ),
                ),
              ),
              SettingsTextInput(
                value: uploadRules.basePath,
                label: 'Base path',
                onChanged: (value) => _updateBundle(
                  context,
                  vm,
                  (bundle) => bundle.copyWith(
                    uploadRules: uploadRules.copyWith(basePath: value),
                  ),
                ),
              ),
              SettingsTextInput(
                value: uploadRules.allowedFileTypes.join(', '),
                label: 'Allowed types',
                hintText: 'pdf, docx, png, zip',
                onChanged: (value) => _updateBundle(
                  context,
                  vm,
                  (bundle) => bundle.copyWith(
                    uploadRules: uploadRules.copyWith(
                      allowedFileTypes: value
                          .split(',')
                          .map((item) => item.trim().toLowerCase())
                          .where((item) => item.isNotEmpty)
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsSwitchTile(
            title: 'Validate MIME type',
            subtitle:
                'Verify content signatures instead of trusting only the file extension.',
            value: uploadRules.validateMimeType,
            onChanged: (value) => _updateBundle(
              context,
              vm,
              (bundle) => bundle.copyWith(
                uploadRules: uploadRules.copyWith(validateMimeType: value),
              ),
            ),
          ),
          SettingsSwitchTile(
            title: 'Virus scan uploads',
            subtitle:
                'Run server-side safety checks before files are released.',
            value: uploadRules.runVirusScan,
            onChanged: (value) => _updateBundle(
              context,
              vm,
              (bundle) => bundle.copyWith(
                uploadRules: uploadRules.copyWith(runVirusScan: value),
              ),
            ),
          ),
          SettingsSwitchTile(
            title: 'Rename files on upload',
            subtitle:
                'Normalize stored filenames for safer downstream processing.',
            value: uploadRules.renameOnUpload,
            onChanged: (value) => _updateBundle(
              context,
              vm,
              (bundle) => bundle.copyWith(
                uploadRules: uploadRules.copyWith(renameOnUpload: value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
    final calendar = vm.settingsState.bundle.calendar;
    return Column(
      children: [
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Calendar Defaults',
                subtitle:
                    'Control the preferred calendar view and event color mapping.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _fieldWrap(
                width: width,
                children: [
                  SettingsDropdownField<CalendarViewOption>(
                    value: calendar.defaultView,
                    label: 'Default view',
                    items: CalendarViewOption.values,
                    labelBuilder: (value) => value.label,
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        calendar: calendar.copyWith(defaultView: value),
                      ),
                    ),
                  ),
                  for (final entry in calendar.typeColors.entries)
                    SettingsColorField(
                      label: '${entry.key} color',
                      color: entry.value,
                      onChanged: (value) {
                        final nextColors = Map<String, Color>.from(
                          calendar.typeColors,
                        )..[entry.key] = value;
                        _updateBundle(
                          context,
                          vm,
                          (bundle) => bundle.copyWith(
                            calendar: calendar.copyWith(typeColors: nextColors),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsBlockHeader(
                title: 'Academic Holidays',
                subtitle:
                    'Add holidays and important pauses that should appear in calendar views.',
                trailing: FilledButton.icon(
                  onPressed: () => _addHoliday(context, vm),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Holiday'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (calendar.holidays.isEmpty)
                const SettingsEmptyStateCard(
                  title: 'No holidays configured',
                  subtitle:
                      'Create holidays to highlight non-working academic dates.',
                )
              else
                Column(
                  children: [
                    for (final holiday in calendar.holidays) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    holiday.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    holiday.type,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            SettingsDateChip(
                              date: holiday.date,
                              onTap: () =>
                                  _editHolidayDate(context, vm, holiday),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              onPressed: () =>
                                  _removeHoliday(context, vm, holiday),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
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
                    onChanged: (value) => _updateSystem(
                      context,
                      vm,
                      system.copyWith(apiBaseUrl: value),
                    ),
                  ),
                  SettingsTextInput(
                    value: system.websocketUrl,
                    label: 'WebSocket URL',
                    onChanged: (value) => _updateSystem(
                      context,
                      vm,
                      system.copyWith(websocketUrl: value),
                    ),
                  ),
                  SettingsNumberInput(
                    value: system.logRetentionDays,
                    label: 'Log retention (days)',
                    onChanged: (value) => _updateSystem(
                      context,
                      vm,
                      system.copyWith(logRetentionDays: value),
                    ),
                  ),
                  SettingsTextInput(
                    value: system.integrationStatus,
                    label: 'Integration status',
                    onChanged: (value) => _updateSystem(
                      context,
                      vm,
                      system.copyWith(integrationStatus: value),
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
                onChanged: (value) => _updateSystem(
                  context,
                  vm,
                  system.copyWith(maintenanceMode: value),
                ),
              ),
              SettingsSwitchTile(
                title: 'Audit logging',
                subtitle:
                    'Record sensitive administrative actions for later review.',
                value: system.auditLoggingEnabled,
                onChanged: (value) => _updateSystem(
                  context,
                  vm,
                  system.copyWith(auditLoggingEnabled: value),
                ),
              ),
              SettingsSwitchTile(
                title: 'Laravel broadcasting',
                subtitle:
                    'Use Laravel broadcast events for realtime notifications.',
                value: system.enableLaravelBroadcasting,
                onChanged: (value) => _updateSystem(
                  context,
                  vm,
                  system.copyWith(enableLaravelBroadcasting: value),
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
                          _updateSystem(
                            context,
                            vm,
                            system.copyWith(apiKeys: next),
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

  Widget _buildBackupSection(
    BuildContext context,
    _SettingsViewModel vm,
    double width,
  ) {
    final backup = vm.settingsState.bundle.backupRestore;
    return Column(
      children: [
        SettingsGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsBlockHeader(
                title: 'Backup Schedule',
                subtitle:
                    'Create restore points, set the schedule, and keep encrypted snapshots ready.',
              ),
              const SizedBox(height: AppSpacing.lg),
              _fieldWrap(
                width: width,
                children: [
                  SettingsDropdownField<BackupFrequency>(
                    value: backup.frequency,
                    label: 'Frequency',
                    items: BackupFrequency.values,
                    labelBuilder: (value) => value.label,
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        backupRestore: backup.copyWith(frequency: value),
                      ),
                    ),
                  ),
                  SettingsTextInput(
                    value: backup.storageTarget,
                    label: 'Storage target',
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        backupRestore: backup.copyWith(storageTarget: value),
                      ),
                    ),
                  ),
                  SettingsNumberInput(
                    value: backup.retentionCount,
                    label: 'Retention count',
                    onChanged: (value) => _updateBundle(
                      context,
                      vm,
                      (bundle) => bundle.copyWith(
                        backupRestore: backup.copyWith(retentionCount: value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SettingsSwitchTile(
                title: 'Automatic backups',
                subtitle:
                    'Run scheduled restore points without manual intervention.',
                value: backup.autoBackupEnabled,
                onChanged: (value) => _updateBundle(
                  context,
                  vm,
                  (bundle) => bundle.copyWith(
                    backupRestore: backup.copyWith(
                      autoBackupEnabled: value,
                      clearNextBackupAt: !value,
                      nextBackupAt: value
                          ? DateTime.now().add(
                              Duration(days: backup.frequency.days),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              SettingsSwitchTile(
                title: 'Encrypt backups',
                subtitle:
                    'Store backups encrypted before upload and retention.',
                value: backup.encryptBackups,
                onChanged: (value) => _updateBundle(
                  context,
                  vm,
                  (bundle) => bundle.copyWith(
                    backupRestore: backup.copyWith(encryptBackups: value),
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
              SettingsBlockHeader(
                title: 'Backup History',
                subtitle:
                    'Restore an earlier snapshot or create a new backup on demand.',
                trailing: FilledButton.icon(
                  onPressed: () => _dispatch(
                    context,
                    const CreateSettingsBackupRequestedAction(),
                  ),
                  icon: const Icon(Icons.backup_rounded),
                  label: const Text('Run Backup'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (backup.history.isEmpty)
                const SettingsEmptyStateCard(
                  title: 'No backups yet',
                  subtitle:
                      'Create the first restore point to begin backup history.',
                )
              else
                Column(
                  children: [
                    for (final snapshot in backup.history) ...[
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
                                    snapshot.label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${snapshot.sizeLabel} | ${snapshot.status} | ${snapshot.source}',
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDateTime(snapshot.createdAt),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: snapshot.restorable
                                  ? () => _dispatch(
                                      context,
                                      RestoreSettingsBackupRequestedAction(
                                        snapshot.id,
                                      ),
                                    )
                                  : null,
                              child: const Text('Restore'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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

  void _updateBundle(
    BuildContext context,
    _SettingsViewModel vm,
    SettingsBundle Function(SettingsBundle bundle) update,
  ) {
    _dispatch(
      context,
      UpdateSettingsBundleAction(update(vm.settingsState.bundle)),
    );
  }

  void _updateNotifications(
    BuildContext context,
    _SettingsViewModel vm,
    NotificationPreferences notifications,
  ) {
    _updateBundle(
      context,
      vm,
      (bundle) => bundle.copyWith(notifications: notifications),
    );
  }

  void _updateSecurity(
    BuildContext context,
    _SettingsViewModel vm,
    SecuritySettings security,
  ) {
    _updateBundle(context, vm, (bundle) => bundle.copyWith(security: security));
  }

  void _updateUserManagement(
    BuildContext context,
    _SettingsViewModel vm,
    UserManagementSettings userManagement,
  ) {
    _updateBundle(
      context,
      vm,
      (bundle) => bundle.copyWith(userManagement: userManagement),
    );
  }

  void _updateSystem(
    BuildContext context,
    _SettingsViewModel vm,
    SystemSettings system,
  ) {
    _updateBundle(context, vm, (bundle) => bundle.copyWith(system: system));
  }

  Future<void> _addHoliday(BuildContext context, _SettingsViewModel vm) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
    if (date == null || !context.mounted) return;

    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'Academic');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add holiday'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (saved != true) return;
    final holiday = HolidayItem(
      id: 'holiday-${DateTime.now().microsecondsSinceEpoch}',
      name: nameController.text.trim().isEmpty
          ? 'Holiday'
          : nameController.text.trim(),
      date: date,
      type: typeController.text.trim().isEmpty
          ? 'Academic'
          : typeController.text.trim(),
    );
    _updateBundle(
      context,
      vm,
      (bundle) => bundle.copyWith(
        calendar: bundle.calendar.copyWith(
          holidays: [holiday, ...bundle.calendar.holidays],
        ),
      ),
    );
  }

  Future<void> _editHolidayDate(
    BuildContext context,
    _SettingsViewModel vm,
    HolidayItem holiday,
  ) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialDate: holiday.date,
    );
    if (!context.mounted) return;
    if (date == null) return;
    _updateBundle(
      context,
      vm,
      (bundle) => bundle.copyWith(
        calendar: bundle.calendar.copyWith(
          holidays: [
            for (final item in bundle.calendar.holidays)
              if (item.id == holiday.id) item.copyWith(date: date) else item,
          ],
        ),
      ),
    );
  }

  void _removeHoliday(
    BuildContext context,
    _SettingsViewModel vm,
    HolidayItem holiday,
  ) {
    _updateBundle(
      context,
      vm,
      (bundle) => bundle.copyWith(
        calendar: bundle.calendar.copyWith(
          holidays: [
            for (final item in bundle.calendar.holidays)
              if (item.id != holiday.id) item,
          ],
        ),
      ),
    );
  }

  Future<void> _addBlockedAccount(
    BuildContext context,
    _SettingsViewModel vm,
  ) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final reasonController = TextEditingController();
    var isTemporary = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Block account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  value: isTemporary,
                  onChanged: (value) => setState(() => isTemporary = value),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Temporary block'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Block'),
              ),
            ],
          );
        },
      ),
    );

    if (!context.mounted) return;
    if (saved != true) return;
    final account = BlockedAccount(
      id: 'blocked-${DateTime.now().microsecondsSinceEpoch}',
      name: nameController.text.trim().isEmpty
          ? 'Blocked user'
          : nameController.text.trim(),
      email: emailController.text.trim().isEmpty
          ? 'user@tolab.edu'
          : emailController.text.trim(),
      reason: reasonController.text.trim().isEmpty
          ? 'Manual review'
          : reasonController.text.trim(),
      blockedAt: DateTime.now(),
      isTemporary: isTemporary,
    );
    _updateSecurity(
      context,
      vm,
      vm.settingsState.bundle.security.copyWith(
        blockedAccounts: [
          account,
          ...vm.settingsState.bundle.security.blockedAccounts,
        ],
      ),
    );
  }

  void _dispatch(BuildContext context, dynamic action) {
    StoreProvider.of<AppState>(context, listen: false).dispatch(action);
  }

  String _formatDateTime(DateTime date) =>
      DateFormat('MMM d, yyyy | HH:mm').format(date);
}

class _RoleEditorTile extends StatelessWidget {
  const _RoleEditorTile({required this.role, required this.onRoleChanged});

  final RolePermissionTemplate role;
  final ValueChanged<RolePermissionTemplate> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        title: Text(role.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          '${role.permissions.values.where((value) => value).length} active permissions',
        ),
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: role.adminAccess,
            onChanged: (value) =>
                onRoleChanged(role.copyWith(adminAccess: value)),
            title: const Text('Admin access'),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: role.staffAccess,
            onChanged: (value) =>
                onRoleChanged(role.copyWith(staffAccess: value)),
            title: const Text('Staff access'),
          ),
          for (final entry in role.permissions.entries)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: entry.value,
              onChanged: (value) {
                final nextPermissions = Map<String, bool>.from(role.permissions)
                  ..[entry.key] = value;
                onRoleChanged(role.copyWith(permissions: nextPermissions));
              },
              title: Text(entry.key.replaceAll('_', ' ')),
            ),
        ],
      ),
    );
  }
}

class _SettingsViewModel {
  const _SettingsViewModel({
    required this.settingsState,
    required this.unreadCount,
    required this.notificationStatus,
  });

  final SettingsState settingsState;
  final int unreadCount;
  final String notificationStatus;
}
