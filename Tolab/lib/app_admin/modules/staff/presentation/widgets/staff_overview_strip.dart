import 'package:flutter/material.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import '../../../../core/animations/app_motion.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/staff_admin_models.dart';
import '../design/staff_management_tokens.dart';
import 'staff_status_badge.dart';

class StaffOverviewStrip extends StatelessWidget {
  const StaffOverviewStrip({super.key, required this.records});

  final List<StaffAdminRecord> records;

  @override
  Widget build(BuildContext context) {
    final doctors = records.where((item) => item.isDoctor).toList();
    final assistants = records.where((item) => item.isAssistant).toList();
    final internalDoctors = doctors
        .where((item) => item.isInternalDoctor)
        .length;
    final delegatedDoctors = doctors
        .where((item) => item.isDelegatedDoctor)
        .length;
    final activeCount = records.where((item) => item.status == 'Active').length;
    final needsAttention = records.where((item) => item.needsAttention).length;
    final permissionAverage = records.isEmpty
        ? 0.0
        : records.fold<double>(
                0,
                (sum, item) => sum + item.permissionCoverage,
              ) /
              records.length;

    final isAr = context.l10n.locale.languageCode == 'ar';

    final totalStaffSubtitle = isAr
        ? '$activeCount حساباً نشطاً بين الأطباء والمعيدين.'
        : '$activeCount active accounts across doctors and assistants.';

    final doctorSplitSubtitle = isAr
        ? '$internalDoctors داخلي و $delegatedDoctors منتدب.'
        : '$internalDoctors internal and $delegatedDoctors delegated doctors.';

    final assistantsSubtitle = isAr
        ? '${assistants.where((item) => item.status == 'Active').length} معيداً نشطاً في السكاشن والمعامل.'
        : '${assistants.where((item) => item.status == 'Active').length} assistants are active in sections and labs.';

    final healthSubtitle = isAr
        ? '$needsAttention ملفات بحاجة لمتابعة الحضور أو الصلاحيات أو النشاط.'
        : '$needsAttention profiles currently need attendance, access, or activity follow-up.';

    final cards = [
      _OverviewMetricCard(
        index: 0,
        title: context.l10n.byValue('Total staff accounts'),
        value: records.length.toString(),
        subtitle: totalStaffSubtitle,
        accent: StaffManagementPalette.doctor,
        icon: Icons.groups_2_rounded,
        footer: Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            StaffStatusBadge(context.l10n.byValue('University staff')),
            StaffStatusBadge(context.l10n.byValue('Provisioned')),
          ],
        ),
      ),
      _OverviewMetricCard(
        index: 1,
        title: context.l10n.byValue('Doctor split'),
        value: doctors.length.toString(),
        subtitle: doctorSplitSubtitle,
        accent: StaffManagementPalette.internal,
        icon: Icons.local_hospital_rounded,
        footer: Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            StaffStatusBadge('$internalDoctors ${context.l10n.byValue('internal')}'),
            StaffStatusBadge('$delegatedDoctors ${context.l10n.byValue('delegated')}'),
          ],
        ),
      ),
      _OverviewMetricCard(
        index: 2,
        title: context.l10n.byValue('Teaching assistants'),
        value: assistants.length.toString(),
        subtitle: assistantsSubtitle,
        accent: StaffManagementPalette.assistant,
        icon: Icons.badge_rounded,
        progress: assistants.isEmpty
            ? 0
            : assistants
                      .where((item) => item.engagementRate >= 80)
                      .length /
                  assistants.length,
        progressLabel: context.l10n.byValue('High-engagement assistants'),
        footer: StaffStatusBadge(context.l10n.byValue('Section and lab support')),
      ),
      _OverviewMetricCard(
        index: 3,
        title: context.l10n.byValue('Control health'),
        value: '${permissionAverage.round()}%',
        subtitle: healthSubtitle,
        accent: StaffManagementPalette.engagement,
        icon: Icons.shield_rounded,
        progress: permissionAverage / 100,
        progressLabel: context.l10n.byValue('Average permissions coverage'),
        footer: Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            StaffStatusBadge('$needsAttention ${context.l10n.byValue('needs attention')}'),
            StaffStatusBadge(context.l10n.byValue('Monitoring active')),
          ],
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth >= 900) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: cards[1]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: cards[2]),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: cards[3]),
            ],
          );
        } else if (maxWidth >= 480) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: AppSpacing.md),
              cards[1],
              const SizedBox(height: AppSpacing.md),
              cards[2],
              const SizedBox(height: AppSpacing.md),
              cards[3],
            ],
          );
        }
      },
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.index,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.footer,
    this.progress,
    this.progressLabel,
  });

  final int index;
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final Widget footer;
  final double? progress;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index * 45)),
      curve: AppMotion.entrance,
      builder: (context, valueFactor, child) {
        return Opacity(
          opacity: valueFactor,
          child: Transform.translate(
            offset: Offset(0, (1 - valueFactor) * 16),
            child: child,
          ),
        );
      },
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppConstants.cardRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: StaffManagementDecorations.tintedPanel(
                    context,
                    tint: accent,
                    opacity: 0.10,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: accent),
                ),
                const Spacer(),
                Container(
                  width: 54,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(
                      AppConstants.pillRadius,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            if (progress != null && progressLabel != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                progressLabel!,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                child: LinearProgressIndicator(
                  value: progress!.clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            footer,
          ],
        ),
      ),
    );
  }
}
