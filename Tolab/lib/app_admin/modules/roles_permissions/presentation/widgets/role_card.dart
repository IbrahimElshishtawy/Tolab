import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/role_model.dart';

class RoleCard extends StatefulWidget {
  const RoleCard({
    super.key,
    required this.role,
    required this.permissionCount,
    required this.permissionCoverage,
    required this.selected,
    required this.onTap,
  });

  final RoleModel role;
  final int permissionCount;
  final double permissionCoverage;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _colorFromHex(widget.role.colorHex);
    final borderColor = widget.selected
        ? accent.withValues(alpha: 0.28)
        : theme.dividerColor;
    final backgroundColor = widget.selected
        ? accent.withValues(alpha: 0.08)
        : theme.cardColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AppCard(
        interactive: true,
        onTap: widget.onTap,
        borderColor: borderColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.emphasized,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.95),
                          accent.withValues(alpha: 0.68),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.role.name.substring(0, 1).toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.role.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.role.slug,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (widget.role.isSystem)
                    const StatusBadge('System', icon: Icons.lock_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.role.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _MetricPill(
                    icon: Icons.people_alt_rounded,
                    label: widget.role.membersLabel,
                  ),
                  _MetricPill(
                    icon: Icons.grid_view_rounded,
                    label: '${widget.permissionCount} permissions',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: widget.permissionCoverage.clamp(0, 1),
                  backgroundColor: accent.withValues(alpha: 0.14),
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

Color _colorFromHex(String hex) {
  final value = hex.replaceAll('#', '');
  final normalized = value.length == 6 ? 'FF$value' : value;
  return Color(int.tryParse(normalized, radix: 16) ?? 0xFF2563EB);
}
