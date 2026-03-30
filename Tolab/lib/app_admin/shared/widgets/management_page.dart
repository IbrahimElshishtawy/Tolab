import 'package:flutter/material.dart';

import '../../core/spacing/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_header.dart';
import '../enums/load_status.dart';
import '../tables/admin_data_table.dart';
import 'async_state_view.dart';
import 'filter_bar.dart';

class ManagementPage<T> extends StatelessWidget {
  const ManagementPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.items,
    required this.columns,
    required this.searchHint,
    this.errorMessage,
    this.headerActions = const [],
    this.summaryCards = const [],
    this.onRetry,
  });

  final String title;
  final String subtitle;
  final LoadStatus status;
  final List<T> items;
  final List<AdminTableColumn<T>> columns;
  final String searchHint;
  final String? errorMessage;
  final List<Widget> headerActions;
  final List<Widget> summaryCards;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: title,
          subtitle: subtitle,
          breadcrumbs: const ['Admin', 'Workspace'],
          actions: headerActions,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (summaryCards.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: summaryCards,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        FilterBar(searchHint: searchHint),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: AsyncStateView(
            status: status,
            errorMessage: errorMessage,
            onRetry: onRetry,
            isEmpty: status == LoadStatus.success && items.isEmpty,
            child: AppCard(
              child: AdminDataTable<T>(items: items, columns: columns),
            ),
          ),
        ),
      ],
    );
  }
}
