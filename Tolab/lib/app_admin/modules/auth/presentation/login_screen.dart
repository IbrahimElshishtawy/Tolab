import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/colors/app_colors.dart';
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
  bool _obscurePassword = true;

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F9FF), Color(0xFFEEF4FB), Color(0xFFF9FBFD)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -110,
              left: -70,
              child: _BackgroundOrb(
                size: 280,
                colors: [Color(0x332563EB), Color(0x102563EB)],
              ),
            ),
            const Positioned(
              right: -90,
              bottom: -110,
              child: _BackgroundOrb(
                size: 320,
                colors: [Color(0x2216A34A), Color(0x082563EB)],
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 520;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1220),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 6, child: _ShowcasePanel()),
                                  const SizedBox(width: AppSpacing.xl),
                                  Expanded(
                                    flex: 5,
                                    child: _buildLoginPanel(context),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const _ShowcasePanel(compact: true),
                                  const SizedBox(height: AppSpacing.xl),
                                  _buildLoginPanel(context),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context) {
    final theme = Theme.of(context);

    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.authState,
      builder: (context, authState) {
        final isLoading = authState.status == LoadStatus.loading;

        return Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppColors.strokeLight),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 42,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Admin Sign In', style: theme.textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Use your local administrator credentials to continue into the operational workspace.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.strokeLight),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default local admin',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _CredentialChip(
                          icon: Icons.alternate_email_rounded,
                          label: 'admin@tolab.edu',
                        ),
                        _CredentialChip(
                          icon: Icons.key_rounded,
                          label: 'Admin@123',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'admin@tolab.edu',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                enabled: !isLoading,
                suffix: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.strokeLight),
                ),
                child: CheckboxListTile(
                  value: _rememberSession,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() => _rememberSession = value ?? true);
                        },
                  title: const Text('Keep this secure session remembered'),
                  subtitle: const Text(
                    'Recommended for your local admin workspace.',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              if (authState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF991B1B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : () => _submitLogin(context),
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      isLoading
                          ? 'Signing you in...'
                          : 'Continue to Admin Workspace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'If you changed the default admin values in the backend environment, re-run the seeder and use the updated credentials.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitLogin(BuildContext context) {
    StoreProvider.of<AppState>(context).dispatch(
      LoginSubmittedAction(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        rememberSession: _rememberSession,
      ),
    );
  }
}

class _ShowcasePanel extends StatelessWidget {
  const _ShowcasePanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF15357A), Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 48,
            offset: const Offset(0, 28),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Tolab University Admin Console',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Secure control for schedules, departments, and academic operations.',
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Monitor activity, coordinate staff workflows, and keep moderation decisions moving from one polished workspace.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: const [
              _MetricTile(
                icon: Icons.apartment_rounded,
                label: 'Departments',
                value: '12 active',
              ),
              _MetricTile(
                icon: Icons.groups_2_rounded,
                label: 'Staff coverage',
                value: '184 members',
              ),
              _MetricTile(
                icon: Icons.shield_moon_rounded,
                label: 'Security posture',
                value: 'Session protected',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TrustPoint(
                  title: 'Unified admin access',
                  subtitle:
                      'Departments, moderation, sections, and staffing in one workflow.',
                ),
                SizedBox(height: AppSpacing.md),
                _TrustPoint(
                  title: 'Seeded local account',
                  subtitle:
                      'Ready for local development with a predictable admin session.',
                ),
                SizedBox(height: AppSpacing.md),
                _TrustPoint(
                  title: 'Fast recovery path',
                  subtitle:
                      'Demo fallback keeps the workspace available when local auth is misaligned.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 184,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustPoint extends StatelessWidget {
  const _TrustPoint({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
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
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
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

class _CredentialChip extends StatelessWidget {
  const _CredentialChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.strokeLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
