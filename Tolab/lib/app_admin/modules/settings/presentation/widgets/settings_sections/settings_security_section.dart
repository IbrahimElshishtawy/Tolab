import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsSecuritySection extends StatelessWidget {
  const SettingsSecuritySection({
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
                          onChanged: (value) => onUpdateBundle(
                            (b) => b.copyWith(
                              security: security.copyWith(
                                passwordPolicy: policy.copyWith(minLength: value),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SettingsNumberInput(
                          value: policy.passwordExpiryDays,
                          label: 'Expiry days',
                          onChanged: (value) => onUpdateBundle(
                            (b) => b.copyWith(
                              security: security.copyWith(
                                passwordPolicy: policy.copyWith(
                                  passwordExpiryDays: value,
                                ),
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
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        security: security.copyWith(sessionTimeoutMinutes: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SettingsSwitchTile(
                    title: 'Require uppercase',
                    subtitle:
                        'Passwords must contain at least one uppercase character.',
                    value: policy.requireUppercase,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        security: security.copyWith(
                          passwordPolicy: policy.copyWith(
                            requireUppercase: value,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Require special characters',
                    subtitle:
                        'Protect admin credentials from weak password reuse.',
                    value: policy.requireSpecialCharacters,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        security: security.copyWith(
                          passwordPolicy: policy.copyWith(
                            requireSpecialCharacters: value,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Force two-factor authentication',
                    subtitle:
                        'Require a second factor for privileged admin roles.',
                    value: security.twoFactorRequired,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        security: security.copyWith(twoFactorRequired: value),
                      ),
                    ),
                  ),
                  SettingsSwitchTile(
                    title: 'Lock on suspicious activity',
                    subtitle:
                        'Temporarily lock accounts after high-risk sign-in behavior.',
                    value: security.lockOnSuspiciousActivity,
                    onChanged: (value) => onUpdateBundle(
                      (b) => b.copyWith(
                        security: security.copyWith(lockOnSuspiciousActivity: value),
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
                  SettingsBlockHeader(
                    title: 'Blocked Accounts',
                    subtitle:
                        'Review and unblock accounts that were manually or automatically restricted.',
                    trailing: FilledButton.icon(
                      onPressed: () => _addBlockedAccount(context),
                      icon: const Icon(Icons.person_add_alt_rounded),
                      label: Text(context.l10n.byValue('Block Account')),
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
                                      onPressed: () => onUpdateBundle(
                                        (b) => b.copyWith(
                                          security: security.copyWith(
                                            blockedAccounts: [
                                              for (final item
                                                  in security.blockedAccounts)
                                                if (item.id != account.id) item,
                                            ],
                                          ),
                                        ),
                                      ),
                                      child: Text(context.l10n.byValue('Unblock')),
                                    ),
                                  ],
                                ),
                                Text(account.email),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${context.l10n.byValue(account.reason)} | ${_formatDateTime(account.blockedAt)}',
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

  Future<void> _addBlockedAccount(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final reasonController = TextEditingController();
    var isTemporary = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(context.l10n.byValue('Block account')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: context.l10n.byValue('Name')),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: context.l10n.byValue('Email')),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(labelText: context.l10n.byValue('Reason')),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  value: isTemporary,
                  onChanged: (value) => setState(() => isTemporary = value),
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.byValue('Temporary block')),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.byValue('Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.l10n.byValue('Block')),
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

    onUpdateBundle(
      (b) => b.copyWith(
        security: b.security.copyWith(
          blockedAccounts: [
            account,
            ...b.security.blockedAccounts,
          ],
        ),
      ),
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
