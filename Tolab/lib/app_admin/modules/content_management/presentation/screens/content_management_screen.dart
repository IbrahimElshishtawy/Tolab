import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/content_models.dart';
import '../../state/content_actions.dart';
import '../../state/content_selectors.dart';
import '../widgets/admin_form.dart';
import '../widgets/admin_table.dart';
import '../widgets/content_responsive_layout.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/upload_widget.dart';
import '../widgets/content_sections/content_metrics_strip.dart';
import '../widgets/content_sections/content_quick_actions.dart';
import '../widgets/content_sections/content_details_panel.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ContentViewModel>(
      onInit: (store) => store.dispatch(const LoadContentRequestedAction()),
      converter: (store) => ContentViewModel.fromStore(store),
      distinct: true,
      onDidChange: (previous, current) {
        if (_searchController.text != current.filters.searchQuery) {
          _searchController.value = TextEditingValue(
            text: current.filters.searchQuery,
            selection: TextSelection.collapsed(
              offset: current.filters.searchQuery.length,
            ),
          );
        }
        if (previous?.mutationMessage != current.mutationMessage &&
            current.mutationMessage != null &&
            mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(current.mutationMessage!)));
          StoreProvider.of<AppState>(
            context,
          ).dispatch(const ResetContentMutationMessageAction());
        }
      },
      builder: (context, vm) {
        if (vm.status == LoadStatus.loading && vm.items.isEmpty) {
          return const LoadingSkeleton();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Content Management',
              subtitle:
                  'Enterprise workspace for lectures, sections, summaries, assessments, uploads, scheduling, publishing, grading, and submission oversight.',
              breadcrumbs: const ['Admin', 'Academic', 'Content'],
              actions: [
                PremiumButton(
                  label: 'New content',
                  icon: Icons.add_rounded,
                  onPressed: vm.canCreate
                      ? () => _openEditor(context, vm, null)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.entrance,
                child: vm.status == LoadStatus.failure
                    ? EmptyState(
                        title: 'Content failed to load',
                        subtitle: vm.errorMessage ?? 'Please try again.',
                        icon: Icons.error_outline_rounded,
                        action: PremiumButton(
                          label: 'Retry',
                          icon: Icons.refresh_rounded,
                          onPressed: () => StoreProvider.of<AppState>(
                            context,
                          ).dispatch(const LoadContentRequestedAction()),
                        ),
                      )
                    : ListView(
                        key: ValueKey(vm.items.length),
                        children: [
                          ContentMetricsStrip(metrics: vm.metrics),
                          const SizedBox(height: AppSpacing.lg),
                          ContentQuickActionsRow(
                            onCreate: vm.canCreate
                                ? () => _openEditor(context, vm, null)
                                : null,
                            onPublishSelected: vm.selectedIds.isEmpty
                                ? null
                                : () => StoreProvider.of<AppState>(context)
                                      .dispatch(
                                        PublishContentRequestedAction(
                                          vm.selectedIds,
                                        ),
                                      ),
                            onArchiveSelected: vm.selectedIds.isEmpty
                                ? null
                                : () => StoreProvider.of<AppState>(context)
                                      .dispatch(
                                        ArchiveContentRequestedAction(
                                          vm.selectedIds,
                                        ),
                                      ),
                            onDeleteSelected: vm.selectedIds.isEmpty
                                ? null
                                : () => StoreProvider.of<AppState>(context)
                                      .dispatch(
                                        DeleteContentRequestedAction(
                                          vm.selectedIds,
                                        ),
                                      ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilterBar(
                            searchController: _searchController,
                            filters: vm.filters,
                            subjects: vm.subjects,
                            instructors: vm.instructors,
                            onSearchChanged: (value) => _updateFilters(
                              context,
                              vm.filters.copyWith(searchQuery: value),
                            ),
                            onTypeChanged: (value) => _updateFilters(
                              context,
                              value == null
                                  ? vm.filters.copyWith(clearType: true)
                                  : vm.filters.copyWith(type: value),
                            ),
                            onSubjectChanged: (value) => _updateFilters(
                              context,
                              value == null
                                  ? vm.filters.copyWith(clearSubjectId: true)
                                  : vm.filters.copyWith(subjectId: value),
                            ),
                            onInstructorChanged: (value) => _updateFilters(
                              context,
                              value == null
                                  ? vm.filters.copyWith(clearInstructorId: true)
                                  : vm.filters.copyWith(instructorId: value),
                            ),
                            onStatusChanged: (value) => _updateFilters(
                              context,
                              value == null
                                  ? vm.filters.copyWith(clearStatus: true)
                                  : vm.filters.copyWith(status: value),
                            ),
                            onClear: () {
                              _searchController.clear();
                              _updateFilters(context, const ContentFilters());
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (vm.filteredItems.isEmpty)
                            EmptyState(
                              title: 'No content matches these filters',
                              subtitle:
                                  'Adjust type, subject, instructor, or status to restore the content grid.',
                              icon: Icons.inbox_outlined,
                              action: PremiumButton(
                                label: 'Clear filters',
                                icon: Icons.refresh_rounded,
                                isSecondary: true,
                                onPressed: () {
                                  _searchController.clear();
                                  _updateFilters(
                                    context,
                                    const ContentFilters(),
                                  );
                                },
                              ),
                            )
                          else
                            ContentResponsiveLayout(
                              primary: AdminTable(
                                items: vm.visibleItems,
                                selectedIds: vm.selectedIds,
                                areAllSelected: vm.areAllVisibleSelected,
                                sort: vm.sort,
                                currentPage: vm.pagination.page,
                                totalPages: vm.totalPages,
                                onRowSelected: (id, selected) =>
                                    StoreProvider.of<AppState>(
                                      context,
                                    ).dispatch(
                                      ContentSelectionToggledAction(
                                        contentId: id,
                                        selected: selected,
                                      ),
                                    ),
                                onSelectAll: (selected) =>
                                    StoreProvider.of<AppState>(
                                      context,
                                    ).dispatch(
                                      ContentVisibleSelectionChangedAction(
                                        visibleIds: vm.visibleItems
                                            .map((item) => item.id)
                                            .toSet(),
                                        selected: selected,
                                      ),
                                    ),
                                onSortChanged: (field) =>
                                    StoreProvider.of<AppState>(
                                      context,
                                    ).dispatch(
                                      ContentSortChangedAction(
                                        vm.sort.copyWith(
                                          field: field,
                                          ascending: vm.sort.field == field
                                              ? !vm.sort.ascending
                                              : true,
                                        ),
                                      ),
                                    ),
                                onPageChanged: (page) =>
                                    StoreProvider.of<AppState>(
                                      context,
                                    ).dispatch(
                                      ContentPaginationChangedAction(
                                        vm.pagination.copyWith(page: page),
                                      ),
                                    ),
                                onView: (item) => StoreProvider.of<AppState>(
                                  context,
                                ).dispatch(SelectContentAction(item.id)),
                                onEdit: (item) =>
                                    _openEditor(context, vm, item),
                                onDelete: (item) =>
                                    StoreProvider.of<AppState>(
                                      context,
                                    ).dispatch(
                                      DeleteContentRequestedAction({item.id}),
                                    ),
                              ),
                              secondary: ContentDetailsPanel(
                                vm: vm,
                                onEdit: _openEditor,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateFilters(BuildContext context, ContentFilters filters) {
    StoreProvider.of<AppState>(
      context,
    ).dispatch(ContentFiltersChangedAction(filters));
  }

  Future<void> _openEditor(
    BuildContext context,
    ContentViewModel vm,
    ContentRecord? record,
  ) async {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(
      PrepareContentDraftAction(attachments: record?.attachments ?? const []),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: AppBreakpoints.isMobile(context) ? 0.96 : 0.92,
          child: _ContentEditorSheet(record: record, vm: vm),
        );
      },
    );

    if (context.mounted) {
      store.dispatch(const ClearContentDraftAction());
    }
  }
}

class ContentViewModel {
  const ContentViewModel({
    required this.status,
    required this.items,
    required this.filteredItems,
    required this.visibleItems,
    required this.metrics,
    required this.recentActivity,
    required this.subjects,
    required this.sections,
    required this.instructors,
    required this.filters,
    required this.sort,
    required this.pagination,
    required this.totalPages,
    required this.selectedIds,
    required this.areAllVisibleSelected,
    required this.activeContent,
    required this.activeDetailsTab,
    required this.draftAttachments,
    required this.uploadTasks,
    required this.hasPendingUploads,
    required this.canCreate,
    this.errorMessage,
    this.mutationMessage,
  });

  final LoadStatus status;
  final List<ContentRecord> items;
  final List<ContentRecord> filteredItems;
  final List<ContentRecord> visibleItems;
  final ContentDashboardMetrics metrics;
  final List<ContentActivityItem> recentActivity;
  final List<ContentSubjectOption> subjects;
  final List<ContentSectionOption> sections;
  final List<ContentInstructorOption> instructors;
  final ContentFilters filters;
  final ContentSort sort;
  final ContentPagination pagination;
  final int totalPages;
  final Set<String> selectedIds;
  final bool areAllVisibleSelected;
  final ContentRecord? activeContent;
  final ContentDetailsTab activeDetailsTab;
  final List<ContentAttachment> draftAttachments;
  final List<ContentUploadTask> uploadTasks;
  final bool hasPendingUploads;
  final bool canCreate;
  final String? errorMessage;
  final String? mutationMessage;

  factory ContentViewModel.fromStore(Store<AppState> store) {
    final state = store.state.contentState;
    final activeContent = selectActiveContent(state);
    return ContentViewModel(
      status: state.status,
      items: selectAllContent(state),
      filteredItems: selectFilteredContent(state),
      visibleItems: selectVisibleContent(state),
      metrics: selectDashboardMetrics(state),
      recentActivity: selectRecentActivity(state),
      subjects: state.subjects,
      sections: state.sections,
      instructors: state.instructors,
      filters: state.filters,
      sort: state.sort,
      pagination: state.pagination,
      totalPages: selectTotalPages(state),
      selectedIds: state.selectedIds,
      areAllVisibleSelected: selectAreAllVisibleSelected(state),
      activeContent: activeContent,
      activeDetailsTab: state.activeDetailsTab,
      draftAttachments: state.draftAttachments,
      uploadTasks: selectUploadTasks(state),
      hasPendingUploads: selectHasPendingUploads(state),
      canCreate: activeContent?.permissions.canCreate ?? true,
      errorMessage: state.errorMessage,
      mutationMessage: state.mutationMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ContentViewModel &&
        other.status == status &&
        listEquals(other.items, items) &&
        listEquals(other.filteredItems, filteredItems) &&
        listEquals(other.visibleItems, visibleItems) &&
        other.metrics.totalContent == metrics.totalContent &&
        other.metrics.totalAssessments == metrics.totalAssessments &&
        other.metrics.pendingSubmissions == metrics.pendingSubmissions &&
        other.metrics.averageEngagementRate == metrics.averageEngagementRate &&
        listEquals(other.recentActivity, recentActivity) &&
        listEquals(other.subjects, subjects) &&
        listEquals(other.sections, sections) &&
        listEquals(other.instructors, instructors) &&
        other.filters == filters &&
        other.sort.field == sort.field &&
        other.sort.ascending == sort.ascending &&
        other.pagination.page == pagination.page &&
        other.pagination.perPage == pagination.perPage &&
        other.totalPages == totalPages &&
        setEquals(other.selectedIds, selectedIds) &&
        other.areAllVisibleSelected == areAllVisibleSelected &&
        other.activeContent?.id == activeContent?.id &&
        other.activeDetailsTab == activeDetailsTab &&
        listEquals(other.draftAttachments, draftAttachments) &&
        listEquals(other.uploadTasks, uploadTasks) &&
        other.hasPendingUploads == hasPendingUploads &&
        other.canCreate == canCreate &&
        other.errorMessage == errorMessage &&
        other.mutationMessage == mutationMessage;
  }

  @override
  int get hashCode => Object.hashAll([
    status,
    items.length,
    filteredItems.length,
    visibleItems.length,
    metrics.totalContent,
    metrics.totalAssessments,
    metrics.pendingSubmissions,
    metrics.averageEngagementRate,
    recentActivity.length,
    subjects.length,
    sections.length,
    instructors.length,
    filters,
    sort.field,
    sort.ascending,
    pagination.page,
    pagination.perPage,
    totalPages,
    selectedIds.length,
    areAllVisibleSelected,
    activeContent?.id,
    activeDetailsTab,
    draftAttachments.length,
    uploadTasks.length,
    hasPendingUploads,
    canCreate,
    errorMessage,
    mutationMessage,
  ]);
}

class _ContentEditorSheet extends StatefulWidget {
  const _ContentEditorSheet({required this.record, required this.vm});

  final ContentRecord? record;
  final ContentViewModel vm;

  @override
  State<_ContentEditorSheet> createState() => _ContentEditorSheetState();
}

class _ContentEditorSheetState extends State<_ContentEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late ContentType _type;
  late String _subjectId;
  late String _sectionId;
  late String _instructorId;
  late ContentVisibility _visibility;
  late ContentStatus _status;
  late DateTime? _publishAt;
  late DateTime? _dueAt;
  late AssessmentMode _assessmentMode;
  late final TextEditingController _questionCountController;
  late final TextEditingController _durationController;
  late final TextEditingController _attemptsController;
  bool _allowLateSubmission = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    final fallbackSubject = widget.vm.subjects.first;
    final fallbackSection =
        widget.vm.sections.firstWhereOrNull(
          (item) =>
              item.subjectId == (record?.subject.id ?? fallbackSubject.id),
        ) ??
        widget.vm.sections.first;
    final fallbackInstructor = widget.vm.instructors.first;

    _titleController = TextEditingController(text: record?.title ?? '');
    _descriptionController = TextEditingController(
      text: record?.description ?? '',
    );
    _type = record?.type ?? ContentType.lecture;
    _subjectId = record?.subject.id ?? fallbackSubject.id;
    _sectionId = record?.section.id ?? fallbackSection.id;
    _instructorId = record?.instructor.id ?? fallbackInstructor.id;
    _visibility = record?.visibility ?? ContentVisibility.enrolledOnly;
    _status = record?.status ?? ContentStatus.draft;
    _publishAt = record?.publishAt;
    _dueAt = record?.dueAt;
    _assessmentMode = record?.assessmentSettings?.mode ?? AssessmentMode.mcq;
    _questionCountController = TextEditingController(
      text: '${record?.assessmentSettings?.questionCount ?? 10}',
    );
    _durationController = TextEditingController(
      text: '${record?.assessmentSettings?.durationMinutes ?? 30}',
    );
    _attemptsController = TextEditingController(
      text: '${record?.assessmentSettings?.attemptsAllowed ?? 1}',
    );
    _allowLateSubmission =
        record?.assessmentSettings?.allowLateSubmission ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _questionCountController.dispose();
    _durationController.dispose();
    _attemptsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.record == null ? 'Create content' : 'Edit content',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () {
                            final navigator = Navigator.of(context);
                            if (navigator.canPop()) {
                              navigator.pop();
                            }
                          },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: StoreConnector<AppState, _EditorDraftVm>(
                  converter: (store) => _EditorDraftVm.fromStore(store),
                  distinct: true,
                  builder: (context, draftVm) {
                    final filteredSections = widget.vm.sections
                        .where((item) => item.subjectId == _subjectId)
                        .toList(growable: false);
                    if (!filteredSections.any(
                          (item) => item.id == _sectionId,
                        ) &&
                        filteredSections.isNotEmpty) {
                      _sectionId = filteredSections.first.id;
                    }
                    return ListView(
                      children: [
                        AdminForm(
                          title: 'Content basics',
                          subtitle:
                              'Define the content type, ownership, scheduling, and publishing surface.',
                          child: Column(
                            children: [
                              TextField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  hintText:
                                      'Advanced lecture topic or assessment title',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _MarkdownToolbar(
                                controller: _descriptionController,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              TextField(
                                controller: _descriptionController,
                                maxLines: 7,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  hintText:
                                      'Rich text-friendly description using markdown formatting.',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.md,
                                runSpacing: AppSpacing.md,
                                children: [
                                  _SelectField<ContentType>(
                                    label: 'Type',
                                    value: _type,
                                    items: ContentType.values,
                                    labelBuilder: (item) => item.label,
                                    onChanged: (value) =>
                                        setState(() => _type = value),
                                  ),
                                  _SelectField<String>(
                                    label: 'Subject',
                                    value: _subjectId,
                                    items: widget.vm.subjects
                                        .map((item) => item.id)
                                        .toList(),
                                    labelBuilder: (id) => widget.vm.subjects
                                        .firstWhere((item) => item.id == id)
                                        .displayLabel,
                                    onChanged: (value) => setState(() {
                                      _subjectId = value;
                                      final nextSection =
                                          filteredSections.firstOrNull;
                                      if (nextSection != null) {
                                        _sectionId = nextSection.id;
                                      }
                                    }),
                                  ),
                                  _SelectField<String>(
                                    label: 'Section',
                                    value: _sectionId,
                                    items: filteredSections
                                        .map((item) => item.id)
                                        .toList(),
                                    labelBuilder: (id) => filteredSections
                                        .firstWhere((item) => item.id == id)
                                        .title,
                                    onChanged: (value) =>
                                        setState(() => _sectionId = value),
                                  ),
                                  _SelectField<String>(
                                    label: 'Instructor',
                                    value: _instructorId,
                                    items: widget.vm.instructors
                                        .map((item) => item.id)
                                        .toList(),
                                    labelBuilder: (id) => widget.vm.instructors
                                        .firstWhere((item) => item.id == id)
                                        .name,
                                    onChanged: (value) =>
                                        setState(() => _instructorId = value),
                                  ),
                                  _SelectField<ContentVisibility>(
                                    label: 'Visibility',
                                    value: _visibility,
                                    items: ContentVisibility.values,
                                    labelBuilder: (item) => item.label,
                                    onChanged: (value) =>
                                        setState(() => _visibility = value),
                                  ),
                                  _SelectField<ContentStatus>(
                                    label: 'Status',
                                    value: _status,
                                    items: ContentStatus.values,
                                    labelBuilder: (item) => item.label,
                                    onChanged: (value) =>
                                        setState(() => _status = value),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.md,
                                runSpacing: AppSpacing.md,
                                children: [
                                  _DateField(
                                    label: 'Publish date',
                                    value: _publishAt,
                                    onChanged: (value) =>
                                        setState(() => _publishAt = value),
                                  ),
                                  _DateField(
                                    label: 'Due date',
                                    value: _dueAt,
                                    onChanged: (value) =>
                                        setState(() => _dueAt = value),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (_type == ContentType.quiz ||
                            _type == ContentType.task ||
                            _type == ContentType.exam)
                          AdminForm(
                            title: 'Assessment settings',
                            subtitle:
                                'Configure grading mode, attempt rules, and timing behavior.',
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.md,
                                  children: [
                                    _SelectField<AssessmentMode>(
                                      label: 'Mode',
                                      value: _assessmentMode,
                                      items: _allowedModesForType(_type),
                                      labelBuilder: (item) => item.label,
                                      onChanged: (value) => setState(
                                        () => _assessmentMode = value,
                                      ),
                                    ),
                                    _SmallField(
                                      label: 'Questions',
                                      controller: _questionCountController,
                                    ),
                                    _SmallField(
                                      label: 'Minutes',
                                      controller: _durationController,
                                    ),
                                    _SmallField(
                                      label: 'Attempts',
                                      controller: _attemptsController,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  value: _allowLateSubmission,
                                  title: const Text('Allow late submission'),
                                  subtitle: const Text(
                                    'Keep the due date visible while accepting late work.',
                                  ),
                                  onChanged: _type == ContentType.exam
                                      ? null
                                      : (value) => setState(
                                          () => _allowLateSubmission = value,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        if (_type == ContentType.quiz ||
                            _type == ContentType.task ||
                            _type == ContentType.exam)
                          const SizedBox(height: AppSpacing.lg),
                        AdminForm(
                          title: 'Attachments',
                          subtitle:
                              'Upload lecture packs, briefs, references, and submission templates.',
                          child: UploadWidget(
                            attachments: draftVm.attachments,
                            tasks: draftVm.uploadTasks,
                            onFilesSelected: (files) =>
                                StoreProvider.of<AppState>(context).dispatch(
                                  UploadDraftFilesRequestedAction(files),
                                ),
                            onRetry: (taskId) => StoreProvider.of<AppState>(
                              context,
                            ).dispatch(RetryDraftUploadRequestedAction(taskId)),
                            onRemoveAttachment: (attachmentId) =>
                                StoreProvider.of<AppState>(context).dispatch(
                                  RemoveDraftAttachmentAction(attachmentId),
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      label: 'Cancel',
                      icon: Icons.close_rounded,
                      isSecondary: true,
                      onPressed: _submitting
                          ? null
                          : () {
                              final navigator = Navigator.of(context);
                              if (navigator.canPop()) {
                                navigator.pop();
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: PremiumButton(
                      label: widget.record == null
                          ? 'Create content'
                          : 'Save changes',
                      icon: Icons.check_rounded,
                      onPressed: _submitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<AssessmentMode> _allowedModesForType(ContentType type) {
    return switch (type) {
      ContentType.quiz => [AssessmentMode.mcq, AssessmentMode.trueFalse],
      ContentType.task => [AssessmentMode.fileSubmission],
      ContentType.exam => [AssessmentMode.timedExam],
      _ => [AssessmentMode.mcq],
    };
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required.')),
      );
      return;
    }
    if (widget.vm.hasPendingUploads) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wait for uploads to finish before saving.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final store = StoreProvider.of<AppState>(context);
    final state = store.state.contentState;
    final subject = widget.vm.subjects.firstWhere(
      (item) => item.id == _subjectId,
    );
    final payload = ContentUpsertPayload(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      subjectId: _subjectId,
      sectionId: _sectionId,
      instructorId: _instructorId,
      courseOfferingId: subject.courseOfferingId,
      visibility: _visibility,
      status: _status,
      publishAt: _publishAt,
      dueAt: _dueAt,
      assessmentSettings:
          _type == ContentType.quiz ||
              _type == ContentType.task ||
              _type == ContentType.exam
          ? ContentAssessmentSettings(
              mode: _assessmentMode,
              questionCount: int.tryParse(_questionCountController.text) ?? 10,
              durationMinutes: int.tryParse(_durationController.text) ?? 30,
              attemptsAllowed: int.tryParse(_attemptsController.text) ?? 1,
              allowLateSubmission: _allowLateSubmission,
            )
          : null,
    );

    final uploads = state.uploadTasks.values
        .where((task) => task.isCompleted)
        .toList(growable: false);
    final action = widget.record == null
        ? CreateContentRequestedAction(
            payload: payload,
            attachments: state.draftAttachments,
            uploadTasks: uploads,
          )
        : UpdateContentRequestedAction(
            contentId: widget.record!.id,
            payload: payload,
            attachments: state.draftAttachments,
            uploadTasks: uploads,
          );
    store.dispatch(action);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
      });
    }
  }
}

class _EditorDraftVm {
  const _EditorDraftVm({required this.attachments, required this.uploadTasks});

  final List<ContentAttachment> attachments;
  final List<ContentUploadTask> uploadTasks;

  factory _EditorDraftVm.fromStore(Store<AppState> store) {
    final state = store.state.contentState;
    return _EditorDraftVm(
      attachments: state.draftAttachments,
      uploadTasks: selectUploadTasks(state),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _EditorDraftVm &&
        listEquals(other.attachments, attachments) &&
        listEquals(other.uploadTasks, uploadTasks);
  }

  @override
  int get hashCode => Object.hash(attachments.length, uploadTasks.length);
}

class _SelectField<T> extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: value == null
              ? ''
              : '${value!.day}/${value!.month}/${value!.year} ${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}',
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                IconButton(
                  onPressed: () => onChanged(null),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              IconButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    initialDate: value ?? DateTime.now(),
                  );
                  if (date == null || !context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      value ?? DateTime.now(),
                    ),
                  );
                  if (time == null) return;
                  onChanged(
                    DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  const _SmallField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _MarkdownToolbar extends StatelessWidget {
  const _MarkdownToolbar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _ToolbarButton(
          icon: Icons.format_bold_rounded,
          onPressed: () => _insert('**bold text**'),
        ),
        _ToolbarButton(
          icon: Icons.format_list_bulleted_rounded,
          onPressed: () => _insert('\n- bullet point'),
        ),
        _ToolbarButton(
          icon: Icons.format_quote_rounded,
          onPressed: () => _insert('\n> highlighted note'),
        ),
      ],
    );
  }

  void _insert(String value) {
    final selection = controller.selection;
    final start = selection.start < 0
        ? controller.text.length
        : selection.start;
    final end = selection.end < 0 ? controller.text.length : selection.end;
    final text = controller.text;
    final nextText = text.replaceRange(start, end, value);
    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: start + value.length),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
