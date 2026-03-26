import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? _pushEnabled;
  bool? _desktopAlertsEnabled;
  bool? _auditLoggingEnabled;
  bool _autoApprove = true;
  bool _compactTables = true;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SettingsState>(
      converter: (store) => store.state.settingsState,
      builder: (context, state) {
        _pushEnabled ??= state.bundle.pushEnabled;
        _desktopAlertsEnabled ??= state.bundle.desktopAlertsEnabled;
        _auditLoggingEnabled ??= state.bundle.auditLoggingEnabled;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Settings',
              subtitle:
                  'Tune the workspace, security posture, and communication defaults with grouped premium settings surfaces.',
              breadcrumbs: const ['Admin', 'Preferences', 'Workspace'],
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
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                _CategoryChip(label: 'Security'),
                _CategoryChip(label: 'Experience'),
                _CategoryChip(label: 'Workspace'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showSidePreview = constraints.maxWidth > 1180;

                  return showSidePreview
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: ListView(
                                children: [
                                  _SettingsSection(
                                    title: 'Experience',
                                    subtitle:
                                        'Theme, layout density, and interaction preferences.',
                                    children: [
                                      _SettingsToggleTile(
                                        title: 'Push notifications ready',
                                        subtitle:
                                            'Enable the notification pipeline across the admin workspace.',
                                        value: _pushEnabled!,
                                        onChanged: (value) => setState(
                                          () => _pushEnabled = value,
                                        ),
                                      ),
                                      _SettingsToggleTile(
                                        title: 'Desktop alerts',
                                        subtitle:
                                            'Show real-time moderation and schedule alerts on desktop.',
                                        value: _desktopAlertsEnabled!,
                                        onChanged: (value) => setState(
                                          () => _desktopAlertsEnabled = value,
                                        ),
                                      ),
                                      _SettingsToggleTile(
                                        title: 'Compact tables',
                                        subtitle:
                                            'Prefer denser rows for large administrative datasets.',
                                        value: _compactTables,
                                        onChanged: (value) => setState(
                                          () => _compactTables = value,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _SettingsSection(
                                    title: 'Security Controls',
                                    subtitle:
                                        'Session controls, audit visibility, and workspace protection.',
                                    children: [
                                      _StaticRow(
                                        label: 'Session timeout',
                                        value:
                                            '${state.bundle.sessionTimeoutMinutes} minutes',
                                      ),
                                      _StaticRow(
                                        label: 'Upload limit',
                                        value:
                                            '${state.bundle.uploadLimitMb} MB',
                                      ),
                                      _SettingsToggleTile(
                                        title: 'Audit logging',
                                        subtitle:
                                            'Retain administrative actions for compliance and incident review.',
                                        value: _auditLoggingEnabled!,
                                        onChanged: (value) => setState(
                                          () => _auditLoggingEnabled = value,
                                        ),
                                      ),
                                      _SettingsToggleTile(
                                        title: 'Auto-approve trusted uploads',
                                        subtitle:
                                            'Skip manual review for verified internal staff uploads.',
                                        value: _autoApprove,
                                        onChanged: (value) => setState(
                                          () => _autoApprove = value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 4,
                              child: _WorkspacePreviewCard(
                                themeMode: state.bundle.themeMode,
                                localeCode: state.bundle.localeCode,
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            _SettingsSection(
                              title: 'Experience',
                              subtitle:
                                  'Theme, layout density, and interaction preferences.',
                              children: [
                                _SettingsToggleTile(
                                  title: 'Push notifications ready',
                                  subtitle:
                                      'Enable the notification pipeline across the admin workspace.',
                                  value: _pushEnabled!,
                                  onChanged: (value) =>
                                      setState(() => _pushEnabled = value),
                                ),
                                _SettingsToggleTile(
                                  title: 'Desktop alerts',
                                  subtitle:
                                      'Show real-time moderation and schedule alerts on desktop.',
                                  value: _desktopAlertsEnabled!,
                                  onChanged: (value) => setState(
                                    () => _desktopAlertsEnabled = value,
                                  ),
                                ),
                                _SettingsToggleTile(
                                  title: 'Compact tables',
                                  subtitle:
                                      'Prefer denser rows for large administrative datasets.',
                                  value: _compactTables,
                                  onChanged: (value) =>
                                      setState(() => _compactTables = value),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _SettingsSection(
                              title: 'Security Controls',
                              subtitle:
                                  'Session controls, audit visibility, and workspace protection.',
                              children: [
                                _StaticRow(
                                  label: 'Session timeout',
                                  value:
                                      '${state.bundle.sessionTimeoutMinutes} minutes',
                                ),
                                _StaticRow(
                                  label: 'Upload limit',
                                  value: '${state.bundle.uploadLimitMb} MB',
                                ),
                                _SettingsToggleTile(
                                  title: 'Audit logging',
                                  subtitle:
                                      'Retain administrative actions for compliance and incident review.',
                                  value: _auditLoggingEnabled!,
                                  onChanged: (value) => setState(
                                    () => _auditLoggingEnabled = value,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _WorkspacePreviewCard(
                              themeMode: state.bundle.themeMode,
                              localeCode: state.bundle.localeCode,
                            ),
                          ],
                        );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StaticRow extends StatelessWidget {
  const _StaticRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _WorkspacePreviewCard extends StatelessWidget {
  const _WorkspacePreviewCard({
    required this.themeMode,
    required this.localeCode,
  });

  final ThemeMode themeMode;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Workspace profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const StatusBadge('Healthy', icon: Icons.verified_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.info],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tolab Admin',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Theme: ${themeMode.name}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Locale: $localeCode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _StaticRow(label: 'Active admins', value: '12'),
          const _StaticRow(label: 'Connected services', value: '8'),
          const _StaticRow(label: 'Storage profile', value: 'Balanced'),
          const SizedBox(height: AppSpacing.md),
          const PremiumButton(
            label: 'Save preferences',
            icon: Icons.save_outlined,
          ),
        ],
      ),
    );
  }
}
