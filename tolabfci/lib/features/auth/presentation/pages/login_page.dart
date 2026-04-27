import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              palette.background,
              palette.surfaceAlt.withValues(alpha: 0.64),
              palette.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = context.isDesktop;
              final horizontalPadding = context.responsiveValue(
                mobile: AppSpacing.md,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxxl,
              );
              final verticalPadding = context.responsiveValue(
                mobile: AppSpacing.lg,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxxl,
              );
              final minHeight = math.max(
                0.0,
                constraints.maxHeight - (verticalPadding * 2),
              );

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: isDesktop
                          ? const _DesktopLoginLayout()
                          : const _CompactLoginLayout(),
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

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Expanded(child: _StudentPortalPanel()),
        SizedBox(width: AppSpacing.xxxl),
        SizedBox(width: 460, child: LoginForm()),
      ],
    );
  }
}

class _CompactLoginLayout extends StatelessWidget {
  const _CompactLoginLayout();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.isTablet ? 560 : 460),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          LoginHeader(),
          SizedBox(height: AppSpacing.xl),
          LoginForm(),
        ],
      ),
    );
  }
}

class _StudentPortalPanel extends StatelessWidget {
  const _StudentPortalPanel();

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: palette.border),
        gradient: LinearGradient(
          colors: isDark
              ? [palette.surface, palette.surfaceAlt]
              : [Colors.white, const Color(0xFFF2F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.07),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PortalMark(),
            const SizedBox(height: AppSpacing.xxxl),
            const LoginHeader(),
            const SizedBox(height: AppSpacing.xxxl),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _PortalSignal(
                  icon: Icons.menu_book_rounded,
                  label: context.tr('المواد', 'Courses'),
                  value: '12',
                ),
                _PortalSignal(
                  icon: Icons.quiz_rounded,
                  label: context.tr('كويزات', 'Quizzes'),
                  value: '3',
                ),
                _PortalSignal(
                  icon: Icons.calendar_month_rounded,
                  label: context.tr('جدول اليوم', 'Today'),
                  value: context.tr('نشط', 'Active'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            _PortalNotice(
              text: context.tr(
                'سيتم التحقق من الرقم القومي بعد تسجيل الدخول مباشرة.',
                'National ID verification follows this sign-in step.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalMark extends StatelessWidget {
  const _PortalMark();

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tolab FCI', style: Theme.of(context).textTheme.titleLarge),
            Text(
              context.tr('بوابة الطالب', 'Student portal'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _PortalSignal extends StatelessWidget {
  const _PortalSignal({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      width: 152,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PortalNotice extends StatelessWidget {
  const _PortalNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.verified_user_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
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
