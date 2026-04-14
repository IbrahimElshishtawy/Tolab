import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dev/dev_auth_config.dart';
import '../../core/app_scope.dart';
import '../../routing/app_routes.dart';
import 'widgets/auth_form_card.dart';
import 'widgets/auth_hero_panel.dart';
import 'widgets/auth_page_shell.dart';

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@tolab.edu');
  final _passwordController = TextEditingController(text: 'Admin@123');

  bool _rememberSession = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.auth(context);

    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        final state = auth.state;

        return Scaffold(
          body: UnifiedAuthPageShell(
            hero: const UnifiedAuthHeroPanel(),
            form: UnifiedAuthFormCard(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              rememberSession: _rememberSession,
              obscurePassword: _obscurePassword,
              isLoading: state.isLoading,
              errorMessage: state.errorMessage,
              onRememberChanged: (value) {
                setState(() => _rememberSession = value);
              },
              onToggleObscure: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              onSubmit: _submit,
              onQuickLoginDev: _quickLoginDev,
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final auth = AppScope.auth(context);
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberSession: _rememberSession,
    );

    if (!mounted || !success) {
      return;
    }

    _redirectForCurrentUser();
  }

  Future<void> _quickLoginDev() async {
    if (!kDebugMode || !enableDevQuickLogin) {
      return;
    }

    final auth = AppScope.auth(context);
    final success = await auth.quickLoginDev(rememberSession: _rememberSession);

    if (!mounted || !success) {
      return;
    }

    _redirectForCurrentUser();
  }

  void _redirectForCurrentUser() {
    final user = AppScope.auth(context).currentUser;
    if (user == null) {
      return;
    }

    context.go(UnifiedAppRoutes.homeForRole(user.role));
  }
}
