import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

class VerifyNationalIdForm extends ConsumerStatefulWidget {
  const VerifyNationalIdForm({super.key});

  @override
  ConsumerState<VerifyNationalIdForm> createState() =>
      _VerifyNationalIdFormState();
}

class _VerifyNationalIdFormState extends ConsumerState<VerifyNationalIdForm> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController(text: '29801011234567');

  @override
  void dispose() {
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .verifyNationalId(_nationalIdController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: EdgeInsets.all(
        context.responsiveValue(
          mobile: AppSpacing.lg,
          tablet: AppSpacing.xl,
          desktop: AppSpacing.xxl,
        ),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('الرقم القومي', 'National ID'),
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(
                'أدخل الرقم القومي المرتبط بحساب الطالب.',
                'Enter the National ID linked to this student account.',
              ),
              style: textTheme.bodySmall?.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              controller: _nationalIdController,
              label: context.tr('الرقم القومي', 'National ID'),
              hintText: '29801011234567',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.badge_outlined,
              onChanged: (_) {
                if (authState.errorMessage != null) {
                  ref.read(authNotifierProvider.notifier).clearError();
                }
              },
              suffixIcon: const Padding(
                padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                child: Icon(Icons.pin_rounded),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return context.tr(
                    'الرقم القومي مطلوب',
                    'National ID is required',
                  );
                }
                if (trimmed.length != 14 ||
                    int.tryParse(trimmed) == null ||
                    trimmed.contains(RegExp(r'\s'))) {
                  return context.tr(
                    'الرقم القومي يجب أن يكون 14 رقمًا',
                    'National ID must be 14 digits',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const _NationalIdHint(),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _VerifyErrorMessage(message: authState.errorMessage!),
            ],
            const SizedBox(height: AppSpacing.lg),
            _VerifySubmitButton(
              isLoading: authState.isSubmitting,
              onPressed: authState.isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _NationalIdHint extends StatelessWidget {
  const _NationalIdHint();

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.tr(
                  'رقم التحقق التجريبي: 29801011234567',
                  'Mock verification ID: 29801011234567',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifyErrorMessage extends StatelessWidget {
  const _VerifyErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final errorColor = Theme.of(context).colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.errorSoft,
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

class _VerifySubmitButton extends StatelessWidget {
  const _VerifySubmitButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isLoading
        ? context.tr('جاري التحقق...', 'Verifying...')
        : context.tr('تحقق ومتابعة', 'Verify and continue');

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        icon: isLoading
            ? SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : const Icon(Icons.verified_rounded, size: 18),
        label: Text(label),
      ),
    );
  }
}
