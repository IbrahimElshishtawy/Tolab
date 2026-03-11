import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:tolab_fci/redux/app_state.dart';

import '../../../core/routing/role_routing.dart';
import '../redux/auth_actions.dart';
import '../redux/auth_state.dart';
import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';
import 'widgets/login/login_card.dart';
import 'widgets/login/login_hero_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isFormValid = false;

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password too short';
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScreenBackground(
        bubbles: const [
          AuthBackgroundBubble(
            top: -80,
            right: -30,
            size: 220,
            colors: [Color(0xFF7AB6FF), Color(0xFF2A67F6)],
          ),
          AuthBackgroundBubble(
            top: 180,
            left: -70,
            size: 180,
            colors: [Color(0xFFB7D6FF), Color(0xFF77A7FF)],
          ),
        ],
        child: StoreConnector<AppState, AuthState>(
          converter: (store) => store.state.authState,
          onWillChange: (oldState, newState) {
            if (newState.isAuthenticated) {
              context.go(landingRouteForRole(newState.role));
            }
            if (newState.error != null && newState.error != oldState?.error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(newState.error!)));
            }
          },
          builder: (context, state) {
            return AuthResponsiveLayout(
              heroBuilder: (compact) => LoginHeroPanel(compact: compact),
              form: LoginCard(
                formKey: _formKey,
                emailController: emailController,
                passwordController: passwordController,
                isObscurePassword: _obscurePassword,
                isFormValid: _isFormValid,
                isLoading: state.isLoading,
                validateEmail: _validateEmail,
                validatePassword: _validatePassword,
                onFormChanged: _validateForm,
                onTogglePasswordVisibility: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
                onForgotPassword: () => context.push('/forget-password'),
                onLogin: () {
                  StoreProvider.of<AppState>(context).dispatch(
                    LoginAction(
                      emailController.text.trim(),
                      passwordController.text,
                    ),
                  );
                },
                onDemoAccountSelected: (account) {
                  setState(() {
                    emailController.text = account['email'] ?? '';
                    passwordController.text = account['password'] ?? '';
                    _isFormValid = true;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
