import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/set_new_password_form.dart';

class SetNewPasswordPage extends StatelessWidget {
  const SetNewPasswordPage({super.key});

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
                      child: context.isDesktop
                          ? const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: _PasswordPanel()),
                                SizedBox(width: AppSpacing.xxxl),
                                SizedBox(
                                  width: 440,
                                  child: SetNewPasswordForm(),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _PasswordPanel(compact: true),
                                SizedBox(height: AppSpacing.xl),
                                SetNewPasswordForm(),
                              ],
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

class _PasswordPanel extends StatelessWidget {
  const _PasswordPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: palette.border),
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
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: AppColors.success,
                size: 28,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
            Text(
              context.tr('أمن حسابك', 'Secure your account'),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.tr(
                'سيتم حفظ كلمة المرور الجديدة في وضع التجربة محليا، ويمكن لاحقا ربطها بنقطة API مخصصة.',
                'The mock flow stores completion locally and can later connect to a dedicated API endpoint.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
