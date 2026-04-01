import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../models/schedule_models.dart';

// Reusable premium event tile used in agenda lists and calendar detail views.
class ScheduleEventCard extends StatefulWidget {
  const ScheduleEventCard({
    super.key,
    required this.event,
    required this.conflictReasons,
    this.highlighted = false,
    this.compact = false,
    this.onTap,
    this.onEdit,
  });

  final ScheduleEventItem event;
  final List<String> conflictReasons;
  final bool highlighted;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  State<ScheduleEventCard> createState() => _ScheduleEventCardState();
}

class _ScheduleEventCardState extends State<ScheduleEventCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.event.type.color;
    final conflict = widget.conflictReasons.isNotEmpty;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              color.withValues(alpha: 0.18),
              Theme.of(context).cardColor.withValues(alpha: 0.96),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          border: Border.all(
            color: widget.highlighted
                ? color
                : conflict
                ? AppColors.danger
                : Theme.of(context).dividerColor,
            width: widget.highlighted || conflict ? 1.4 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: _hovered ? 0.18 : 0.10),
              blurRadius: _hovered ? 24 : 16,
              offset: Offset(0, _hovered ? 12 : 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.all(
                widget.compact ? AppSpacing.md : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          widget.event.type.icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.event.subject} | ${widget.event.section}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop && widget.onEdit != null)
                        IconButton(
                          tooltip: 'Edit event',
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _Badge(
                        label: widget.event.type.label,
                        foreground: color,
                        background: color.withValues(alpha: 0.12),
                      ),
                      _Badge(
                        label: widget.event.status.label,
                        foreground: widget.event.status.color,
                        background: widget.event.status.color.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      _Badge(
                        label: '${widget.event.department} | ${widget.event.yearLabel}',
                        foreground: AppColors.info,
                        background: AppColors.info.withValues(alpha: 0.10),
                      ),
                      if (widget.event.repeatRule != ScheduleRepeatRule.none)
                        _Badge(
                          label: widget.event.repeatRule.shortLabel,
                          foreground: AppColors.warning,
                          background: AppColors.warning.withValues(alpha: 0.12),
                        ),
                      _Badge(
                        label: widget.event.isSynced ? 'Synced' : 'Local',
                        foreground: widget.event.isSynced
                            ? AppColors.secondary
                            : AppColors.info,
                        background: (widget.event.isSynced
                                ? AppColors.secondary
                                : AppColors.info)
                            .withValues(alpha: 0.12),
                      ),
                      if (conflict)
                        const _Badge(
                          label: 'Conflict',
                          foreground: AppColors.danger,
                          background: AppColors.dangerSoft,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MetaRow(
                    icon: Icons.schedule_rounded,
                    label:
                        '${DateFormat('EEE, d MMM').format(widget.event.startAt)} | ${DateFormat.jm().format(widget.event.startAt)} - ${DateFormat.jm().format(widget.event.endAt)}',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _MetaRow(
                    icon: Icons.person_outline_rounded,
                    label: widget.event.instructor,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _MetaRow(
                    icon: Icons.location_on_outlined,
                    label: widget.event.location,
                  ),
                  if (!widget.compact &&
                      widget.event.studentScopeLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _MetaRow(
                      icon: Icons.groups_2_outlined,
                      label: widget.event.studentScopeLabel!,
                    ),
                  ],
                  if (!widget.compact &&
                      widget.event.note != null &&
                      widget.event.note!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.event.note!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (conflict) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.conflictReasons.join(' | '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
