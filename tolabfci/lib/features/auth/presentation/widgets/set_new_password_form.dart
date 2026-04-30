import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';

class SetNewPasswordForm extends ConsumerStatefulWidget {
  const SetNewPasswordForm({super.key});

  @override
  ConsumerState<SetNewPasswordForm> createState() => _SetNewPasswordFormState();
}

class _SetNewPasswordFormState extends ConsumerState<SetNewPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(authNotifierProvider.notifier)
        .setNewPassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.stage != next.stage &&
          next.stage == AuthStage.authenticated) {
        GoRouter.of(context).goNamed(RouteNames.home);
      }
    });

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('تعيين كلمة مرور جديدة', 'Set a new password'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(
                'بعد هذه الخطوة لن تحتاج لاستخدام الرقم القومي ككلمة مرور افتراضية.',
                'After this step you can stop using the National ID as the default password.',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              controller: _passwordController,
              label: context.tr('كلمة المرور الجديدة', 'New password'),
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: _obscurePassword,
              onChanged: (_) {
                if (authState.errorMessage != null) {
                  ref.read(authNotifierProvider.notifier).clearError();
                }
              },
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.length < 8) {
                  return context.tr(
                    'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
                    'Password must be at least 8 characters',
                  );
                }
                if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
                    !RegExp(r'\d').hasMatch(password)) {
                  return context.tr(
                    'استخدم حروف وأرقام لزيادة الأمان',
                    'Use letters and numbers for better security',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _confirmController,
              label: context.tr('تأكيد كلمة المرور', 'Confirm password'),
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return context.tr(
                    'كلمتا المرور غير متطابقتين',
                    'Passwords do not match',
                  );
                }
                return null;
              },
            ),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _FlowErrorMessage(message: authState.errorMessage!),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: authState.isSubmitting ? null : _submit,
                icon: authState.isSubmitting
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : const Icon(Icons.done_rounded, size: 18),
                label: Text(
                  authState.isSubmitting
                      ? context.tr('جاري الحفظ...', 'Saving...')
                      : context.tr('حفظ ومتابعة', 'Save and continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowErrorMessage extends StatelessWidget {
  const _FlowErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.errorSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: errorColor.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: errorColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: errorColor, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
