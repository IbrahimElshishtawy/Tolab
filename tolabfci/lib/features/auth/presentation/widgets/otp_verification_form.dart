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

class OtpVerificationForm extends ConsumerStatefulWidget {
  const OtpVerificationForm({super.key});

  @override
  ConsumerState<OtpVerificationForm> createState() =>
      _OtpVerificationFormState();
}

class _OtpVerificationFormState extends ConsumerState<OtpVerificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(authNotifierProvider.notifier)
        .verifyOtp(_codeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.stage != next.stage &&
          next.stage == AuthStage.awaitingNewPassword) {
        GoRouter.of(context).goNamed(RouteNames.setNewPassword);
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
              context.tr('كود التحقق', 'Verification code'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(
                'أدخل كود التحقق المرسل إلى بريدك الجامعي. كود التجربة هو 123456.',
                'Enter the code sent to your university email. The mock code is 123456.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              controller: _codeController,
              label: context.tr('الكود', 'Code'),
              hintText: '123456',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.password_rounded,
              onChanged: (_) {
                if (authState.errorMessage != null) {
                  ref.read(authNotifierProvider.notifier).clearError();
                }
              },
              validator: (value) {
                final normalized = (value ?? '').trim().replaceAll(
                  RegExp(r'\s+'),
                  '',
                );
                if (!RegExp(r'^\d{6}$').hasMatch(normalized)) {
                  return context.tr(
                    'الكود يجب أن يكون 6 أرقام',
                    'Code must be 6 digits',
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
                    : const Icon(Icons.verified_rounded, size: 18),
                label: Text(
                  authState.isSubmitting
                      ? context.tr('جاري التحقق...', 'Verifying...')
                      : context.tr('تأكيد الكود', 'Verify code'),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: errorColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
