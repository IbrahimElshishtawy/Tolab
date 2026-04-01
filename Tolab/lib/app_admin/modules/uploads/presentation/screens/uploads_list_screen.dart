import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../state/app_state.dart';
import '../../models/upload_model.dart';
import '../../state/uploads_actions.dart';
import '../../state/uploads_selectors.dart';
import '../widgets/drag_drop_area.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/upload_card.dart';
import '../widgets/upload_table.dart';
import 'upload_preview_screen.dart';

class UploadsListScreen extends StatefulWidget {
  const UploadsListScreen({super.key});

  @override
  State<UploadsListScreen> createState() => _UploadsListScreenState();
}

class _UploadsListScreenState extends State<UploadsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _UploadsViewModel>(
      onInit: (store) => store.dispatch(const FetchUploadsAction()),
      converter: (store) => _UploadsViewModel.fromStore(store),
      onDidChange: (previous, current) {
        if (previous?.feedbackMessage != current.feedbackMessage &&
            current.feedbackMessage != null &&
            current.feedbackMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(current.feedbackMessage!)));
          StoreProvider.of<AppState>(
            context,
          ).dispatch(const UploadsFeedbackClearedAction());
        }
        if (_searchController.text != current.filters.searchQuery) {
          _searchController.value = TextEditingValue(
            text: current.filters.searchQuery,
            selection: TextSelection.collapsed(
              offset: current.filters.searchQuery.length,
            ),
          );
        }
      },
      builder: (context, vm) {
        final isMobile = AppBreakpoints.isMobile(context);
        final isDesktop = AppBreakpoints.isDesktop(context);
        final store = StoreProvider.of<AppState>(context);

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          children: [
            PageHeader(
              title: 'Uploads',
              subtitle:
                  'A premium file operations workspace for materials, sections, permissions, previews, and large upload queues.',
              breadcrumbs: const ['Admin', 'Content', 'Uploads'],
              actions: [
                PremiumButton(
                  label: 'Select Files',
                  icon: Icons.attach_file_rounded,
                  onPressed: () => _pickFiles(store),
                ),
                PremiumButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  isSecondary: true,
                  onPressed: () => store.dispatch(const FetchUploadsAction()),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildStats(vm),
            const SizedBox(height: AppSpacing.lg),
            if (vm.isOffline) ...[
              const _OfflineBanner(),
              const SizedBox(height: AppSpacing.md),
            ],
            if (vm.status == LoadStatus.refreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: LinearProgressIndicator(),
              ),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: DragDropArea(onFilesSelected: _dispatchFiles),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 2, child: _QueuePanel(items: vm.queueItems)),
                ],
              )
            else ...[
              DragDropArea(onFilesSelected: _dispatchFiles),
              const SizedBox(height: AppSpacing.md),
              _QueuePanel(items: vm.queueItems),
            ],
            const SizedBox(height: AppSpacing.lg),
            _FiltersPanel(
              searchController: _searchController,
              filters: vm.filters,
              sort: vm.sort,
              viewMode: vm.viewMode,
              lookups: vm.lookups,
              onSearchChanged: (value) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                  store.dispatch(
                    UploadsFiltersChangedAction(
                      vm.filters.copyWith(searchQuery: value),
                    ),
                  );
                });
              },
              onTypeChanged: (value) {
                store.dispatch(
                  UploadsFiltersChangedAction(
                    vm.filters.copyWith(type: value, clearType: value == null),
                  ),
                );
              },
              onMaterialChanged: (value) {
                store.dispatch(
                  UploadsFiltersChangedAction(
                    vm.filters.copyWith(
                      materialId: value,
                      clearMaterial: value == null,
                    ),
                  ),
                );
              },
              onSectionChanged: (value) {
                store.dispatch(
                  UploadsFiltersChangedAction(
                    vm.filters.copyWith(
                      sectionId: value,
                      clearSection: value == null,
                    ),
                  ),
                );
              },
              onYearChanged: (value) {
                store.dispatch(
                  UploadsFiltersChangedAction(
                    vm.filters.copyWith(year: value, clearYear: value == null),
                  ),
                );
              },
              onStatusChanged: (value) {
                store.dispatch(
                  UploadsFiltersChangedAction(
                    vm.filters.copyWith(
                      status: value,
                      clearStatus: value == null,
                    ),
                  ),
                );
              },
              onSortChanged: (sort) =>
                  store.dispatch(UploadsSortChangedAction(sort)),
              onViewModeChanged: (viewMode) =>
                  store.dispatch(UploadsViewModeChangedAction(viewMode)),
            ),
            if (vm.selectedIds.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _BulkActionsBar(
                selectedCount: vm.selectedIds.length,
                onDelete: () => _confirmDelete(vm.selectedIds),
                onAssign: () => _assignUploads(vm.selectedIds),
                onDownload: () {
                  store.dispatch(
                    DownloadUploadsAction(
                      uploadIds: vm.selectedIds,
                      onResolved: _downloadUploads,
                      onError: _showInlineMessage,
                    ),
                  );
                },
                onClear: () =>
                    store.dispatch(const UploadsSelectionClearedAction()),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AnimatedSwitcher(
              duration: AppMotion.medium,
              child: _buildContent(vm, isMobile: isMobile),
            ),
            const SizedBox(height: AppSpacing.md),
            _PaginationBar(
              pagination: vm.pagination,
              onPageChanged: (page) {
                store.dispatch(
                  UploadsPaginationChangedAction(
                    vm.pagination.copyWith(page: page),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStats(_UploadsViewModel vm) {
    final stats = [
      _StatData(
        label: 'Visible uploads',
        value: vm.metrics.totalCount.toString(),
        subtitle: 'Page-ready assets',
        color: AppColors.primary,
        icon: Icons.folder_copy_rounded,
      ),
      _StatData(
        label: 'Uploading now',
        value: vm.metrics.uploadingCount.toString(),
        subtitle: 'Live transfer queue',
        color: AppColors.info,
        icon: Icons.cloud_upload_rounded,
      ),
      _StatData(
        label: 'Needs retry',
        value: vm.metrics.failedCount.toString(),
        subtitle: 'Graceful recovery ready',
        color: AppColors.danger,
        icon: Icons.warning_amber_rounded,
      ),
      _StatData(
        label: 'Storage footprint',
        value: _formatFileSize(vm.metrics.totalStorageBytes),
        subtitle: 'Protected content volume',
        color: AppColors.secondary,
        icon: Icons.sd_storage_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 760
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: columns == 1 ? 2.5 : 1.55,
          ),
          itemBuilder: (context, index) => _StatCard(data: stats[index]),
        );
      },
    );
  }

  Widget _buildContent(_UploadsViewModel vm, {required bool isMobile}) {
    if (vm.status == LoadStatus.loading && vm.items.isEmpty) {
      return const _UploadsSkeleton();
    }

    if (vm.status == LoadStatus.failure && vm.items.isEmpty) {
      return AppCard(
        key: const ValueKey('uploads-error'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 42),
            const SizedBox(height: AppSpacing.md),
            Text(vm.errorMessage ?? 'Unable to load uploads.'),
            const SizedBox(height: AppSpacing.md),
            PremiumButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: () => StoreProvider.of<AppState>(
                context,
              ).dispatch(const FetchUploadsAction()),
            ),
          ],
        ),
      );
    }

    if (vm.items.isEmpty) {
      return AppCard(
        key: const ValueKey('uploads-empty'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 42),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No uploads match the current filters.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Adjust the search, change the filters, or add fresh files to the queue.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (isMobile || vm.viewMode == UploadViewMode.grid) {
      return ListView.separated(
        key: const ValueKey('uploads-grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vm.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = vm.items[index];
          return UploadCard(
            item: item,
            selected: vm.selectedIds.contains(item.id),
            onSelected: (_) => _toggleSelection(item.id),
            onPreview: () => _openPreview(item),
            onDelete: () => _confirmDelete({item.id}),
            onAssign: () => _assignUploads({item.id}),
            onRetry: item.isFailed ? () => _retryUpload(item.id) : null,
            onCancel: item.isUploading ? () => _cancelUpload(item.id) : null,
          );
        },
      );
    }

    return UploadTable(
      key: const ValueKey('uploads-table'),
      items: vm.items,
      selectedIds: vm.selectedIds,
      onToggleSelection: _toggleSelection,
      onToggleAll: (selected) {
        final ids = selected
            ? vm.items.map((item) => item.id).toSet()
            : <String>{};
        StoreProvider.of<AppState>(
          context,
        ).dispatch(UploadsSelectionChangedAction(ids));
      },
      onPreview: _openPreview,
      onDelete: (item) => _confirmDelete({item.id}),
      onAssign: (item) => _assignUploads({item.id}),
      onRetry: (item) => _retryUpload(item.id),
      onCancel: (item) => _cancelUpload(item.id),
    );
  }

  Future<void> _pickFiles(Store<AppState> store) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb,
      lockParentWindow: true,
    );
    if (result == null) return;
    final files = result.files
        .map(
          (file) => UploadLocalFile(
            localId:
                'local-${DateTime.now().microsecondsSinceEpoch}-${file.name.hashCode}',
            name: file.name,
            sizeBytes: file.size,
            mimeType: _mimeTypeFor(file.name),
            path: file.path,
            bytes: file.bytes,
          ),
        )
        .toList(growable: false);
    store.dispatch(UploadFilesAction(files: files));
  }

  void _dispatchFiles(List<UploadLocalFile> files) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(UploadFilesAction(files: files));
  }

  void _toggleSelection(String uploadId) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(UploadsSelectionToggledAction(uploadId));
  }

  void _retryUpload(String uploadId) {
    StoreProvider.of<AppState>(context).dispatch(RetryUploadAction(uploadId));
  }

  void _cancelUpload(String uploadId) {
    StoreProvider.of<AppState>(context).dispatch(CancelUploadAction(uploadId));
  }

  void _openPreview(UploadItem item) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          UploadPreviewScreen(uploadId: item.id, uploadName: item.name),
    );
  }

  Future<void> _confirmDelete(Set<String> ids) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete upload${ids.length == 1 ? '' : 's'}?',
      message:
          'This removes ${ids.length == 1 ? 'the selected file' : '${ids.length} selected files'} from the uploads workspace.',
    );
    if (!mounted) return;
    if (!confirmed) return;
    StoreProvider.of<AppState>(context).dispatch(DeleteUploadsAction(ids));
  }

  Future<void> _assignUploads(Set<String> ids) async {
    final store = StoreProvider.of<AppState>(context);
    final lookups = store.state.uploadsState.lookups;
    final payload = await showModalBottomSheet<UploadAssignmentPayload>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          _AssignmentSheet(lookups: lookups, selectedCount: ids.length),
    );
    if (!mounted) return;
    if (payload == null) return;
    store.dispatch(AssignUploadsAction(uploadIds: ids, payload: payload));
  }

  Future<void> _downloadUploads(List<UploadItem> items) async {
    for (final item in items) {
      final url = item.downloadUrl ?? item.previewUrl;
      if (url == null) continue;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showInlineMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _UploadsViewModel {
  const _UploadsViewModel({
    required this.status,
    required this.items,
    required this.queueItems,
    required this.metrics,
    required this.filters,
    required this.sort,
    required this.pagination,
    required this.lookups,
    required this.selectedIds,
    required this.viewMode,
    required this.isOffline,
    required this.errorMessage,
    required this.feedbackMessage,
  });

  final LoadStatus status;
  final List<UploadItem> items;
  final List<UploadItem> queueItems;
  final UploadMetrics metrics;
  final UploadListFilters filters;
  final UploadListSort sort;
  final UploadPagination pagination;
  final UploadLookups lookups;
  final Set<String> selectedIds;
  final UploadViewMode viewMode;
  final bool isOffline;
  final String? errorMessage;
  final String? feedbackMessage;

  factory _UploadsViewModel.fromStore(Store<AppState> store) {
    final state = store.state.uploadsState;
    final items = selectUploads(store.state);
    return _UploadsViewModel(
      status: state.status,
      items: items,
      queueItems: items
          .where((item) => item.isUploading || item.isFailed)
          .toList(growable: false),
      metrics: selectUploadMetrics(store.state),
      filters: state.filters,
      sort: state.sort,
      pagination: state.pagination,
      lookups: state.lookups,
      selectedIds: state.selectedIds,
      viewMode: state.viewMode,
      isOffline: state.isOffline,
      errorMessage: state.errorMessage,
      feedbackMessage: state.feedbackMessage,
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.searchController,
    required this.filters,
    required this.sort,
    required this.viewMode,
    required this.lookups,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onMaterialChanged,
    required this.onSectionChanged,
    required this.onYearChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onViewModeChanged,
  });

  final TextEditingController searchController;
  final UploadListFilters filters;
  final UploadListSort sort;
  final UploadViewMode viewMode;
  final UploadLookups lookups;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UploadFileType?> onTypeChanged;
  final ValueChanged<String?> onMaterialChanged;
  final ValueChanged<String?> onSectionChanged;
  final ValueChanged<String?> onYearChanged;
  final ValueChanged<UploadStatus?> onStatusChanged;
  final ValueChanged<UploadListSort> onSortChanged;
  final ValueChanged<UploadViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, material, section, or uploader',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SegmentedButton<UploadViewMode>(
                segments: const [
                  ButtonSegment(
                    value: UploadViewMode.table,
                    label: Text('Table'),
                    icon: Icon(Icons.table_rows_rounded),
                  ),
                  ButtonSegment(
                    value: UploadViewMode.grid,
                    label: Text('Grid'),
                    icon: Icon(Icons.grid_view_rounded),
                  ),
                ],
                selected: {viewMode},
                onSelectionChanged: (value) => onViewModeChanged(value.first),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _DropdownBox<UploadFileType?>(
                label: 'Type',
                value: filters.type,
                width: 180,
                items: [
                  const DropdownMenuItem<UploadFileType?>(
                    value: null,
                    child: Text('All types'),
                  ),
                  ...UploadFileType.values.map(
                    (type) => DropdownMenuItem<UploadFileType?>(
                      value: type,
                      child: Text(type.label),
                    ),
                  ),
                ],
                onChanged: onTypeChanged,
              ),
              _DropdownBox<String?>(
                label: 'Material',
                value: filters.materialId,
                width: 200,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All materials'),
                  ),
                  ...lookups.materials.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.id,
                      child: Text(item.label),
                    ),
                  ),
                ],
                onChanged: onMaterialChanged,
              ),
              _DropdownBox<String?>(
                label: 'Section',
                value: filters.sectionId,
                width: 170,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All sections'),
                  ),
                  ...lookups.sections.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.id,
                      child: Text(item.label),
                    ),
                  ),
                ],
                onChanged: onSectionChanged,
              ),
              _DropdownBox<String?>(
                label: 'Year',
                value: filters.year,
                width: 150,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All years'),
                  ),
                  ...lookups.years.map(
                    (item) => DropdownMenuItem<String?>(
                      value: item,
                      child: Text(item),
                    ),
                  ),
                ],
                onChanged: onYearChanged,
              ),
              _DropdownBox<UploadStatus?>(
                label: 'Status',
                value: filters.status,
                width: 160,
                items: [
                  const DropdownMenuItem<UploadStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...UploadStatus.values.map(
                    (status) => DropdownMenuItem<UploadStatus?>(
                      value: status,
                      child: Text(status.label),
                    ),
                  ),
                ],
                onChanged: onStatusChanged,
              ),
              _DropdownBox<UploadSortField>(
                label: 'Sort',
                value: sort.field,
                width: 170,
                items: UploadSortField.values
                    .map(
                      (field) => DropdownMenuItem<UploadSortField>(
                        value: field,
                        child: Text(_sortLabel(field)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (field) {
                  if (field == null) return;
                  onSortChanged(sort.copyWith(field: field));
                },
              ),
              PremiumButton(
                label: sort.ascending ? 'Ascending' : 'Descending',
                icon: sort.ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                isSecondary: true,
                onPressed: () =>
                    onSortChanged(sort.copyWith(ascending: !sort.ascending)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  const _DropdownBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.width,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _BulkActionsBar extends StatelessWidget {
  const _BulkActionsBar({
    required this.selectedCount,
    required this.onDelete,
    required this.onAssign,
    required this.onDownload,
    required this.onClear,
  });

  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onAssign;
  final VoidCallback onDownload;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$selectedCount upload${selectedCount == 1 ? '' : 's'} selected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              PremiumButton(
                label: 'Assign',
                icon: Icons.rule_folder_rounded,
                isSecondary: true,
                onPressed: onAssign,
              ),
              PremiumButton(
                label: 'Download',
                icon: Icons.download_rounded,
                isSecondary: true,
                onPressed: onDownload,
              ),
              PremiumButton(
                label: 'Delete',
                icon: Icons.delete_outline_rounded,
                isSecondary: true,
                isDestructive: true,
                onPressed: onDelete,
              ),
              PremiumButton(
                label: 'Clear',
                icon: Icons.close_rounded,
                isSecondary: true,
                onPressed: onClear,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QueuePanel extends StatelessWidget {
  const _QueuePanel({required this.items});

  final List<UploadItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Queue', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Uploading and failed jobs stay visible for quick retry and cancellation.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Queue is clear',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (final item in items) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${item.assignment.materialLabel} | ${DateFormat('dd MMM, HH:mm').format(item.uploadedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 160,
                        child: UploadsProgressIndicator(
                          progress: item.progress,
                          status: item.status,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                  if (item != items.last) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.pagination, required this.onPageChanged});

  final UploadPagination pagination;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Page ${pagination.page} of ${pagination.totalPages} | ${pagination.totalItems} total uploads',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          onPressed: pagination.page <= 1
              ? null
              : () => onPageChanged(pagination.page - 1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          onPressed: pagination.page >= pagination.totalPages
              ? null
              : () => onPageChanged(pagination.page + 1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _UploadsSkeleton extends StatelessWidget {
  const _UploadsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 18, width: 220, color: Colors.white),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 14,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(height: 14, width: 180, color: Colors.white),
              const SizedBox(height: AppSpacing.lg),
              Container(height: 8, width: double.infinity, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.warningSoft.withValues(alpha: 0.72),
      borderColor: AppColors.warning.withValues(alpha: 0.28),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Offline mode is active. Upload history stays available, but new transfers may fail until connectivity returns.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      interactive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Icon(data.icon, color: data.color),
              ),
              const Spacer(),
              StatusBadge(data.label),
            ],
          ),
          const Spacer(),
          Text(data.value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AssignmentSheet extends StatefulWidget {
  const _AssignmentSheet({required this.lookups, required this.selectedCount});

  final UploadLookups lookups;
  final int selectedCount;

  @override
  State<_AssignmentSheet> createState() => _AssignmentSheetState();
}

class _AssignmentSheetState extends State<_AssignmentSheet> {
  String? _courseId;
  String? _sectionId;
  String? _subjectId;
  String? _year;
  UploadAccessLevel _accessLevel = UploadAccessLevel.students;
  bool _canDownload = true;
  bool _allowPublicLink = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assign uploads',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Apply material, section, year, and access rules to ${widget.selectedCount} selected upload${widget.selectedCount == 1 ? '' : 's'}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _BottomSheetDropdown<String?>(
              label: 'Course',
              value: _courseId,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Optional'),
                ),
                ...widget.lookups.courses.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text(item.label),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _courseId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            _BottomSheetDropdown<String?>(
              label: 'Section',
              value: _sectionId,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Optional'),
                ),
                ...widget.lookups.sections.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text(item.label),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _sectionId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            _BottomSheetDropdown<String?>(
              label: 'Subject / Material',
              value: _subjectId,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Optional'),
                ),
                ...widget.lookups.subjects.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text(item.label),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _subjectId = value),
            ),
            const SizedBox(height: AppSpacing.md),
            _BottomSheetDropdown<String?>(
              label: 'Academic year',
              value: _year,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Optional'),
                ),
                ...widget.lookups.years.map(
                  (item) =>
                      DropdownMenuItem<String?>(value: item, child: Text(item)),
                ),
              ],
              onChanged: (value) => setState(() => _year = value),
            ),
            const SizedBox(height: AppSpacing.md),
            _BottomSheetDropdown<UploadAccessLevel>(
              label: 'Access level',
              value: _accessLevel,
              items: UploadAccessLevel.values
                  .map(
                    (item) => DropdownMenuItem<UploadAccessLevel>(
                      value: item,
                      child: Text(item.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(
                () => _accessLevel = value ?? UploadAccessLevel.students,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile.adaptive(
              value: _canDownload,
              onChanged: (value) => setState(() => _canDownload = value),
              title: const Text('Allow download'),
            ),
            SwitchListTile.adaptive(
              value: _allowPublicLink,
              onChanged: (value) => setState(() => _allowPublicLink = value),
              title: const Text('Allow secure public link'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: PremiumButton(
                    label: 'Cancel',
                    icon: Icons.close_rounded,
                    isSecondary: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PremiumButton(
                    label: 'Apply Assignment',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      Navigator.of(context).pop(
                        UploadAssignmentPayload(
                          courseId: _courseId,
                          sectionId: _sectionId,
                          subjectId: _subjectId,
                          academicYear: _year,
                          accessControl: UploadAccessControl(
                            level: _accessLevel,
                            canDownload: _canDownload,
                            allowPublicLink: _allowPublicLink,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetDropdown<T> extends StatelessWidget {
  const _BottomSheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

String _formatFileSize(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}

String _sortLabel(UploadSortField field) => switch (field) {
  UploadSortField.name => 'Name',
  UploadSortField.type => 'Type',
  UploadSortField.size => 'Size',
  UploadSortField.material => 'Material',
  UploadSortField.uploadedAt => 'Date',
  UploadSortField.status => 'Status',
};

String _mimeTypeFor(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.mp4')) return 'video/mp4';
  if (lower.endsWith('.mov')) return 'video/quicktime';
  if (lower.endsWith('.xlsx')) {
    return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  }
  if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
  if (lower.endsWith('.csv')) return 'text/csv';
  if (lower.endsWith('.zip')) return 'application/zip';
  if (lower.endsWith('.docx')) {
    return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  }
  return 'application/octet-stream';
}
