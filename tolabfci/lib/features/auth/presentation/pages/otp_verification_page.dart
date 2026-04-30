import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/otp_verification_form.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

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
                                Expanded(child: _OtpPanel()),
                                SizedBox(width: AppSpacing.xxxl),
                                SizedBox(
                                  width: 440,
                                  child: OtpVerificationForm(),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _OtpPanel(compact: true),
                                SizedBox(height: AppSpacing.xl),
                                OtpVerificationForm(),
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

class _OtpPanel extends StatelessWidget {
  const _OtpPanel({this.compact = false});

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
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
            Text(
              context.tr('تأكيد البريد الجامعي', 'Confirm university email'),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.tr(
                'هذه خطوة تجريبية جاهزة لاحقا للتكامل مع خدمة OTP أو Microsoft Entra.',
                'This mock step is ready to map later to an OTP service or Microsoft Entra.',
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
