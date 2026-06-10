import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/models/notification_models.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import 'package:tolab_fci/app/localization/app_localizations.dart';
import '../../models/student_management_models.dart';
import '../../state/students_state.dart';
import '../../widgets/student_module_primitives.dart';
import '../helpers/student_file_saver.dart';
import '../helpers/student_management_helpers.dart';
import '../widgets/activity_section.dart';
import '../widgets/campaign_dialog.dart';
import '../widgets/communication_section.dart';
import '../widgets/groups_section.dart';
import '../widgets/overview_section.dart';
import '../widgets/registry_section.dart';
import '../widgets/student_editor_dialog.dart';

class StudentsManagementPage extends StatefulWidget {
  const StudentsManagementPage({super.key});

  @override
  State<StudentsManagementPage> createState() => _StudentsManagementPageState();
}

class _StudentsManagementPageState extends State<StudentsManagementPage> {
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
    return StoreConnector<AppState, _StudentsViewModel>(
      onInit: (store) => store.dispatch(const LoadStudentsAction()),
      converter: (store) => _StudentsViewModel(
        state: store.state.studentsState,
        role: store.state.authState.currentUser?.role ?? 'viewer',
        notificationStatus:
            store.state.notificationsState.connectionStatus.label,
      ),
      builder: (context, vm) {
        if (_searchController.text != vm.state.filters.query) {
          _searchController.value = TextEditingValue(
            text: vm.state.filters.query,
            selection: TextSelection.collapsed(
              offset: vm.state.filters.query.length,
            ),
          );
        }

        final store = StoreProvider.of<AppState>(context);
        final snapshot = vm.state.snapshot;
        final isDesktop = MediaQuery.sizeOf(context).width >= 1320;

        if (!vm.canManage) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: StudentEmptyState(
              title: 'Student module is admin-only',
              subtitle:
                  'Role-based access is active. Sign in as an administrator to manage student records, approvals, and exports.',
              icon: Icons.lock_person_rounded,
            ),
          );
        }

        if (vm.state.status == LoadStatus.loading && snapshot == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (vm.state.status == LoadStatus.failure && snapshot == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: context.l10n.byValue('Student Management Module'),
                  subtitle: context.l10n.byValue(
                      'A unified admin workspace for student lifecycle operations.'),
                  breadcrumbs: [
                    context.l10n.byValue('Admin'),
                    context.l10n.byValue('Students')
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                StudentEmptyState(
                  title: 'Unable to load students',
                  subtitle:
                      vm.state.errorMessage ??
                      'Try refreshing the module again.',
                  icon: Icons.error_outline_rounded,
                ),
              ],
            ),
          );
        }

        if (snapshot == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final students = sortStudents(
          filterStudents(snapshot.students, vm.state.filters),
          vm.state.sortColumn,
          vm.state.sortAscending,
        );
        final selectedStudent = resolveSelectedStudent(
          snapshot,
          students,
          vm.state.selectedStudentId,
        );
        final activities = filterActivities(
          snapshot,
          vm.state.filters,
          students,
        );

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: context.l10n.byValue('Student Management Module'),
                subtitle: context.l10n.byValue(
                    'Premium student lifecycle workspace with analytics, approvals, communication, bulk upload, documents, activity tracking, and secure exports.'),
                breadcrumbs: [
                  context.l10n.byValue('Admin'),
                  context.l10n.byValue('Academy'),
                  context.l10n.byValue('Students')
                ],
                actions: [
                  PremiumButton(
                    label: context.l10n.byValue('Bulk upload'),
                    icon: Icons.file_upload_outlined,
                    isSecondary: true,
                    onPressed: () => _pickImportFile(store),
                  ),
                  PremiumButton(
                    label: context.l10n.byValue('Export analytics'),
                    icon: Icons.picture_as_pdf_rounded,
                    isSecondary: true,
                    onPressed: () => _exportAnalyticsReport(store),
                  ),
                  PremiumButton(
                    label: context.l10n.byValue('Add student'),
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () =>
                        _openStudentEditor(context, store, existing: null),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    _buildHero(store, vm, students),
                    if (vm.state.importPreview != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildImportReview(
                        store,
                        vm.state.importPreview!,
                        vm.state,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: switch (vm.state.activeTab) {
                        StudentWorkspaceTab.overview => OverviewSection(
                            key: const ValueKey('overview'),
                            snapshot: snapshot,
                            selectedStudent: selectedStudent,
                            notificationStatus: vm.notificationStatus,
                            onExportCsv: () => _exportRegistryCsv(students),
                            onOpenStudent: (student) => store.dispatch(
                              StudentsSelectedStudentChangedAction(student.id),
                            ),
                            onEditStudent: () => _openStudentEditor(
                              context,
                              store,
                              existing: selectedStudent,
                            ),
                            onUploadDocuments: () =>
                                _pickStudentDocuments(store, selectedStudent),
                            onExportTranscript: () =>
                                _handleTranscriptExport(store, selectedStudent),
                            onDownloadBundle: () =>
                                _handleDocumentBundle(store, selectedStudent),
                            onApproveDocument: (document) => _reviewDocument(
                              store,
                              selectedStudent,
                              document,
                              StudentDocumentStatus.approved,
                            ),
                            onRejectDocument: (document) => _reviewDocument(
                              store,
                              selectedStudent,
                              document,
                              StudentDocumentStatus.rejected,
                            ),
                          ),
                        StudentWorkspaceTab.registry => RegistrySection(
                            key: const ValueKey('registry'),
                            state: vm.state,
                            students: students,
                            selectedStudent: selectedStudent,
                            onSelectStudent: (studentId) => store.dispatch(
                              StudentsSelectedStudentChangedAction(studentId),
                            ),
                            onToggleSelection: (studentId) => store.dispatch(
                              StudentsToggleSelectionAction(studentId),
                            ),
                            onSelectAll: () => store.dispatch(
                              StudentsSetSelectionAction(
                                students.map((item) => item.id).toSet(),
                              ),
                            ),
                            onClearSelection: () => store.dispatch(
                              const StudentsClearSelectionAction(),
                            ),
                            onSort: (column) => store.dispatch(
                                StudentsSortChangedAction(column)),
                            onApproveSelected: () => _runBulkAction(
                              store,
                              StudentBulkActionType.approveRegistrations,
                            ),
                            onRejectSelected: () => _runBulkAction(
                              store,
                              StudentBulkActionType.rejectRegistrations,
                              needsTwoFactor: true,
                            ),
                            onAssignCourse: () =>
                                _showAssignCourseDialog(context, store),
                            onEditStudent: () => _openStudentEditor(
                              context,
                              store,
                              existing: selectedStudent,
                            ),
                            onUploadDocuments: () =>
                                _pickStudentDocuments(store, selectedStudent),
                            onExportTranscript: () =>
                                _handleTranscriptExport(store, selectedStudent),
                            onDownloadBundle: () =>
                                _handleDocumentBundle(store, selectedStudent),
                            showSidePanel: isDesktop,
                            onApproveDocument: (document) => _reviewDocument(
                              store,
                              selectedStudent,
                              document,
                              StudentDocumentStatus.approved,
                            ),
                            onRejectDocument: (document) => _reviewDocument(
                              store,
                              selectedStudent,
                              document,
                              StudentDocumentStatus.rejected,
                            ),
                          ),
                        StudentWorkspaceTab.activity => ActivitySection(
                            key: const ValueKey('activity'),
                            activities: activities,
                            studentsById: {
                              for (final student in snapshot.students)
                                student.id: student,
                            },
                          ),
                        StudentWorkspaceTab.groups => GroupsSection(
                            key: const ValueKey('groups'),
                            snapshot: snapshot,
                            onNotifyGroup: (group) => _showCampaignDialog(
                                context, store,
                                group: group),
                          ),
                        StudentWorkspaceTab.communication =>
                          CommunicationSection(
                            key: const ValueKey('communication'),
                            snapshot: snapshot,
                            selectedStudentIds: vm.state.selectedStudentIds,
                            onCompose: () =>
                                _showCampaignDialog(context, store),
                          ),
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero(
    Store<AppState> store,
    _StudentsViewModel vm,
    List<StudentProfile> students,
  ) {
    final snapshot = vm.state.snapshot!;
    final filters = vm.state.filters;
    return StudentGlassPanel(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.18),
          AppColors.info.withValues(alpha: 0.12),
          Theme.of(context).cardColor.withValues(alpha: 0.74),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.byValue('Realtime student operations'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.byValue('Search by name, ID, email, department, or course, then move across approvals, documents, analytics, groups, and communication without losing context.'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _SecurityPanel(lastUpdatedAt: vm.state.lastUpdatedAt),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width < 960
                    ? double.infinity
                    : 300,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => store.dispatch(
                    StudentsFiltersChangedAction(
                      filters.copyWith(query: value),
                    ),
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.byValue('Search name, ID, email, department, course'),
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              _FilterDropdown(
                label: 'Department',
                value: filters.department,
                items: [
                  'All departments',
                  ...{
                    for (final student in snapshot.students) student.department,
                  },
                ].toList(),
                onChanged: (value) => store.dispatch(
                  StudentsFiltersChangedAction(
                    filters.copyWith(department: value),
                  ),
                ),
              ),
              _FilterDropdown(
                label: 'Year',
                value: filters.year,
                items: const ['All years', '1', '2', '3', '4', '5'],
                onChanged: (value) => store.dispatch(
                  StudentsFiltersChangedAction(filters.copyWith(year: value)),
                ),
              ),
              _FilterDropdown(
                label: 'Status',
                value: filters.enrollmentStatus,
                items: const [
                  'All statuses',
                  'Active',
                  'Pending approval',
                  'Probation',
                  'Suspended',
                  'Alumni',
                ],
                onChanged: (value) => store.dispatch(
                  StudentsFiltersChangedAction(
                    filters.copyWith(enrollmentStatus: value),
                  ),
                ),
              ),
              _FilterDropdown(
                label: 'GPA',
                value: filters.gpaBand,
                items: const [
                  'All GPA',
                  'High (3.5+)',
                  'Stable (2.5-3.49)',
                  'Low (<2.5)',
                ],
                onChanged: (value) => store.dispatch(
                  StudentsFiltersChangedAction(
                    filters.copyWith(gpaBand: value),
                  ),
                ),
              ),
              _FilterDropdown(
                label: 'Attendance',
                value: filters.attendanceBand,
                items: const [
                  'All attendance',
                  'Excellent (90%+)',
                  'Stable (80-89%)',
                  'At risk (<80%)',
                ],
                onChanged: (value) => store.dispatch(
                  StudentsFiltersChangedAction(
                    filters.copyWith(attendanceBand: value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _FilterDropdown(
                label: 'Course',
                value: filters.course,
                items: [
                  'All courses',
                  ...{
                    for (final student in snapshot.students)
                      for (final course in student.courses) course.title,
                  },
                ].toList(),
                onChanged: (value) => store.dispatch(
                  StudentsFiltersChangedAction(filters.copyWith(course: value)),
                ),
              ),
              _FilterDropdown(
                label: 'Activity',
                value: filters.activityType,
                items: const [
                  'All activity',
                  'Login',
                  'Assignment',
                  'Forum post',
                  'Message',
                  'Submission',
                  'Document',
                  'Approval',
                ],
                onChanged: (value) => store.dispatch(
                  StudentsFiltersChangedAction(
                    filters.copyWith(activityType: value),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => store.dispatch(
                  StudentsFiltersChangedAction(const StudentFilters()),
                ),
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(context.l10n.byValue('Reset filters')),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportRegistryCsv(students),
                icon: const Icon(Icons.download_rounded),
                label: Text(context.l10n.byValue('Export table')),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final tab in StudentWorkspaceTab.values)
                ChoiceChip(
                  label: Text(context.l10n.byValue(tab.label)),
                  selected: vm.state.activeTab == tab,
                  onSelected: (_) =>
                      store.dispatch(StudentsTabChangedAction(tab)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportReview(
    Store<AppState> store,
    StudentImportPreview preview,
    StudentsState state,
  ) {
    return StudentSectionCard(
      title: context.l10n.byValue('Bulk upload review'),
      subtitle: context.l10n.byValue(
          'Auto-mapped CSV/Excel columns, duplicate detection, and progress-aware import pipeline.'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StudentStatusPill(
            label: '${preview.validRows} ${context.l10n.byValue('valid')}',
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          StudentStatusPill(
            label: '${preview.duplicates.length} ${context.l10n.byValue('duplicates')}',
            color: AppColors.warning,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final field in StudentImportField.values)
                SizedBox(
                  width: 220,
                  child: _FilterDropdown(
                    label: field.label,
                    value: preview.columnMapping[field] ?? 'Not mapped',
                    items: ['Not mapped', ...preview.headers],
                    onChanged: (value) => store.dispatch(
                      StudentsImportMappingUpdatedAction(
                        field,
                        value == 'Not mapped' ? null : value,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LinearProgressIndicator(
            value: state.isWorking ? state.importProgress.clamp(0, 1) : null,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            preview.duplicates.isEmpty
                ? context.l10n.byValue('No duplicates detected in the import file.')
                : '${context.l10n.byValue('Duplicates:')} ${preview.duplicates.take(5).join(', ')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              FilledButton.icon(
                onPressed: state.isWorking
                    ? null
                    : () =>
                          store.dispatch(const StudentsImportRequestedAction()),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(context.l10n.byValue('Import students')),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                state.lastImportResult?.summary ??
                    '${preview.totalRows} ${context.l10n.byValue('rows detected in')} ${preview.fileName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImportFile(Store<AppState> store) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx', 'xls'],
      withData: true,
    );
    final file = result?.files.singleOrNull;
    if (file == null || file.bytes == null) return;
    store.dispatch(
      StudentsImportPreviewRequestedAction(
        fileName: file.name,
        bytes: file.bytes!,
      ),
    );
  }

  Future<void> _pickStudentDocuments(
    Store<AppState> store,
    StudentProfile? student,
  ) async {
    if (student == null) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    final files = result.files
        .where((file) => file.bytes != null)
        .map(
          (file) => StudentUploadedFile(
            name: file.name,
            bytes: file.bytes!,
            sizeInBytes: file.size,
            mimeType: file.extension == null
                ? null
                : 'application/${file.extension}',
          ),
        )
        .toList(growable: false);
    if (files.isEmpty) return;
    store.dispatch(
      StudentsDocumentsUploadRequestedAction(
        studentId: student.id,
        files: files,
      ),
    );
  }

  Future<void> _exportRegistryCsv(List<StudentProfile> students) async {
    final buffer = StringBuffer()
      ..writeln(
        '"Student ID","Name","Email","Department","Year","Status","GPA","Attendance","Current Courses"',
      );
    for (final student in students) {
      final currentCourses = student.courses
          .where((item) => item.isCurrentTerm)
          .map((item) => item.title)
          .join(' | ');
      buffer.writeln(
        [
          student.studentNumber,
          student.fullName,
          student.contact.email,
          student.department,
          student.year.toString(),
          student.enrollmentStatus.label,
          student.gpa.toStringAsFixed(2),
          student.attendanceRate.toStringAsFixed(0),
          currentCourses,
        ].map(csvCell).join(','),
      );
    }
    await saveStudentModuleFile(
      fileName: 'students-registry.csv',
      bytes: Uint8List.fromList(utf8.encode(buffer.toString())),
      allowedExtensions: const ['csv'],
    );
  }

  Future<void> _exportAnalyticsReport(Store<AppState> store) async {
    store.dispatch(
      StudentsAnalyticsExportRequestedAction(
        onReady: (bytes, suggestedName) {
          saveStudentModuleFile(
            fileName: suggestedName,
            bytes: bytes,
            allowedExtensions: const ['pdf'],
          );
        },
      ),
    );
  }

  Future<void> _handleTranscriptExport(
    Store<AppState> store,
    StudentProfile? student,
  ) async {
    if (student == null) return;
    final code = await _showTwoFactorDialog(
      context,
      title: 'Confirm transcript export',
      subtitle:
          'Sensitive exports require a 2FA code before generating the transcript PDF.',
    );
    if (code == null) return;
    store.dispatch(
      StudentsTranscriptExportRequestedAction(
        studentId: student.id,
        onReady: (bytes, suggestedName) {
          saveStudentModuleFile(
            fileName: suggestedName,
            bytes: bytes,
            allowedExtensions: const ['pdf'],
          );
        },
      ),
    );
  }

  Future<void> _handleDocumentBundle(
    Store<AppState> store,
    StudentProfile? student,
  ) async {
    if (student == null) return;
    store.dispatch(
      StudentsDocumentBundleRequestedAction(
        studentId: student.id,
        onReady: (bytes, suggestedName) {
          saveStudentModuleFile(
            fileName: suggestedName,
            bytes: bytes,
            allowedExtensions: const ['zip'],
          );
        },
      ),
    );
  }

  Future<void> _reviewDocument(
    Store<AppState> store,
    StudentProfile? student,
    StudentDocumentRecord document,
    StudentDocumentStatus status,
  ) async {
    if (student == null) return;
    final code = await _showTwoFactorDialog(
      context,
      title: 'Confirm document review',
      subtitle:
          'This approval workflow is protected. Enter the admin 2FA code to continue.',
    );
    if (code == null) return;
    store.dispatch(
      StudentsDocumentDecisionRequestedAction(
        studentId: student.id,
        documentId: document.id,
        status: status,
        verificationCode: code,
      ),
    );
  }

  Future<void> _runBulkAction(
    Store<AppState> store,
    StudentBulkActionType type, {
    bool needsTwoFactor = false,
  }) async {
    String? code;
    if (needsTwoFactor) {
      code = await _showTwoFactorDialog(
        context,
        title: 'Secure bulk action',
        subtitle:
            'This operation affects multiple student records and requires 2FA verification.',
      );
      if (code == null) return;
    }
    store.dispatch(
      StudentsBulkActionRequestedAction(type: type, verificationCode: code),
    );
  }

  Future<void> _showAssignCourseDialog(
    BuildContext context,
    Store<AppState> store,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Assign course in bulk'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Course title',
              hintText: 'Example: Research Methods',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Assign'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || controller.text.trim().isEmpty) return;
    store.dispatch(
      StudentsBulkActionRequestedAction(
        type: StudentBulkActionType.assignCourse,
        courseTitle: controller.text.trim(),
      ),
    );
  }

  Future<void> _openStudentEditor(
    BuildContext context,
    Store<AppState> store, {
    required StudentProfile? existing,
  }) async {
    final result = await showDialog<StudentProfile>(
      context: context,
      builder: (context) => StudentEditorDialog(existing: existing),
    );
    if (result == null) return;
    store.dispatch(StudentsStudentSavedRequestedAction(student: result));
  }

  Future<void> _showCampaignDialog(
    BuildContext context,
    Store<AppState> store, {
    StudentGroupRecord? group,
  }) async {
    final snapshot = store.state.studentsState.snapshot;
    if (snapshot == null) return;
    final result = await showDialog<CampaignDialogResult>(
      context: context,
      builder: (context) => CampaignDialog(
        snapshot: snapshot,
        group: group,
        selectedStudentIds: store.state.studentsState.selectedStudentIds,
      ),
    );
    if (result == null) return;
    store.dispatch(
      StudentsCampaignRequestedAction(
        title: result.title,
        body: result.body,
        channel: result.channel,
        recipientStudentIds: result.recipientStudentIds,
        audienceLabel: result.audienceLabel,
        groupId: result.groupId,
      ),
    );
  }
}

class _StudentsViewModel {
  const _StudentsViewModel({
    required this.state,
    required this.role,
    required this.notificationStatus,
  });

  final StudentsState state;
  final String role;
  final String notificationStatus;

  bool get canManage => role.toLowerCase().contains('admin');
}

class _SecurityPanel extends StatelessWidget {
  const _SecurityPanel({required this.lastUpdatedAt});

  final DateTime? lastUpdatedAt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: StudentGlassPanel(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: StreamBuilder<DateTime>(
          stream: Stream<DateTime>.periodic(
            const Duration(seconds: 30),
            (_) => DateTime.now(),
          ),
          initialData: DateTime.now(),
          builder: (context, snapshot) {
            final now = snapshot.data ?? DateTime.now();
            final reference = lastUpdatedAt ?? now;
            final remaining = Duration(minutes: 14) - now.difference(reference);
            final safeRemaining = remaining.isNegative
                ? Duration.zero
                : remaining;
            
            final isAr = context.l10n.locale.languageCode == 'ar';
            final timeoutText = isAr
                ? 'تنتهي الجلسة خلال ${safeRemaining.inMinutes} دقيقة • يتطلب مصادقة ثنائية للإجراءات الحساسة.'
                : 'Session timeout in ${safeRemaining.inMinutes}m • 2FA required for sensitive actions.';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.byValue('Security'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  timeoutText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : items.firstOrNull,
        isExpanded: true,
        decoration: InputDecoration(labelText: context.l10n.byValue(label)),
        selectedItemBuilder: (context) => [
          for (final item in items)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(context.l10n.byValue(item), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
        items: [
          for (final item in items)
            DropdownMenuItem(
              value: item,
              child: Text(context.l10n.byValue(item), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

Future<String?> _showTwoFactorDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '2FA code',
                hintText: 'Enter 6-digit code',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.length != 6) return;
              Navigator.of(context).pop(code);
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}
