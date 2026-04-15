import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../localization/app_localizations.dart';
import '../../../../app_admin/core/colors/app_colors.dart';
import '../../../../app_admin/core/constants/app_constants.dart';
import '../../dev/dev_auth_config.dart';
import '../../../routing/app_routes.dart';
import 'dev_quick_login_button.dart';

class UnifiedAuthFormCard extends StatelessWidget {
  const UnifiedAuthFormCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.rememberSession,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.onRememberChanged,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onQuickLoginDev,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberSession;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onToggleObscure;
  final Future<void> Function() onSubmit;
  final Future<void> Function() onQuickLoginDev;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(compact ? 22 : 30),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(compact ? 26 : 32),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : const Color(0xFFDDE5F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.24)
                : const Color(0x140F172A),
            blurRadius: 38,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SurfaceChip(
                  icon: Icons.lock_outline_rounded,
                  label: l10n.t('auth.form.chips.secure_sign_in'),
                ),
                _SurfaceChip(
                  icon: Icons.hub_outlined,
                  label: l10n.t('auth.form.chips.role_resolved'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              l10n.t('auth.form.welcome_back'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: compact ? 28 : 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.t('auth.form.description'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceElevatedDark
                    : const Color(0xFFF6F9FC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.strokeDark
                      : const Color(0xFFE4EBF5),
                ),
              ),
              child: Text(
                l10n.t('auth.form.info'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 22),
            _FieldLabel(
              label: l10n.t('auth.form.email'),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: l10n.t('auth.form.email_hint'),
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return l10n.t('auth.validation.email_required');
                  }
                  if (!email.contains('@')) {
                    return l10n.t('auth.validation.email_invalid');
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel(
              label: l10n.t('auth.form.password'),
              child: TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !isLoading,
                onFieldSubmitted: isLoading ? null : (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: l10n.t('auth.form.password_hint'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: isLoading ? null : onToggleObscure,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return l10n.t('auth.validation.password_required');
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 6,
              children: [
                _RememberSessionRow(
                  value: rememberSession,
                  enabled: !isLoading,
                  onChanged: onRememberChanged,
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go(UnifiedAppRoutes.forgotPassword),
                  child: Text(l10n.t('auth.form.forgot_password')),
                ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              _ErrorBanner(message: errorMessage!),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onSubmit,
                icon: Icon(
                  isLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    isLoading
                        ? l10n.t('auth.form.submitting')
                        : l10n.t('auth.form.submit'),
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                ),
              ),
            ),
            if (kDebugMode && enableDevQuickLogin) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Text(
                l10n.t('auth.form.developer_tools'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('auth.form.developer_description'),
                style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 10),
              DevQuickLoginButton(
                isLoading: isLoading,
                onPressed: onQuickLoginDev,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _RememberSessionRow extends StatelessWidget {
  const _RememberSessionRow({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? (next) => onChanged(next ?? true) : null,
            ),
            const SizedBox(width: 2),
            Text(
              context.l10n.t('auth.form.remember_session'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.byValue(message),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceChip extends StatelessWidget {
  const _SurfaceChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevatedDark.withValues(alpha: 0.92)
            : const Color(0xFFF5F8FC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : const Color(0xFFE3EAF4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
