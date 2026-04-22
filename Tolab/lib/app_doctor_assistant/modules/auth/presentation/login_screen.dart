import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../state/app_state.dart';
import '../state/auth_actions.dart';
import '../state/auth_selectors.dart';
import '../state/session_selectors.dart';
import '../../../core/navigation/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@tolab.edu');
  final _passwordController = TextEditingController(text: '123456');
  String _selectedPreset = 'Admin';

  static const _presets = <String, String>{
    'Admin': 'admin@tolab.edu',
    'Doctor': 'doctor@tolab.edu',
    'Assistant': 'assistant@tolab.edu',
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: StoreConnector<DoctorAssistantAppState, _LoginViewModel>(
                        converter: (store) => _LoginViewModel.fromStore(store),
                        onWillChange: (previous, current) {
                          if ((previous?.isAuthenticated ?? false) == false &&
                              current.isAuthenticated) {
                            context.go(AppRoutes.dashboard);
                          }
                        },
                        builder: (context, vm) {
                          return Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'University staff login',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Admin-created accounts only. Use your university email and assigned password.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: _presets.entries.map((entry) {
                                    return ChoiceChip(
                                      label: Text(entry.key),
                                      selected: _selectedPreset == entry.key,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedPreset = entry.key;
                                          _emailController.text = entry.value;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                AppTextField(
                                  label: 'University email',
                                  controller: _emailController,
                                  hint: 'admin@tolab.edu',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.alternate_email_rounded,
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AppTextField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  hint: '123456',
                                  obscureText: true,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                                if (vm.error != null) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    vm.error!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.rose500),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Staff test accounts: admin@tolab.edu, doctor@tolab.edu, and assistant@tolab.edu with password 123456',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                AppButton(
                                  label: 'Sign in',
                                  isLoading: vm.isLoading,
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() !=
                                        true) {
                                      return;
                                    }

                                    vm.login(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push(AppRoutes.forgotPassword),
                                    child: const Text('Forgot password?'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginViewModel {
  const _LoginViewModel({
    required this.isLoading,
    required this.error,
    required this.isAuthenticated,
    required this.login,
  });

  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final void Function(String email, String password) login;

  factory _LoginViewModel.fromStore(Store<DoctorAssistantAppState> store) {
    final authState = getAuthState(store.state);
    final sessionUser = getCurrentUser(store.state);

    return _LoginViewModel(
      isLoading: authState.status.name == 'loading',
      error: authState.error,
      isAuthenticated: sessionUser != null,
      login: (email, password) {
        store.dispatch(LoginRequestedAction(email: email, password: password));
      },
    );
  }
}
