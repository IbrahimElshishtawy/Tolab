import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/academy_models.dart';
import '../state/academy_actions.dart';
import '../state/academy_state.dart';

class AcademyLoginPage extends StatefulWidget {
  const AcademyLoginPage({super.key});

  @override
  State<AcademyLoginPage> createState() => _AcademyLoginPageState();
}

class _AcademyLoginPageState extends State<AcademyLoginPage> {
  final _emailController = TextEditingController(text: 'admin@tolab.edu');
  final _passwordController = TextEditingController(text: 'Admin@123');
  AcademyRole _selectedRole = AcademyRole.admin;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AcademyAppState, AcademySessionState>(
      converter: (store) => store.state.session,
      builder: (context, session) {
        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.info.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 920;
                        return Flex(
                          direction: compact ? Axis.vertical : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: compact ? 0 : 11,
                              child: _HeroPanel(selectedRole: _selectedRole),
                            ),
                            SizedBox(
                              width: compact ? 0 : AppSpacing.xl,
                              height: compact ? AppSpacing.xl : 0,
                            ),
                            Expanded(
                              flex: 9,
                              child: AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tolab Academy Panel',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Choose a role, sign in, and open the dedicated admin, student, or doctor workspace.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    Wrap(
                                      spacing: AppSpacing.sm,
                                      runSpacing: AppSpacing.sm,
                                      children: AcademyRole.values
                                          .map(
                                            (role) => ChoiceChip(
                                              label: Text(role.label),
                                              selected: _selectedRole == role,
                                              onSelected: (_) {
                                                setState(() {
                                                  _selectedRole = role;
                                                  _emailController.text =
                                                      switch (role) {
                                                        AcademyRole.admin =>
                                                          'admin@tolab.edu',
                                                        AcademyRole.student =>
                                                          'student@tolab.edu',
                                                        AcademyRole.doctor =>
                                                          'doctor@tolab.edu',
                                                      };
                                                });
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    TextField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(
                                          Icons.alternate_email_rounded,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock_rounded),
                                      ),
                                    ),
                                    if (session.errorMessage != null) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      Text(
                                        session.errorMessage!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: AppColors.danger),
                                      ),
                                    ],
                                    const SizedBox(height: AppSpacing.xl),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: session.status.isLoading
                                            ? null
                                            : () {
                                                StoreProvider.of<AcademyAppState>(
                                                  context,
                                                ).dispatch(
                                                  AcademyLoginRequestedAction(
                                                    email: _emailController.text
                                                        .trim(),
                                                    password:
                                                        _passwordController
                                                            .text,
                                                    preferredRole:
                                                        _selectedRole,
                                                  ),
                                                );
                                              },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: AppSpacing.sm,
                                          ),
                                          child: Text(
                                            session.status.isLoading
                                                ? 'Signing In...'
                                                : 'Open ${_selectedRole.label} Workspace',
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.78),
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.mediumRadius,
                                        ),
                                      ),
                                      child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Seeded credentials'),
                                          SizedBox(height: AppSpacing.xs),
                                          Text(
                                            '`admin@tolab.edu`, `student@tolab.edu`, `doctor@tolab.edu`',
                                          ),
                                          Text('Password: `Admin@123`'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.selectedRole});

  final AcademyRole selectedRole;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.88),
      child: AnimatedSwitcher(
        duration: AppMotion.medium,
        child: Column(
          key: ValueKey(selectedRole),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(switch (selectedRole) {
                AcademyRole.admin => Icons.admin_panel_settings_rounded,
                AcademyRole.student => Icons.school_rounded,
                AcademyRole.doctor => Icons.cast_for_education_rounded,
              }, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              selectedRole.shellTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(switch (selectedRole) {
              AcademyRole.admin =>
                'Run the academy from one premium control center with scrollable dashboards, CRUD-ready management pages, moderation, uploads, and realtime notifications.',
              AcademyRole.student =>
                'Track enrolled courses, lectures, tasks, quizzes, exams, calendar milestones, and realtime learning alerts in one focused workflow.',
              AcademyRole.doctor =>
                'Manage teaching load, publish lecture assets, follow student performance, and coordinate academic delivery with drag-drop uploads and course-centric tools.',
            }, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                _HeroBadge(label: 'Premium iOS/macOS style'),
                _HeroBadge(label: 'Full-page vertical scrolling'),
                _HeroBadge(label: 'Laravel API ready'),
                _HeroBadge(label: 'FIFO realtime toasts'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
