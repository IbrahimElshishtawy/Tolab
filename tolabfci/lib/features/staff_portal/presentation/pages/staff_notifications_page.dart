import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/repositories/mock_staff_portal_repository.dart';
import '../providers/staff_portal_providers.dart';

class StaffNotificationsPage extends ConsumerWidget {
  const StaffNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(staffNotificationsStreamProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: notificationsAsync.when(
          data: (items) => ListView(
            children: [
              Text(
                context.tr(
                  'تنبيهات العمل الأكاديمي',
                  'Academic workspace alerts',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.tr(
                  'كل ما يحتاج انتباهك من نشر ومتابعة ومخاطر',
                  'Everything that needs attention around publishing, follow-up, and risk',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () async {
                      await ref
                          .read(staffPortalRepositoryProvider)
                          .markNotificationAsRead(item.id);
                    },
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(item.createdAtLabel),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(item.category),
                          const SizedBox(height: AppSpacing.sm),
                          Text(item.body),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const LoadingWidget(label: 'Loading notifications...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
