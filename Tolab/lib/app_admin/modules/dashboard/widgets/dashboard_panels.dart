import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/dashboard_models.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({
    super.key,
    required this.actions,
    required this.onActionSelected,
  });

  final List<DashboardQuickAction> actions;
  final ValueChanged<DashboardQuickAction> onActionSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Fast entry points for the highest-frequency admin operations.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final action in actions) ...[
            _ActionTile(action: action, onTap: () => onActionSelected(action)),
            if (action != actions.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class RecentActivityPanel extends StatelessWidget {
  const RecentActivityPanel({super.key, required this.items});

  final List<DashboardActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'The latest operational movement across students, staff, and subjects.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimationLimiter(
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++)
                  AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 320),
                    child: SlideAnimation(
                      verticalOffset: 18,
                      child: FadeInAnimation(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: _activityTone(items[index].type).withValues(
                              alpha: items[index].highlighted ? 0.12 : 0.06,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppConstants.mediumRadius,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: _activityTone(
                                    items[index].type,
                                  ).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _activityIcon(items[index].type),
                                  color: _activityTone(items[index].type),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      items[index].title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      items[index].subtitle,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      items[index].actorName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                items[index].timeLabel,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModerationAlertsPanel extends StatelessWidget {
  const ModerationAlertsPanel({super.key, required this.items});

  final List<DashboardModerationAlert> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pending moderation',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningSoft.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
                child: Text(
                  '${items.fold<int>(0, (sum, item) => sum + item.flaggedCount)} items',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Flagged conversations and content issues waiting for intervention.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final item in items) ...[
            _AlertTile(item: item),
            if (item != items.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class ScheduleSummaryPanel extends StatelessWidget {
  const ScheduleSummaryPanel({super.key, required this.items});

  final List<DashboardScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Upcoming lectures, exams, and tasks across the selected scope.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final item in items) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _scheduleColor(item.type).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallRadius,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          item.dayLabel,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.timeLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.location} • ${item.owner}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    item.statusLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _scheduleColor(item.type),
                    ),
                  ),
                ],
              ),
            ),
            if (item != items.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.onTap});

  final DashboardQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.82),
      onTap: action.enabled ? onTap : null,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
            child: Icon(_actionIcon(action.id), color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_outward_rounded, size: 18),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.item});

  final DashboardModerationAlert item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.severity) {
      DashboardAlertSeverity.low => AppColors.info,
      DashboardAlertSeverity.medium => AppColors.warning,
      DashboardAlertSeverity.high => AppColors.danger,
      DashboardAlertSeverity.critical => AppColors.danger,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_rounded, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.scopeLabel} • ${item.flaggedCount} flagged',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _actionIcon(String id) {
  return switch (id) {
    'add_student' => Icons.person_add_alt_1_rounded,
    'add_staff' => Icons.badge_rounded,
    'add_course' => Icons.library_add_rounded,
    'send_notification' => Icons.campaign_rounded,
    _ => Icons.flash_on_rounded,
  };
}

Color _activityTone(DashboardActivityType type) {
  return switch (type) {
    DashboardActivityType.student => AppColors.primary,
    DashboardActivityType.staff => AppColors.secondary,
    DashboardActivityType.subject => AppColors.info,
    DashboardActivityType.enrollment => AppColors.primary,
    DashboardActivityType.moderation => AppColors.warning,
    DashboardActivityType.schedule => AppColors.purple,
    DashboardActivityType.system => AppColors.slate,
  };
}

IconData _activityIcon(DashboardActivityType type) {
  return switch (type) {
    DashboardActivityType.student => Icons.school_rounded,
    DashboardActivityType.staff => Icons.groups_rounded,
    DashboardActivityType.subject => Icons.menu_book_rounded,
    DashboardActivityType.enrollment => Icons.playlist_add_check_circle_rounded,
    DashboardActivityType.moderation => Icons.shield_rounded,
    DashboardActivityType.schedule => Icons.event_available_rounded,
    DashboardActivityType.system => Icons.settings_suggest_rounded,
  };
}

Color _scheduleColor(DashboardScheduleType type) {
  return switch (type) {
    DashboardScheduleType.lecture => AppColors.primary,
    DashboardScheduleType.exam => AppColors.danger,
    DashboardScheduleType.task => AppColors.warning,
    DashboardScheduleType.meeting => AppColors.info,
    DashboardScheduleType.review => AppColors.secondary,
  };
}
