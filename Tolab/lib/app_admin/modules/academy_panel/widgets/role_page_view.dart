import 'package:data_table_2/data_table_2.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/academy_models.dart';

class RolePageView extends StatefulWidget {
  const RolePageView({
    super.key,
    required this.page,
    required this.loading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onPrimaryAction,
    required this.onEditRow,
    required this.onDeleteRow,
    required this.onUploadFiles,
    this.header,
  });

  final RolePageData page;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onPrimaryAction;
  final ValueChanged<JsonMap> onEditRow;
  final ValueChanged<JsonMap> onDeleteRow;
  final ValueChanged<List<UploadDraft>> onUploadFiles;
  final Widget? header;

  @override
  State<RolePageView> createState() => _RolePageViewState();
}

class _RolePageViewState extends State<RolePageView> {
  final ScrollController _scrollController = ScrollController();
  late final Map<String, GlobalKey> _sectionKeys;

  @override
  void initState() {
    super.initState();
    _sectionKeys = {
      for (final section in widget.page.sections) section.id: GlobalKey(),
    };
  }

  @override
  void didUpdateWidget(covariant RolePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.key != widget.page.key) {
      _sectionKeys
        ..clear()
        ..addEntries(
          widget.page.sections.map(
            (section) => MapEntry(section.id, GlobalKey()),
          ),
        );
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _jumpTo(String sectionId) async {
    final key = _sectionKeys[sectionId];
    final context = key?.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.header != null) ...[
                  widget.header!,
                  const SizedBox(height: AppSpacing.md),
                ],
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: widget.page.breadcrumbs
                            .map((item) => _BreadcrumbPill(label: item))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.page.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  widget.page.subtitle,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              OutlinedButton.icon(
                                onPressed: widget.onRefresh,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Refresh'),
                              ),
                              FilledButton.icon(
                                onPressed: widget.onPrimaryAction,
                                icon: const Icon(Icons.add_rounded),
                                label: Text(widget.page.primaryActionLabel),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.page.quickJumps.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: widget.page.quickJumps
                              .map(
                                (item) => ActionChip(
                                  avatar: item.icon == null
                                      ? null
                                      : Icon(item.icon, size: 18),
                                  label: Text(item.label),
                                  onPressed: () => _jumpTo(item.sectionId),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (widget.page.backendEndpoints.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: widget.page.backendEndpoints
                              .map(
                                (endpoint) => _EndpointPill(endpoint: endpoint),
                              )
                              .toList(),
                        ),
                      ],
                      if (widget.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.danger),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedStatusHeaderDelegate(
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    if (widget.loading)
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    else
                      const Icon(Icons.arrow_downward_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.loading
                            ? 'Syncing page data from backend...'
                            : 'Full-page scrolling enabled with sticky controls and responsive section cards.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xxxl,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final section = widget.page.sections[index];
                return Padding(
                  key: _sectionKeys[section.id],
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SectionCard(
                    section: section,
                    onEditRow: widget.onEditRow,
                    onDeleteRow: widget.onDeleteRow,
                    onUploadFiles: widget.onUploadFiles,
                  ),
                );
              }, childCount: widget.page.sections.length),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.onEditRow,
    required this.onDeleteRow,
    required this.onUploadFiles,
  });

  final PageSectionData section;
  final ValueChanged<JsonMap> onEditRow;
  final ValueChanged<JsonMap> onDeleteRow;
  final ValueChanged<List<UploadDraft>> onUploadFiles;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(section.subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          switch (section.type) {
            PageSectionType.metrics => _MetricGrid(metrics: section.metrics),
            PageSectionType.cards => _InfoCardGrid(cards: section.cards),
            PageSectionType.list => _ListPanel(items: section.items),
            PageSectionType.timeline => _TimelinePanel(items: section.timeline),
            PageSectionType.table => _TablePanel(
              table: section.table!,
              onEditRow: onEditRow,
              onDeleteRow: onDeleteRow,
            ),
            PageSectionType.uploads => _UploadPanel(
              uploads: section.uploads,
              onUploadFiles: onUploadFiles,
            ),
          },
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<PanelMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: metrics
          .map(
            (metric) => SizedBox(
              width: 260,
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(metric.icon, color: metric.color ?? AppColors.primary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      metric.value,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(metric.label),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      metric.delta,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoCardGrid extends StatelessWidget {
  const _InfoCardGrid({required this.cards});

  final List<PanelInfoCard> cards;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: cards
          .map(
            (card) => SizedBox(
              width: 320,
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.icon != null)
                      Icon(card.icon, color: AppColors.info),
                    if (card.icon != null)
                      const SizedBox(height: AppSpacing.md),
                    Text(
                      card.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      card.value,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(card.caption),
                    if (card.highlight != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        card.highlight!,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ListPanel extends StatelessWidget {
  const _ListPanel({required this.items});

  final List<PanelListItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.72),
                child: Row(
                  children: [
                    if (item.icon != null)
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item.icon, color: AppColors.primary),
                      ),
                    if (item.icon != null) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(item.subtitle),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item.meta),
                        if (item.status != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.status!,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.items});

  final List<PanelTimelineEntry> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 14,
                        width: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 58,
                        color: AppColors.primary.withValues(alpha: 0.18),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.72),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(item.subtitle),
                                if (item.location != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    item.location!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(item.timeLabel),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TablePanel extends StatelessWidget {
  const _TablePanel({
    required this.table,
    required this.onEditRow,
    required this.onDeleteRow,
  });

  final PanelTableData table;
  final ValueChanged<JsonMap> onEditRow;
  final ValueChanged<JsonMap> onDeleteRow;

  @override
  Widget build(BuildContext context) {
    if (table.rows.isEmpty) {
      return Center(child: Text(table.emptyLabel));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: table.columns.length * 210,
        child: DataTable2(
          minWidth: 920,
          fixedTopRows: table.stickyHeader ? 1 : 0,
          columns: [
            ...table.columns.map(
              (column) => DataColumn2(label: Text(column.label)),
            ),
            const DataColumn2(label: Text('Actions')),
          ],
          rows: table.rows
              .map(
                (row) => DataRow2(
                  cells: [
                    ...table.columns.map(
                      (column) =>
                          DataCell(Text('${row.cells[column.key] ?? '-'}')),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => onEditRow(row.cells),
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            onPressed: () => onDeleteRow(row.cells),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({required this.uploads, required this.onUploadFiles});

  final List<UploadItem> uploads;
  final ValueChanged<List<UploadDraft>> onUploadFiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UploadDropzone(onUploadFiles: onUploadFiles),
        const SizedBox(height: AppSpacing.md),
        ...uploads.map(
          (upload) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.72),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_rounded),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upload.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(upload.sizeLabel),
                      ],
                    ),
                  ),
                  Text(upload.status),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadDropzone extends StatefulWidget {
  const _UploadDropzone({required this.onUploadFiles});

  final ValueChanged<List<UploadDraft>> onUploadFiles;

  @override
  State<_UploadDropzone> createState() => _UploadDropzoneState();
}

class _UploadDropzoneState extends State<_UploadDropzone> {
  bool _dragging = false;

  bool get _desktopDropSupported {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    widget.onUploadFiles(
      result.files
          .map(
            (file) => UploadDraft(
              name: file.name,
              path: file.path,
              bytes: file.bytes,
              size: file.size,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: _dragging
            ? AppColors.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: _dragging ? AppColors.primary : Theme.of(context).dividerColor,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_rounded,
            size: 42,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _desktopDropSupported
                ? 'Drag files here or pick from device'
                : 'Pick files from this device',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Supports drag-drop on desktop and file picker flow on mobile/tablet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Choose Files'),
          ),
        ],
      ),
    );

    if (!_desktopDropSupported) return content;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) async {
        setState(() => _dragging = false);
        final files = <UploadDraft>[];
        for (final file in details.files) {
          files.add(
            UploadDraft(
              name: file.name,
              path: file.path,
              bytes: await file.readAsBytes(),
            ),
          );
        }
        widget.onUploadFiles(files);
      },
      child: content,
    );
  }
}

class _EndpointPill extends StatelessWidget {
  const _EndpointPill({required this.endpoint});

  final String endpoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(endpoint),
    );
  }
}

class _BreadcrumbPill extends StatelessWidget {
  const _BreadcrumbPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

class _PinnedStatusHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedStatusHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 84;

  @override
  double get maxExtent => 84;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedStatusHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

Future<JsonMap?> showRecordEditorDialog(
  BuildContext context, {
  required String title,
  required List<PanelTableColumn> columns,
  JsonMap initial = const {},
}) {
  final controllers = <String, TextEditingController>{
    for (final column in columns)
      column.key: TextEditingController(text: '${initial[column.key] ?? ''}'),
  };

  return showDialog<JsonMap>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: columns
                  .map(
                    (column) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TextField(
                        controller: controllers[column.key],
                        decoration: InputDecoration(labelText: column.label),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop({
                for (final column in columns)
                  column.key: controllers[column.key]!.text.trim(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  ).whenComplete(() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
  });
}
