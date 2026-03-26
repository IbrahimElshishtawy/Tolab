import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lottie/lottie.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/forms/app_text_field.dart';
import '../../../state/app_state.dart';
import '../state/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@tolab.edu');
  final _passwordController = TextEditingController(text: 'Admin@123');
  bool _rememberSession = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  if (MediaQuery.sizeOf(context).width > 900)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 280,
                              child: Lottie.asset('assets/lottie/login.json'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Text(
                                'Operational oversight for departments, schedules, moderation, and academic workflows.',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: StoreConnector<AppState, AuthState>(
                      converter: (store) => store.state.authState,
                      builder: (context, authState) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Sign In',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Use `admin@tolab.edu` and `Admin@123` for the seeded admin session.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                AppTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  prefixIcon: Icons.alternate_email_rounded,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                CheckboxListTile(
                                  value: _rememberSession,
                                  onChanged: (value) {
                                    setState(
                                      () => _rememberSession = value ?? true,
                                    );
                                  },
                                  title: const Text('Remember secure session'),
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                                if (authState.errorMessage != null) ...[
                                  Text(
                                    authState.errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed:
                                        authState.status == LoadStatus.loading
                                        ? null
                                        : () {
                                            StoreProvider.of<AppState>(
                                              context,
                                            ).dispatch(
                                              LoginSubmittedAction(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                                rememberSession:
                                                    _rememberSession,
                                              ),
                                            );
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      child:
                                          authState.status == LoadStatus.loading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Continue to Admin Workspace',
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
