import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../state/app_state.dart';
import '../../../../shared/models/notification_models.dart';
import '../../state/notifications_state.dart';

class NotificationToastHost extends StatefulWidget {
  const NotificationToastHost({super.key});

  @override
  State<NotificationToastHost> createState() => _NotificationToastHostState();
}

class _NotificationToastHostState extends State<NotificationToastHost> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AdminNotification?>(
      distinct: true,
      converter: (store) => store.state.notificationsState.activeToast,
      onDidChange: (_, current) {
        _timer?.cancel();
        if (current == null) return;
        _timer = Timer(const Duration(seconds: 4), () {
          if (!mounted) return;
          StoreProvider.of<AppState>(
            context,
            listen: false,
          ).dispatch(const NotificationToastDismissedAction());
        });
      },
      builder: (context, notification) {
        final isMobile = MediaQuery.sizeOf(context).width < 760;
        return IgnorePointer(
          ignoring: notification == null,
          child: SafeArea(
            child: Align(
              alignment: isMobile ? Alignment.topCenter : Alignment.topRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, -0.18),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: notification == null
                    ? const SizedBox.shrink()
                    : Padding(
                        key: ValueKey(notification.id),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: isMobile
                              ? MediaQuery.sizeOf(context).width - 32
                              : 380,
                          child: _NotificationToastCard(
                            notification: notification,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationToastCard extends StatelessWidget {
  const _NotificationToastCard({required this.notification});

  final AdminNotification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.94),
      borderRadius: AppConstants.dialogRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: _accent(notification.category).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _icon(notification.category),
                  color: _accent(notification.category),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.byValue(notification.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.byValue(notification.category.label)} • ${notification.createdAtLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => StoreProvider.of<AppState>(
                  context,
                  listen: false,
                ).dispatch(const NotificationToastDismissedAction()),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.byValue(notification.body),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: () {
                  context.go(RoutePaths.notifications);
                  StoreProvider.of<AppState>(context, listen: false).dispatch(
                    MarkNotificationReadRequestedAction(notification.id),
                  );
                },
                child: Text(l10n.t('common.actions.open')),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    StoreProvider.of<AppState>(context, listen: false).dispatch(
                      MarkNotificationReadRequestedAction(notification.id),
                    ),
                child: Text(l10n.t('common.actions.mark_as_read')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _accent(AdminNotificationCategory category) => switch (category) {
    AdminNotificationCategory.academic => AppColors.primary,
    AdminNotificationCategory.messages => AppColors.info,
    AdminNotificationCategory.system => AppColors.warning,
    AdminNotificationCategory.announcements => AppColors.secondary,
  };

  IconData _icon(AdminNotificationCategory category) => switch (category) {
    AdminNotificationCategory.academic => Icons.school_rounded,
    AdminNotificationCategory.messages => Icons.mark_chat_unread_rounded,
    AdminNotificationCategory.system => Icons.settings_suggest_rounded,
    AdminNotificationCategory.announcements => Icons.campaign_rounded,
  };
}
