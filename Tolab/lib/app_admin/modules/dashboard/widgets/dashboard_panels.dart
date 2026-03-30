import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/enums/load_status.dart';
import '../state/dashboard_state.dart';

class DashboardSearchResultsPanel extends StatelessWidget {
  const DashboardSearchResultsPanel({
    super.key,
    required this.query,
    required this.results,
    required this.searchStatus,
    required this.onEntrySelected,
  });

  final String query;
  final List<DashboardDirectoryEntry> results;
  final LoadStatus searchStatus;
  final ValueChanged<DashboardDirectoryEntry> onEntrySelected;

  @override
  Widget build(BuildContext context) {
    final heading = query.trim().isEmpty ? 'Suggested people' : 'Search results';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      query.trim().isEmpty
                          ? 'Students, doctors, and assistants most relevant to current operations.'
                          : 'Results update instantly from the local index while Laravel search refines them in the background.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (searchStatus == LoadStatus.loading)
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (results.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'No matching student, doctor, or assistant was found for this query.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final entry in results)
                  SizedBox(
                    width: 280,
                    child: _DirectoryCard(
                      entry: entry,
                      onTap: () => onEntrySelected(entry),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'High-priority shortcuts for daily academy admin work.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final action in actions) ...[
            _QuickActionButton(
              action: action,
              onTap: () => onActionSelected(action),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class DashboardAlertsPanel extends StatelessWidget {
  const DashboardAlertsPanel({super.key, required this.alerts});

  final List<DashboardAlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live alerts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Queues that should stay visible while notifications continue in the top shell.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final alert in alerts) ...[
            _AlertTile(alert: alert),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class RecentActivityTableCard extends StatefulWidget {
  const RecentActivityTableCard({super.key, required this.rows});

  final List<DashboardActivityRow> rows;

  @override
  State<RecentActivityTableCard> createState() => _RecentActivityTableCardState();
}

class _RecentActivityTableCardState extends State<RecentActivityTableCard> {
  final TextEditingController _queryController = TextEditingController();
  DashboardActivityCategory _category = DashboardActivityCategory.all;
  int _sortColumnIndex = 4;
  bool _sortAscending = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _applyFilters(widget.rows);
    final source = _ActivityDataSource(
      context: context,
      rows: filteredRows,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent registrations, uploads, and review queue',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sortable, searchable, sticky-headed operations table with pagination for large queues.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 340,
                child: TextField(
                  controller: _queryController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search activity table',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              for (final category in DashboardActivityCategory.values)
                ChoiceChip(
                  selected: _category == category,
                  label: Text(category.label),
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PaginatedDataTable2(
            columnSpacing: 18,
            horizontalMargin: 12,
            dataRowHeight: 72,
            rowsPerPage: _rowsPerPage,
            minWidth: 1100,
            showFirstLastButtons: true,
            fixedTopRows: 1,
            onRowsPerPageChanged: (value) {
              if (value == null) return;
              setState(() => _rowsPerPage = value);
            },
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: [
              DataColumn2(
                label: const Text('Category'),
                size: ColumnSize.S,
                onSort: (columnIndex, ascending) => _sort<String>(
                  columnIndex,
                  ascending,
                  filteredRows,
                  (row) => row.type.label,
                ),
              ),
              DataColumn2(
                label: const Text('Title'),
                size: ColumnSize.L,
                onSort: (columnIndex, ascending) => _sort<String>(
                  columnIndex,
                  ascending,
                  filteredRows,
                  (row) => row.title,
                ),
              ),
              DataColumn2(
                label: const Text('Actor'),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) => _sort<String>(
                  columnIndex,
                  ascending,
                  filteredRows,
                  (row) => row.actor,
                ),
              ),
              DataColumn2(
                label: const Text('Department'),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) => _sort<String>(
                  columnIndex,
                  ascending,
                  filteredRows,
                  (row) => row.department,
                ),
              ),
              DataColumn2(
                label: const Text('Created'),
                size: ColumnSize.S,
                onSort: (columnIndex, ascending) => _sort<DateTime>(
                  columnIndex,
                  ascending,
                  filteredRows,
                  (row) => row.createdAt,
                ),
              ),
              const DataColumn2(
                label: Text('Status'),
                size: ColumnSize.S,
              ),
            ],
            source: source,
          ),
        ],
      ),
    );
  }

  List<DashboardActivityRow> _applyFilters(List<DashboardActivityRow> rows) {
    final filtered = rows
        .where((row) => row.matchesCategory(_category))
        .where((row) => row.matchesQuery(_queryController.text))
        .toList(growable: true);

    filtered.sort(_compareRows);
    return filtered;
  }

  int _compareRows(DashboardActivityRow left, DashboardActivityRow right) {
    final factor = _sortAscending ? 1 : -1;
    return switch (_sortColumnIndex) {
      0 => factor * left.type.label.compareTo(right.type.label),
      1 => factor * left.title.compareTo(right.title),
      2 => factor * left.actor.compareTo(right.actor),
      3 => factor * left.department.compareTo(right.department),
      _ => factor * left.createdAt.compareTo(right.createdAt),
    };
  }

  void _sort<T>(
    int columnIndex,
    bool ascending,
    List<DashboardActivityRow> rows,
    Comparable<T> Function(DashboardActivityRow row) getField,
  ) {
    rows.sort((a, b) {
      final left = getField(a);
      final right = getField(b);
      return ascending
          ? Comparable.compare(left, right)
          : Comparable.compare(right, left);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
}

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({required this.entry, required this.onTap});

  final DashboardDirectoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = _roleColor(entry.role);
    return AppCard(
      interactive: true,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: tone.withValues(alpha: 0.14),
                child: Text(
                  entry.initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: tone,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      entry.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MiniChip(label: entry.role.label, color: tone),
              _MiniChip(label: entry.departmentLabel, color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(entry.statusLabel, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Last seen ${entry.lastSeenLabel}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.onTap});

  final DashboardQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _toneColor(action.tone);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent.withValues(alpha: 0.96),
              accent.withValues(alpha: 0.72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.24),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_actionIcon(action.id), color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    action.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final DashboardAlertItem alert;

  @override
  Widget build(BuildContext context) {
    final accent = _toneColor(alert.tone);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_active_rounded, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(alert.subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _MiniChip(label: alert.counterLabel, color: accent),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _ActivityDataSource extends DataTableSource {
  _ActivityDataSource({
    required BuildContext context,
    required List<DashboardActivityRow> rows,
  }) : _context = context,
       _rows = rows;

  final BuildContext _context;
  final List<DashboardActivityRow> _rows;

  @override
  DataRow? getRow(int index) {
    if (index >= _rows.length) return null;
    final row = _rows[index];
    return DataRow(
      cells: [
        DataCell(_MiniChip(label: row.type.label, color: _toneColor(row.tone))),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(row.title, style: Theme.of(_context).textTheme.titleSmall),
              const SizedBox(height: 4),
              SizedBox(
                width: 280,
                child: Text(
                  row.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(_context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(row.actor)),
        DataCell(Text(row.department)),
        DataCell(Text(row.createdAtLabel)),
        DataCell(_MiniChip(label: row.statusLabel, color: _toneColor(row.tone))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _rows.length;

  @override
  int get selectedRowCount => 0;
}

Color _roleColor(DashboardDirectoryRole role) => switch (role) {
  DashboardDirectoryRole.student => AppColors.primary,
  DashboardDirectoryRole.doctor => AppColors.secondary,
  DashboardDirectoryRole.assistant => AppColors.info,
};

Color _toneColor(DashboardMetricTone tone) => switch (tone) {
  DashboardMetricTone.primary => AppColors.primary,
  DashboardMetricTone.info => AppColors.info,
  DashboardMetricTone.success => AppColors.secondary,
  DashboardMetricTone.warning => AppColors.warning,
  DashboardMetricTone.danger => AppColors.danger,
};

IconData _actionIcon(String id) => switch (id) {
  'add-student' => Icons.person_add_alt_1_rounded,
  'assign-course' => Icons.assignment_ind_rounded,
  'upload-content' => Icons.cloud_upload_rounded,
  _ => Icons.flash_on_rounded,
};
