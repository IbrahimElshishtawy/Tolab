import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../state/app_state.dart';
import '../../models/moderation_models.dart';
import '../widgets/moderation_charts.dart';

class ModerationAnalyticsScreen extends StatelessWidget {
  const ModerationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _AnalyticsViewModel>(
      converter: (store) => _AnalyticsViewModel(
        analytics: store.state.moderationState.analytics,
        reportsCount: store.state.moderationState.reports.length,
        groupsCount: store.state.moderationState.groups.length,
        moderatorsCount: store.state.moderationState.moderators.length,
      ),
      builder: (context, vm) {
        return Column(
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _SummaryCard(
                  label: 'Total reports',
                  value: vm.reportsCount.toString(),
                ),
                _SummaryCard(
                  label: 'Moderated groups',
                  value: vm.groupsCount.toString(),
                ),
                _SummaryCard(
                  label: 'Moderator seats',
                  value: vm.moderatorsCount.toString(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: ModerationAnalyticsOverview(analytics: vm.analytics)),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsViewModel {
  const _AnalyticsViewModel({
    required this.analytics,
    required this.reportsCount,
    required this.groupsCount,
    required this.moderatorsCount,
  });

  final ModerationAnalytics analytics;
  final int reportsCount;
  final int groupsCount;
  final int moderatorsCount;
}
