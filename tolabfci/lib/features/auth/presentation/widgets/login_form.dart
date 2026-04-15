import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
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
  final _emailController = TextEditingController(text: 'omar.nabil@tolab.edu');
  final _passwordController = TextEditingController(text: 'doctor123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _emailController,
              label: context.tr('البريد الجامعي', 'University email'),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.alternate_email_rounded,
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
              obscureText: true,
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
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr(
                'حسابات تجريبية: doctor `omar.nabil@tolab.edu / doctor123`، assistant `nora.sameh@tolab.edu / assistant123`، student `mariam.hassan@tolab.edu / student123`.',
                'Demo accounts: doctor `omar.nabil@tolab.edu / doctor123`, assistant `nora.sameh@tolab.edu / assistant123`, student `mariam.hassan@tolab.edu / student123`.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                authState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            LoginSubmitButton(
              isLoading: authState.isSubmitting,
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .login(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
