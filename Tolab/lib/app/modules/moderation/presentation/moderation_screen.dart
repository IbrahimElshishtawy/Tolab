import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/models/moderation_models.dart';
import '../../../shared/tables/admin_data_table.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/filter_bar.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../state/app_state.dart';
import '../state/moderation_state.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  String _selectedFilter = 'All reports';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ModerationState>(
      onInit: (store) => store.dispatch(LoadModerationAction()),
      converter: (store) => store.state.moderationState,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Moderation',
              subtitle:
                  'Review posts, comments, and messages with a clean action-oriented moderation queue and contextual review panel.',
              breadcrumbs: ['Admin', 'Safety', 'Moderation'],
              actions: [
                PremiumButton(
                  label: 'Policy center',
                  icon: Icons.rule_folder_outlined,
                  isSecondary: true,
                ),
                PremiumButton(
                  label: 'Assign moderator',
                  icon: Icons.admin_panel_settings_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: const [
                _ModerationMetric(
                  label: 'Open reports',
                  value: '18',
                  color: AppColors.warning,
                ),
                _ModerationMetric(
                  label: 'Auto-hidden',
                  value: '7',
                  color: AppColors.info,
                ),
                _ModerationMetric(
                  label: 'Escalated',
                  value: '3',
                  color: AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilterBar(
              searchHint: 'Search author, group, content, report ID',
              filters: const ['All reports', 'Pending', 'Flagged', 'Messages'],
              selectedFilter: _selectedFilter,
              onFilterSelected: (value) =>
                  setState(() => _selectedFilter = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AsyncStateView(
                status: state.status,
                errorMessage: state.errorMessage,
                onRetry: () => StoreProvider.of<AppState>(
                  context,
                ).dispatch(LoadModerationAction()),
                isEmpty: state.items.isEmpty,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showSidePanel = constraints.maxWidth > 1160;

                    return showSidePanel
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _ModerationTable(items: state.items),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 4,
                                child: _ReviewPanel(
                                  item: state.items.isNotEmpty
                                      ? state.items.first
                                      : null,
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            children: [
                              SizedBox(
                                height: 520,
                                child: _ModerationTable(items: state.items),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _ReviewPanel(
                                item: state.items.isNotEmpty
                                    ? state.items.first
                                    : null,
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModerationTable extends StatelessWidget {
  const _ModerationTable({required this.items});

  final List<ModerationItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review queue', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: AdminDataTable<ModerationItem>(
              items: items,
              columns: [
                AdminTableColumn<ModerationItem>(
                  label: 'Content',
                  cellBuilder: (item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.type,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.preview,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AdminTableColumn<ModerationItem>(
                  label: 'Author',
                  cellBuilder: (item) => Text(item.author),
                ),
                AdminTableColumn<ModerationItem>(
                  label: 'Context',
                  cellBuilder: (item) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.groupName),
                      const SizedBox(height: 2),
                      Text(
                        '${item.reportsCount} reports  ${item.createdAtLabel}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                AdminTableColumn<ModerationItem>(
                  label: 'Actions',
                  cellBuilder: (item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(item.status),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                      ),
                    ],
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

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({required this.item});

  final ModerationItem? item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: item == null
          ? const Center(child: Text('No moderation item selected'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Review details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    StatusBadge(item!.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoLine(label: 'Type', value: item!.type),
                _InfoLine(label: 'Author', value: item!.author),
                _InfoLine(label: 'Group', value: item!.groupName),
                _InfoLine(
                  label: 'Reports',
                  value: item!.reportsCount.toString(),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                  child: Text(item!.preview),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.psychology_alt_outlined,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'AI policy signal: tone escalation with repeated external-link pattern.',
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        label: 'Hide',
                        icon: Icons.visibility_off_outlined,
                        isSecondary: true,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: PremiumButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _ModerationMetric extends StatelessWidget {
  const _ModerationMetric({
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
      width: 210,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
