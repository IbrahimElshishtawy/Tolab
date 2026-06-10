import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import '../../../../../state/app_state.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/state/settings_actions.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsBackupSection extends StatelessWidget {
  const SettingsBackupSection({
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
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        backupRestore: backup.copyWith(frequency: value),
                      ),
                    ),
                  ),
                  SettingsTextInput(
                    value: backup.storageTarget,
                    label: 'Storage target',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        backupRestore: backup.copyWith(storageTarget: value),
                      ),
                    ),
                  ),
                  SettingsNumberInput(
                    value: backup.retentionCount,
                    label: 'Retention count',
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
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
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
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
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
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
                  onPressed: () => StoreProvider.of<AppState>(context, listen: false).dispatch(
                    const CreateSettingsBackupRequestedAction(),
                  ),
                  icon: const Icon(Icons.backup_rounded),
                  label: Text(context.l10n.byValue('Run Backup')),
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
                                    context.l10n.byValue(snapshot.label),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${snapshot.sizeLabel} | ${context.l10n.byValue(snapshot.status)} | ${context.l10n.byValue(snapshot.source)}',
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
                                  ? () => StoreProvider.of<AppState>(context, listen: false).dispatch(
                                      RestoreSettingsBackupRequestedAction(
                                        snapshot.id,
                                      ),
                                    )
                                  : null,
                              child: Text(context.l10n.byValue('Restore')),
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
