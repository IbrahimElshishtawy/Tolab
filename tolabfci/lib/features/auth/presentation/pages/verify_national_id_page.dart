import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/verify_national_id_form.dart';

class VerifyNationalIdPage extends StatelessWidget {
  const VerifyNationalIdPage({super.key});

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
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: isDesktop
                          ? const _DesktopVerifyLayout()
                          : const _CompactVerifyLayout(),
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

class _DesktopVerifyLayout extends StatelessWidget {
  const _DesktopVerifyLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Expanded(child: _VerificationPanel()),
        SizedBox(width: AppSpacing.xxxl),
        SizedBox(width: 440, child: VerifyNationalIdForm()),
      ],
    );
  }
}

class _CompactVerifyLayout extends StatelessWidget {
  const _CompactVerifyLayout();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.isTablet ? 560 : 460),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _VerificationPanel(compact: true),
          SizedBox(height: AppSpacing.xl),
          VerifyNationalIdForm(),
        ],
      ),
    );
  }
}

class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
            Text(
              context.tr('تحقق من هويتك', 'Verify your identity'),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.tr(
                'خطوة حماية إضافية قبل فتح مساحة الطالب والمواد الدراسية.',
                'One extra protection step before opening the student workspace.',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.5),
            ),
            if (!compact) ...[
              const SizedBox(height: AppSpacing.xxl),
              _VerificationStep(
                icon: Icons.login_rounded,
                label: context.tr('تم تسجيل الدخول', 'Signed in'),
              ),
              const SizedBox(height: AppSpacing.md),
              _VerificationStep(
                icon: Icons.badge_outlined,
                label: context.tr('أدخل الرقم القومي', 'Enter National ID'),
              ),
              const SizedBox(height: AppSpacing.md),
              _VerificationStep(
                icon: Icons.home_rounded,
                label: context.tr('انتقل إلى الرئيسية', 'Continue home'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  const _VerificationStep({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
          ),
        ),
      ],
    );
  }
}
