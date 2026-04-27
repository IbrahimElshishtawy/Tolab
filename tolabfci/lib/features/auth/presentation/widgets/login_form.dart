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
import 'login_submit_button.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'student@test.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
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
              context.tr('تسجيل الدخول', 'Sign in'),
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(
                'استخدم حساب الطالب الجامعي للمتابعة.',
                'Use your student university account to continue.',
              ),
              style: textTheme.bodySmall?.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              controller: _emailController,
              label: context.tr('البريد الجامعي', 'University email'),
              hintText: 'student@test.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.alternate_email_rounded,
              onChanged: (_) {
                if (authState.errorMessage != null) {
                  ref.read(authNotifierProvider.notifier).clearError();
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.tr('البريد مطلوب', 'Email is required');
                }
                if (!value.contains('@')) {
                  return context.tr(
                    'أدخل بريدًا صحيحًا',
                    'Enter a valid email',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _passwordController,
              label: context.tr('كلمة المرور', 'Password'),
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              onChanged: (_) {
                if (authState.errorMessage != null) {
                  ref.read(authNotifierProvider.notifier).clearError();
                }
              },
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? context.tr('إظهار كلمة المرور', 'Show password')
                    : context.tr('إخفاء كلمة المرور', 'Hide password'),
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
                if (value == null || value.trim().isEmpty) {
                  return context.tr(
                    'كلمة المرور مطلوبة',
                    'Password is required',
                  );
                }
                if (value.length < 6) {
                  return context.tr(
                    'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                    'Password must be at least 6 characters',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const _StudentCredentialHint(),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _AuthErrorMessage(message: authState.errorMessage!),
            ],
            const SizedBox(height: AppSpacing.lg),
            LoginSubmitButton(
              isLoading: authState.isSubmitting,
              onPressed: authState.isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCredentialHint extends StatelessWidget {
  const _StudentCredentialHint();

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
                  'حساب الطالب التجريبي: student@test.com / 123456',
                  'Student demo account: student@test.com / 123456',
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

class _AuthErrorMessage extends StatelessWidget {
  const _AuthErrorMessage({required this.message});

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
