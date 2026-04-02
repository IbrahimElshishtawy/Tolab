import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_scope.dart';
import '../../routing/app_routes.dart';

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
    final state = auth.state;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F8FC), Color(0xFFF3F7FF), Color(0xFFEEF3FA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 920;

                    return isWide
                        ? Row(
                            children: [
                              const Expanded(flex: 11, child: _LoginHeroPanel()),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 9,
                                child: _LoginCard(
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
                                    setState(
                                      () => _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                  onSubmit: _submit,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _LoginHeroPanel(compact: true),
                              const SizedBox(height: 20),
                              _LoginCard(
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
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                                onSubmit: _submit,
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
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

    final user = auth.currentUser;
    if (user == null) {
      return;
    }

    context.go(UnifiedAppRoutes.homeForRole(user.role));
  }
}

class _LoginHeroPanel extends StatelessWidget {
  const _LoginHeroPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF123676), Color(0xFF2563EB)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Unified Access',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'One secure login for admin, doctor, and assistant access.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Role and permissions are resolved from the backend after authentication. Internal workspaces stay separated.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _HeroChip(label: 'Admin dashboard'),
              _HeroChip(label: 'Doctor workspace'),
              _HeroChip(label: 'Assistant workspace'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TrustLine(
                  title: 'Backend-driven role detection',
                  subtitle: 'No manual role picker in the login flow.',
                ),
                SizedBox(height: 12),
                _TrustLine(
                  title: 'Shared session persistence',
                  subtitle: 'One auth state, one logout path, protected routing.',
                ),
                SizedBox(height: 12),
                _TrustLine(
                  title: 'Development-ready local accounts',
                  subtitle:
                      'admin@tolab.edu, doctor@tolab.edu, assistant@tolab.edu',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE5EAF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 36,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sign in',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use your university email and password. Your role is resolved automatically after login.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5B6475),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'University email',
                hintText: 'name@tolab.edu',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return 'Email is required';
                }
                if (!email.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
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
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: rememberSession,
              onChanged: isLoading
                  ? null
                  : (value) => onRememberChanged(value ?? true),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('Remember this session'),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : onSubmit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(isLoading ? 'Signing in...' : 'Continue'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => context.go(UnifiedAppRoutes.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
