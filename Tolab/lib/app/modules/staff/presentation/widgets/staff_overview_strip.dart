import 'package:flutter/material.dart';

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
    final internalDoctors = doctors.where((item) => item.isInternalDoctor).length;
    final delegatedDoctors = doctors.where((item) => item.isDelegatedDoctor).length;
    final activeCount = records.where((item) => item.status == 'Active').length;
    final needsAttention = records.where((item) => item.needsAttention).length;
    final permissionAverage = records.isEmpty
        ? 0.0
        : records.fold<double>(
              0,
              (sum, item) => sum + item.permissionCoverage,
            ) /
            records.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 940;
        final width = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - (AppSpacing.md * 3)) / 4;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: width,
              child: _OverviewMetricCard(
                index: 0,
                title: 'Total staff accounts',
                value: records.length.toString(),
                subtitle:
                    '$activeCount active accounts across doctors and assistants.',
                accent: StaffManagementPalette.doctor,
                icon: Icons.groups_2_rounded,
                footer: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: const [
                    StaffStatusBadge('University staff'),
                    StaffStatusBadge('Provisioned'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: _OverviewMetricCard(
                index: 1,
                title: 'Doctor split',
                value: doctors.length.toString(),
                subtitle:
                    '$internalDoctors internal and $delegatedDoctors delegated doctors.',
                accent: StaffManagementPalette.internal,
                icon: Icons.stethoscope_rounded,
                footer: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StaffStatusBadge('$internalDoctors internal'),
                    StaffStatusBadge('$delegatedDoctors delegated'),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: _OverviewMetricCard(
                index: 2,
                title: 'Teaching assistants',
                value: assistants.length.toString(),
                subtitle:
                    '${assistants.where((item) => item.status == 'Active').length} assistants are active in sections and labs.',
                accent: StaffManagementPalette.assistant,
                icon: Icons.badge_rounded,
                progress: assistants.isEmpty
                    ? 0
                    : assistants
                            .where((item) => item.engagementRate >= 80)
                            .length /
                        assistants.length,
                progressLabel: 'High-engagement assistants',
                footer: const StaffStatusBadge('Section and lab support'),
              ),
            ),
            SizedBox(
              width: width,
              child: _OverviewMetricCard(
                index: 3,
                title: 'Control health',
                value: '${permissionAverage.round()}%',
                subtitle:
                    '$needsAttention profiles currently need attendance, access, or activity follow-up.',
                accent: StaffManagementPalette.engagement,
                icon: Icons.shield_rounded,
                progress: permissionAverage / 100,
                progressLabel: 'Average permissions coverage',
                footer: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StaffStatusBadge('$needsAttention needs attention'),
                    const StaffStatusBadge('Monitoring active'),
                  ],
                ),
              ),
            ),
          ],
        );
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
                    borderRadius: BorderRadius.circular(AppConstants.pillRadius),
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
              Text(progressLabel!, style: Theme.of(context).textTheme.labelMedium),
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
