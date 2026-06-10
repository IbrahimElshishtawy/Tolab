import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/section_management_models.dart';
import '../design/section_management_tokens.dart';
import 'section_management_primitives.dart';

class SectionHeroHeader extends StatelessWidget {
  const SectionHeroHeader({
    super.key,
    required this.record,
    required this.compact,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActivation,
  });

  final SectionManagementRecord record;
  final bool compact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActivation;

  @override
  Widget build(BuildContext context) {
    final capacityColor = capacityBandColor(record.capacityBand);
    final alertLabel = switch (record.capacityBand) {
      SectionCapacityBand.available =>
        '${record.availableSeats} ${context.l10n.byValue('seats available')}',
      SectionCapacityBand.almostFull => context.l10n.byValue('Almost full, review incoming adds'),
      SectionCapacityBand.full => context.l10n.byValue('Section full, waitlist active'),
    };

    return SectionGlassPanel(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroIdentity(context),
                const SizedBox(height: AppSpacing.lg),
                _buildHeroCapacityCard(context, alertLabel, capacityColor),
                const SizedBox(height: AppSpacing.lg),
                _buildHeroActions(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroIdentity(context),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _InfoPill(
                            icon: Icons.apartment_rounded,
                            label: context.l10n.byValue(record.department),
                          ),
                          _InfoPill(
                            icon: Icons.school_rounded,
                            label: context.l10n.byValue(record.yearLabel),
                          ),
                          _InfoPill(
                            icon: Icons.auto_stories_rounded,
                            label: context.l10n.byValue(record.semesterLabel),
                          ),
                          _InfoPill(
                            icon: Icons.place_outlined,
                            label: context.l10n.byValue(record.locationLabel),
                          ),
                          _InfoPill(
                            icon: Icons.sync_rounded,
                            label: context.l10n.byValue(record.lastUpdatedLabel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildHeroActions(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildHeroCapacityCard(
                        context,
                        alertLabel,
                        capacityColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroIdentity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.byValue('Section Management'),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(record.name, style: Theme.of(context).textTheme.displayMedium),
            _CodeBadge(code: record.code),
            StatusBadge(record.status),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          record.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SectionManagementPalette.subtleText(context),
              ),
        ),
      ],
    );
  }

  Widget _buildHeroCapacityCard(
    BuildContext context,
    String alertLabel,
    Color accentColor,
  ) {
    return AppCard(
      backgroundColor: SectionManagementPalette.frostedSurface(context),
      borderColor: accentColor.withValues(alpha: 0.20),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.people_alt_rounded, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.byValue('Capacity management'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alertLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: accentColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCapacityBar(
            value: record.capacityUsage,
            label:
                '${record.studentsCount} ${context.l10n.byValue('filled of')} ${record.capacity} ${context.l10n.byValue('total seats')}',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniCapacityStat(
                  label: context.l10n.byValue('Available'),
                  value: math.max(record.availableSeats, 0).toString(),
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniCapacityStat(
                  label: context.l10n.byValue('Waitlist'),
                  value: record.waitlistCount.toString(),
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniCapacityStat(
                  label: context.l10n.byValue('Capacity %'),
                  value: '${record.capacityUsagePercent}%',
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActions() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.end,
      children: [
        PremiumButton(
          label: 'Edit',
          icon: Icons.edit_outlined,
          isSecondary: true,
          onPressed: onEdit,
        ),
        PremiumButton(
          label: 'Delete',
          icon: Icons.delete_outline_rounded,
          isDestructive: true,
          onPressed: onDelete,
        ),
        PremiumButton(
          label: record.isActive ? 'Deactivate' : 'Activate',
          icon: record.isActive
              ? Icons.pause_circle_outline_rounded
              : Icons.play_circle_outline_rounded,
          onPressed: onToggleActivation,
        ),
      ],
    );
  }
}

class SectionBackdropOrb extends StatelessWidget {
  const SectionBackdropOrb({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  const _CodeBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        code,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

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
        color: SectionManagementPalette.frostedSurface(
          context,
          lightAlpha: 0.72,
        ),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: SectionManagementPalette.subtleText(context),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _MiniCapacityStat extends StatelessWidget {
  const _MiniCapacityStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
