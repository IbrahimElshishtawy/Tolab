import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/staff_portal_providers.dart';

class StaffProfilePage extends ConsumerWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(staffProfileProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: profileAsync.when(
          data: (profile) => ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('${profile.title} • ${profile.roleLabel}'),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _Info(
                          label: context.tr('البريد', 'Email'),
                          value: profile.email,
                        ),
                        _Info(
                          label: context.tr('القسم', 'Department'),
                          value: profile.department,
                        ),
                        _Info(
                          label: context.tr('المكتب', 'Office'),
                          value: profile.office,
                        ),
                        _Info(
                          label: context.tr('الهاتف', 'Phone'),
                          value: profile.phone,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const LoadingWidget(label: 'Loading profile...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
