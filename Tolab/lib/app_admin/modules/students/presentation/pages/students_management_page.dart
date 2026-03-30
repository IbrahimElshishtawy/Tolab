import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/student_management_models.dart';
import '../../state/students_state.dart';
import '../../widgets/student_module_charts.dart';
import '../../widgets/student_module_primitives.dart';
import '../helpers/student_file_saver.dart';

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
        final isDesktop = MediaQuery.sizeOf(context).width >= 1180;

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
                const PageHeader(
                  title: 'Student Management Module',
                  subtitle:
                      'A unified admin workspace for student lifecycle operations.',
                  breadcrumbs: ['Admin', 'Students'],
                ),
                const SizedBox(height: AppSpacing.lg),
                StudentEmptyState(
                  title: 'Unable to load students',
                  subtitle:
                      vm.state.errorMessage ?? 'Try refreshing the module again.',
                  icon: Icons.error_outline_rounded,
                ),
              ],
            ),
          );
        }

        if (snapshot == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final students = _sortStudents(
          _filterStudents(snapshot?.students ?? const [], vm.state.filters),
          vm.state.sortColumn,
          vm.state.sortAscending,
        );
        final selectedStudent = _resolveSelectedStudent(
          snapshot,
          students,
          vm.state.selectedStudentId,
        );
        final activities = _filterActivities(snapshot, vm.state.filters, students);

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Student Management Module',
                subtitle:
                    'Premium student lifecycle workspace with analytics, approvals, communication, bulk upload, documents, activity tracking, and secure exports.',
                breadcrumbs: const ['Admin', 'Academy', 'Students'],
                actions: [
                  PremiumButton(
                    label: 'Bulk upload',
                    icon: Icons.file_upload_outlined,
                    isSecondary: true,
                    onPressed: () => _pickImportFile(store),
                  ),
                  PremiumButton(
                    label: 'Export analytics',
                    icon: Icons.picture_as_pdf_rounded,
                    isSecondary: true,
                    onPressed: () => _exportAnalyticsReport(store),
                  ),
                  PremiumButton(
                    label: 'Add student',
                    icon: Icons.person_add_alt_1_rounded,
                    onPressed: () => _openStudentEditor(
                      context,
                      store,
                      existing: null,
                    ),
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
                      _buildImportReview(store, vm.state.importPreview!, vm.state),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: switch (vm.state.activeTab) {
                        StudentWorkspaceTab.overview => _OverviewSection(
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
                        StudentWorkspaceTab.registry => _RegistrySection(
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
                              StudentsSortChangedAction(column),
                            ),
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
                        StudentWorkspaceTab.activity => _ActivitySection(
                            key: const ValueKey('activity'),
                            activities: activities,
                            studentsById: {
                              for (final student in snapshot?.students ?? const [])
                                student.id: student,
                            },
                          ),
                        StudentWorkspaceTab.groups => _GroupsSection(
                            key: const ValueKey('groups'),
                            snapshot: snapshot,
                            onNotifyGroup: (group) =>
                                _showCampaignDialog(context, store, group: group),
                          ),
                        StudentWorkspaceTab.communication => _CommunicationSection(
                            key: const ValueKey('communication'),
                            snapshot: snapshot,
                            selectedStudentIds: vm.state.selectedStudentIds,
                            onCompose: () => _showCampaignDialog(context, store),
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
                      'Realtime student operations',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search by name, ID, email, department, or course, then move across approvals, documents, analytics, groups, and communication without losing context.',
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
                width: MediaQuery.sizeOf(context).width < 900 ? double.infinity : 360,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => store.dispatch(
                    StudentsFiltersChangedAction(filters.copyWith(query: value)),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search name, ID, email, department, course',
                    prefixIcon: Icon(Icons.search_rounded),
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
                items: const [
                  'All years',
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                ],
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
                  StudentsFiltersChangedAction(filters.copyWith(gpaBand: value)),
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
                label: const Text('Reset filters'),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportRegistryCsv(students),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export table'),
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
                  label: Text(tab.label),
                  selected: vm.state.activeTab == tab,
                  onSelected: (_) =>
                      store.dispatch(StudentsTabChangedAction(tab)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              for (final alert in snapshot.alerts.take(3))
                SizedBox(
                  width: MediaQuery.sizeOf(context).width < 900 ? double.infinity : 280,
                  child: _AlertTile(alert: alert),
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
      title: 'Bulk upload review',
      subtitle:
          'Auto-mapped CSV/Excel columns, duplicate detection, and progress-aware import pipeline.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StudentStatusPill(
            label: '${preview.validRows} valid',
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          StudentStatusPill(
            label: '${preview.duplicates.length} duplicates',
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
                ? 'No duplicates detected in the import file.'
                : 'Duplicates: ${preview.duplicates.take(5).join(', ')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              FilledButton.icon(
                onPressed: state.isWorking
                    ? null
                    : () => store.dispatch(const StudentsImportRequestedAction()),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Import students'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                state.lastImportResult?.summary ??
                    '${preview.totalRows} rows detected in ${preview.fileName}',
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
        ].map(_csvCell).join(','),
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
      StudentsBulkActionRequestedAction(
        type: type,
        verificationCode: code,
      ),
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
      builder: (context) => _StudentEditorDialog(existing: existing),
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
    final result = await showDialog<_CampaignDialogResult>(
      context: context,
      builder: (context) => _CampaignDialog(
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

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    super.key,
    required this.snapshot,
    required this.selectedStudent,
    required this.notificationStatus,
    required this.onExportCsv,
    required this.onOpenStudent,
    required this.onEditStudent,
    required this.onUploadDocuments,
    required this.onExportTranscript,
    required this.onDownloadBundle,
    required this.onApproveDocument,
    required this.onRejectDocument,
  });

  final StudentModuleSnapshot snapshot;
  final StudentProfile? selectedStudent;
  final String notificationStatus;
  final VoidCallback onExportCsv;
  final ValueChanged<StudentProfile> onOpenStudent;
  final VoidCallback onEditStudent;
  final VoidCallback onUploadDocuments;
  final VoidCallback onExportTranscript;
  final VoidCallback onDownloadBundle;
  final ValueChanged<StudentDocumentRecord> onApproveDocument;
  final ValueChanged<StudentDocumentRecord> onRejectDocument;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final chartWidth = width > 1400
        ? (width - 220) / 3
        : width > 980
        ? (width - 160) / 2
        : width - 48;
    final watchlist = snapshot.students
        .where((item) => item.isAtRisk)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: chartWidth,
              child: StudentKpiCard(
                label: 'Students',
                value: snapshot.totalStudents.toString(),
                caption: 'All enrolled student records in the module.',
                icon: Icons.groups_rounded,
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              width: chartWidth,
              child: StudentKpiCard(
                label: 'Courses',
                value: snapshot.activeCoursesCount.toString(),
                caption: 'Distinct active offerings assigned to students.',
                icon: Icons.auto_stories_rounded,
                color: AppColors.info,
              ),
            ),
            SizedBox(
              width: chartWidth,
              child: StudentKpiCard(
                label: 'Pending',
                value: snapshot.pendingApprovals.toString(),
                caption: 'Registrations still waiting for admin approval.',
                icon: Icons.fact_check_rounded,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: chartWidth,
              child: StudentKpiCard(
                label: 'Average GPA',
                value: snapshot.averageGpa.toStringAsFixed(2),
                caption: 'Live academic average across all student profiles.',
                icon: Icons.insights_rounded,
                color: AppColors.success,
              ),
            ),
            SizedBox(
              width: chartWidth,
              child: StudentKpiCard(
                label: 'Attendance',
                value: '${snapshot.averageAttendance.toStringAsFixed(0)}%',
                caption: 'Average attendance health tracked from course records.',
                icon: Icons.co_present_rounded,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(
              width: chartWidth,
              child: StudentKpiCard(
                label: notificationStatus,
                value: snapshot.pendingDocuments.toString(),
                caption: 'Pending document reviews in the approval queue.',
                icon: Icons.file_open_rounded,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: chartWidth,
              child: StudentSectionCard(
                title: 'Enrollment trend',
                subtitle: 'Realtime line chart for enrollment momentum.',
                trailing: IconButton(
                  onPressed: onExportCsv,
                  icon: const Icon(Icons.download_rounded),
                ),
                child: SizedBox(
                  height: 260,
                  child: StudentLineTrendChart(points: snapshot.enrollmentTrend),
                ),
              ),
            ),
            SizedBox(
              width: chartWidth,
              child: StudentSectionCard(
                title: 'Department distribution',
                subtitle: 'Student distribution by department.',
                child: SizedBox(
                  height: 260,
                  child: StudentDepartmentBarChart(
                    distribution: snapshot.departmentDistribution,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: chartWidth,
              child: StudentSectionCard(
                title: 'Approval queue',
                subtitle:
                    'Donut split across pending, active, and watchlist students.',
                child: SizedBox(
                  height: 260,
                  child: StudentDonutChart(
                    pending: snapshot.pendingApprovals,
                    active: snapshot.students
                        .where(
                          (item) =>
                              item.enrollmentStatus ==
                              StudentEnrollmentStatus.active,
                        )
                        .length,
                    watchlist: watchlist,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final showSide = constraints.maxWidth > 1200 && selectedStudent != null;
            if (!showSide) {
              return Column(
                children: [
                  _PendingQueuesCard(snapshot: snapshot, onOpenStudent: onOpenStudent),
                  if (selectedStudent != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _StudentProfilePanel(
                      student: selectedStudent!,
                      onEditStudent: onEditStudent,
                      onUploadDocuments: onUploadDocuments,
                      onExportTranscript: onExportTranscript,
                      onDownloadBundle: onDownloadBundle,
                      onApproveDocument: onApproveDocument,
                      onRejectDocument: onRejectDocument,
                    ),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _PendingQueuesCard(
                    snapshot: snapshot,
                    onOpenStudent: onOpenStudent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 4,
                  child: _StudentProfilePanel(
                    student: selectedStudent!,
                    onEditStudent: onEditStudent,
                    onUploadDocuments: onUploadDocuments,
                    onExportTranscript: onExportTranscript,
                    onDownloadBundle: onDownloadBundle,
                    onApproveDocument: onApproveDocument,
                    onRejectDocument: onRejectDocument,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PendingQueuesCard extends StatelessWidget {
  const _PendingQueuesCard({
    required this.snapshot,
    required this.onOpenStudent,
  });

  final StudentModuleSnapshot snapshot;
  final ValueChanged<StudentProfile> onOpenStudent;

  @override
  Widget build(BuildContext context) {
    final pending = snapshot.students
        .where(
          (item) =>
              item.enrollmentStatus == StudentEnrollmentStatus.pendingApproval ||
              item.pendingDocumentCount > 0,
        )
        .toList(growable: false);
    return StudentSectionCard(
      title: 'Approvals and document queue',
      subtitle:
          'Scrollable approval table highlighting pending enrollment packages, missing document reviews, and at-risk signals.',
      child: SizedBox(
        height: 360,
        child: DataTable2(
          fixedTopRows: 1,
          minWidth: 860,
          columns: const [
            DataColumn2(label: Text('Student'), size: ColumnSize.L),
            DataColumn2(label: Text('Department')),
            DataColumn2(label: Text('Status')),
            DataColumn2(label: Text('Pending docs')),
            DataColumn2(label: Text('GPA')),
            DataColumn2(label: Text('Action')),
          ],
          rows: [
            for (final student in pending)
              DataRow2(
                onTap: () => onOpenStudent(student),
                cells: [
                  DataCell(Text(student.fullName)),
                  DataCell(Text(student.department)),
                  DataCell(
                    StudentStatusPill(
                      label: student.enrollmentStatus.label,
                      color: student.enrollmentStatus ==
                              StudentEnrollmentStatus.pendingApproval
                          ? AppColors.warning
                          : AppColors.info,
                    ),
                  ),
                  DataCell(Text(student.pendingDocumentCount.toString())),
                  DataCell(Text(student.gpa.toStringAsFixed(2))),
                  const DataCell(Icon(Icons.chevron_right_rounded)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RegistrySection extends StatelessWidget {
  const _RegistrySection({
    super.key,
    required this.state,
    required this.students,
    required this.selectedStudent,
    required this.onSelectStudent,
    required this.onToggleSelection,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onSort,
    required this.onApproveSelected,
    required this.onRejectSelected,
    required this.onAssignCourse,
    required this.onEditStudent,
    required this.onUploadDocuments,
    required this.onExportTranscript,
    required this.onDownloadBundle,
    required this.showSidePanel,
    required this.onApproveDocument,
    required this.onRejectDocument,
  });

  final StudentsState state;
  final List<StudentProfile> students;
  final StudentProfile? selectedStudent;
  final ValueChanged<String> onSelectStudent;
  final ValueChanged<String> onToggleSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final ValueChanged<String> onSort;
  final VoidCallback onApproveSelected;
  final VoidCallback onRejectSelected;
  final VoidCallback onAssignCourse;
  final VoidCallback onEditStudent;
  final VoidCallback onUploadDocuments;
  final VoidCallback onExportTranscript;
  final VoidCallback onDownloadBundle;
  final bool showSidePanel;
  final ValueChanged<StudentDocumentRecord> onApproveDocument;
  final ValueChanged<StudentDocumentRecord> onRejectDocument;

  @override
  Widget build(BuildContext context) {
    final table = StudentSectionCard(
      title: 'Student registry',
      subtitle:
          'Sticky-header student registry with live search results, bulk actions, and deep profile drilldown.',
      trailing: state.selectedStudentIds.isEmpty
          ? StudentStatusPill(
              label: '${students.length} results',
              color: AppColors.info,
            )
          : Wrap(
              spacing: AppSpacing.sm,
              children: [
                FilledButton.tonal(
                  onPressed: onApproveSelected,
                  child: const Text('Approve'),
                ),
                FilledButton.tonal(
                  onPressed: onRejectSelected,
                  child: const Text('Reject'),
                ),
                OutlinedButton(
                  onPressed: onAssignCourse,
                  child: const Text('Assign course'),
                ),
                TextButton(
                  onPressed: onClearSelection,
                  child: Text('${state.selectedStudentIds.length} selected'),
                ),
              ],
            ),
      child: SizedBox(
        height: 520,
        child: DataTable2(
          fixedTopRows: 1,
          minWidth: 1120,
          sortAscending: state.sortAscending,
          sortColumnIndex: switch (state.sortColumn) {
            'name' => 1,
            'department' => 2,
            'attendance' => 3,
            'gpa' => 4,
            _ => 5,
          },
          columns: [
            DataColumn2(
              fixedWidth: 40,
              label: IconButton(
                onPressed: onSelectAll,
                icon: const Icon(Icons.done_all_rounded),
              ),
            ),
            DataColumn2(
              label: const Text('Student'),
              size: ColumnSize.L,
              onSort: (_, __) => onSort('name'),
            ),
            DataColumn2(
              label: const Text('Department'),
              onSort: (_, __) => onSort('department'),
            ),
            DataColumn2(
              label: const Text('Attendance'),
              onSort: (_, __) => onSort('attendance'),
            ),
            DataColumn2(
              label: const Text('GPA'),
              onSort: (_, __) => onSort('gpa'),
            ),
            DataColumn2(
              label: const Text('Status'),
              onSort: (_, __) => onSort('status'),
            ),
            const DataColumn2(label: Text('Actions'), size: ColumnSize.S),
          ],
          rows: [
            for (final student in students)
              DataRow2(
                selected: selectedStudent?.id == student.id,
                onTap: () => onSelectStudent(student.id),
                cells: [
                  DataCell(
                    Checkbox(
                      value: state.selectedStudentIds.contains(student.id),
                      onChanged: (_) => onToggleSelection(student.id),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        StudentAvatar(name: student.fullName),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(student.fullName),
                              Text(
                                '${student.studentNumber} • ${student.contact.email}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text('${student.department} • Y${student.year}')),
                  DataCell(Text('${student.attendanceRate.toStringAsFixed(0)}%')),
                  DataCell(Text(student.gpa.toStringAsFixed(2))),
                  DataCell(
                    StudentStatusPill(
                      label: student.enrollmentStatus.label,
                      color: student.isAtRisk ? AppColors.danger : AppColors.success,
                    ),
                  ),
                  DataCell(
                    IconButton(
                      onPressed: () => onSelectStudent(student.id),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    if (!showSidePanel || selectedStudent == null) {
      return Column(
        children: [
          table,
          if (selectedStudent != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _StudentProfilePanel(
              student: selectedStudent,
              onEditStudent: onEditStudent,
              onUploadDocuments: onUploadDocuments,
              onExportTranscript: onExportTranscript,
              onDownloadBundle: onDownloadBundle,
              onApproveDocument: onApproveDocument,
              onRejectDocument: onRejectDocument,
            ),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: table),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 4,
          child: _StudentProfilePanel(
            student: selectedStudent,
            onEditStudent: onEditStudent,
            onUploadDocuments: onUploadDocuments,
            onExportTranscript: onExportTranscript,
            onDownloadBundle: onDownloadBundle,
            onApproveDocument: onApproveDocument,
            onRejectDocument: onRejectDocument,
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    super.key,
    required this.activities,
    required this.studentsById,
  });

  final List<StudentActivityRecord> activities;
  final Map<String, StudentProfile> studentsById;

  @override
  Widget build(BuildContext context) {
    return StudentSectionCard(
      title: 'Activity tracking',
      subtitle:
          'Recent login, submission, forum, message, and approval events in a searchable table view.',
      child: SizedBox(
        height: 520,
        child: DataTable2(
          fixedTopRows: 1,
          minWidth: 980,
          columns: const [
            DataColumn2(label: Text('Student'), size: ColumnSize.L),
            DataColumn2(label: Text('Type')),
            DataColumn2(label: Text('Course')),
            DataColumn2(label: Text('Description'), size: ColumnSize.L),
            DataColumn2(label: Text('When')),
          ],
          rows: [
            for (final activity in activities)
              DataRow2(
                cells: [
                  DataCell(Text(studentsById[activity.studentId]?.fullName ?? 'Unknown')),
                  DataCell(Text(activity.type.label)),
                  DataCell(Text(activity.courseTitle ?? 'General')),
                  DataCell(Text(activity.description)),
                  DataCell(
                    Text(DateFormat('MMM d, HH:mm').format(activity.occurredAt)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupsSection extends StatelessWidget {
  const _GroupsSection({
    super.key,
    required this.snapshot,
    required this.onNotifyGroup,
  });

  final StudentModuleSnapshot snapshot;
  final ValueChanged<StudentGroupRecord> onNotifyGroup;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final group in snapshot.groups)
          SizedBox(
            width: 360,
            child: StudentSectionCard(
              title: group.name,
              subtitle:
                  '${group.department} • Year ${group.year} • ${group.className}',
              trailing: IconButton(
                onPressed: () => onNotifyGroup(group),
                icon: const Icon(Icons.notifications_active_rounded),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course: ${group.courseTitle}'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Members: ${group.memberIds.length} • Leader: ${snapshot.findStudent(group.leaderId)?.fullName ?? 'Unassigned'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final memberId in group.memberIds)
                        StudentStatusPill(
                          label:
                              snapshot.findStudent(memberId)?.fullName ??
                              memberId,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CommunicationSection extends StatelessWidget {
  const _CommunicationSection({
    super.key,
    required this.snapshot,
    required this.selectedStudentIds,
    required this.onCompose,
  });

  final StudentModuleSnapshot snapshot;
  final Set<String> selectedStudentIds;
  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StudentSectionCard(
          title: 'Communication center',
          subtitle:
              'Send individual, grouped, or bulk messages using in-app, email, and push channels tied to the app’s realtime notifications stack.',
          trailing: FilledButton.icon(
            onPressed: onCompose,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Compose campaign'),
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              StudentStatusPill(
                label: '${selectedStudentIds.length} selected students',
                color: AppColors.primary,
              ),
              StudentStatusPill(
                label: '${snapshot.groups.length} groups',
                color: AppColors.info,
              ),
              StudentStatusPill(
                label: '${snapshot.campaigns.length} recent campaigns',
                color: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        StudentSectionCard(
          title: 'Recent campaigns',
          subtitle:
              'Delivery log with recipients, delivery rate, and open-rate feedback.',
          child: SizedBox(
            height: 420,
            child: DataTable2(
              fixedTopRows: 1,
              minWidth: 920,
              columns: const [
                DataColumn2(label: Text('Title'), size: ColumnSize.L),
                DataColumn2(label: Text('Audience')),
                DataColumn2(label: Text('Channel')),
                DataColumn2(label: Text('Delivered')),
                DataColumn2(label: Text('Opened')),
                DataColumn2(label: Text('Sent')),
              ],
              rows: [
                for (final campaign in snapshot.campaigns)
                  DataRow2(
                    cells: [
                      DataCell(Text(campaign.title)),
                      DataCell(Text(campaign.audienceLabel)),
                      DataCell(Text(campaign.channel.label)),
                      DataCell(Text('${campaign.delivered}/${campaign.recipients}')),
                      DataCell(Text('${campaign.opened}/${campaign.recipients}')),
                      DataCell(
                        Text(DateFormat('MMM d, HH:mm').format(campaign.sentAt)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentProfilePanel extends StatelessWidget {
  const _StudentProfilePanel({
    required this.student,
    required this.onEditStudent,
    required this.onUploadDocuments,
    required this.onExportTranscript,
    required this.onDownloadBundle,
    required this.onApproveDocument,
    required this.onRejectDocument,
  });

  final StudentProfile student;
  final VoidCallback onEditStudent;
  final VoidCallback onUploadDocuments;
  final VoidCallback onExportTranscript;
  final VoidCallback onDownloadBundle;
  final ValueChanged<StudentDocumentRecord> onApproveDocument;
  final ValueChanged<StudentDocumentRecord> onRejectDocument;

  @override
  Widget build(BuildContext context) {
    return StudentSectionCard(
      title: 'Student profile',
      subtitle:
          'Photo, contacts, courses, grades, attendance, documents, and activity feed.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onEditStudent,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: onUploadDocuments,
            icon: const Icon(Icons.upload_file_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentAvatar(name: student.fullName, radius: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${student.studentNumber} • ${student.department} • Year ${student.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StudentStatusPill(
                label: student.enrollmentStatus.label,
                color: student.isAtRisk ? AppColors.danger : AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _InfoTile(
                label: 'Email',
                value: student.contact.email,
                icon: Icons.alternate_email_rounded,
              ),
              _InfoTile(
                label: 'Phone',
                value: student.contact.phone,
                icon: Icons.phone_rounded,
              ),
              _InfoTile(
                label: 'Emergency',
                value:
                    '${student.emergencyContact.name} • ${student.emergencyContact.phone}',
                icon: Icons.health_and_safety_rounded,
              ),
              _InfoTile(
                label: 'Address',
                value: student.contact.address,
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: StudentStatusPill(
                  label: 'GPA ${student.gpa.toStringAsFixed(2)}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StudentStatusPill(
                  label: 'Attendance ${student.attendanceRate.toStringAsFixed(0)}%',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StudentStatusPill(
                  label: 'Avg ${student.averageGrade.toStringAsFixed(0)}',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onExportTranscript,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Transcript'),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onDownloadBundle,
                icon: const Icon(Icons.folder_zip_rounded),
                label: const Text('Docs bundle'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Courses', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final course in student.courses.take(3)) ...[
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text('${course.code} • ${course.title}'),
              subtitle: Text(
                '${course.grade} • ${course.score.toStringAsFixed(0)} • ${course.attendanceRate.toStringAsFixed(0)}% attendance',
              ),
              trailing: Text(course.semester),
            ),
            const Divider(height: 1),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Documents', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final document in student.documents.take(4)) ...[
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    title: Text(document.name),
                    subtitle: Text('${document.category} • ${document.sizeLabel}'),
                  ),
                ),
                StudentStatusPill(
                  label: document.status.label,
                  color: switch (document.status) {
                    StudentDocumentStatus.pending => AppColors.warning,
                    StudentDocumentStatus.approved => AppColors.success,
                    StudentDocumentStatus.rejected => AppColors.danger,
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: () => onApproveDocument(document),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                ),
                IconButton(
                  onPressed: () => onRejectDocument(document),
                  icon: const Icon(Icons.cancel_outlined),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final activity in student.activities.take(4)) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                switch (activity.type) {
                  StudentActivityType.login => Icons.login_rounded,
                  StudentActivityType.assignment => Icons.assignment_rounded,
                  StudentActivityType.forumPost => Icons.forum_rounded,
                  StudentActivityType.message => Icons.chat_bubble_outline_rounded,
                  StudentActivityType.submission => Icons.upload_rounded,
                  StudentActivityType.document => Icons.folder_rounded,
                  StudentActivityType.approval => Icons.verified_rounded,
                },
              ),
              title: Text(activity.title),
              subtitle: Text(activity.description),
              trailing: Text(
                DateFormat('MMM d').format(activity.occurredAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final StudentModuleAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.severity) {
      StudentAlertSeverity.info => AppColors.info,
      StudentAlertSeverity.success => AppColors.success,
      StudentAlertSeverity.warning => AppColors.warning,
      StudentAlertSeverity.critical => AppColors.danger,
    };
    return StudentGlassPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentStatusPill(label: alert.badgeLabel, color: color),
              const Spacer(),
              Text(
                DateFormat('HH:mm').format(alert.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(alert.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(alert.body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
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
            final remaining = Duration(
              minutes: 14,
            ) -
                now.difference(reference);
            final safeRemaining = remaining.isNegative
                ? Duration.zero
                : remaining;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Session timeout in ${safeRemaining.inMinutes}m • 2FA required for sensitive actions.',
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
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
        decoration: InputDecoration(labelText: label),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _StudentEditorDialog extends StatefulWidget {
  const _StudentEditorDialog({required this.existing});

  final StudentProfile? existing;

  @override
  State<_StudentEditorDialog> createState() => _StudentEditorDialogState();
}

class _StudentEditorDialogState extends State<_StudentEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _gpaController;
  late final TextEditingController _attendanceController;
  late final TextEditingController _notesController;
  late int _year;
  late String _department;
  late StudentEnrollmentStatus _status;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.fullName ?? '');
    _studentIdController = TextEditingController(
      text: existing?.studentNumber ?? '',
    );
    _emailController = TextEditingController(text: existing?.contact.email ?? '');
    _phoneController = TextEditingController(text: existing?.contact.phone ?? '');
    _addressController = TextEditingController(
      text: existing?.contact.address ?? '',
    );
    _emergencyNameController = TextEditingController(
      text: existing?.emergencyContact.name ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: existing?.emergencyContact.phone ?? '',
    );
    _gpaController = TextEditingController(
      text: existing == null ? '0.00' : existing.gpa.toStringAsFixed(2),
    );
    _attendanceController = TextEditingController(
      text:
          existing == null ? '0' : existing.attendanceRate.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _year = existing?.year ?? 1;
    _department = existing?.department ?? 'Computer Science';
    _status = existing?.enrollmentStatus ?? StudentEnrollmentStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _gpaController.dispose();
    _attendanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add student' : 'Edit student'),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _dialogField(_nameController, 'Full name'),
                _dialogField(_studentIdController, 'Student ID'),
                _dialogField(
                  _emailController,
                  'Email',
                  validator: _emailValidator,
                ),
                _dialogField(_phoneController, 'Phone'),
                _dialogField(_addressController, 'Address'),
                _dialogField(_emergencyNameController, 'Emergency contact'),
                _dialogField(_emergencyPhoneController, 'Emergency phone'),
                _dialogField(_gpaController, 'GPA'),
                _dialogField(_attendanceController, 'Attendance %'),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<int>(
                    initialValue: _year,
                    decoration: const InputDecoration(labelText: 'Year'),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Year 1')),
                      DropdownMenuItem(value: 2, child: Text('Year 2')),
                      DropdownMenuItem(value: 3, child: Text('Year 3')),
                      DropdownMenuItem(value: 4, child: Text('Year 4')),
                      DropdownMenuItem(value: 5, child: Text('Year 5')),
                    ],
                    onChanged: (value) => setState(() => _year = value ?? _year),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: _department,
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Computer Science',
                        child: Text('Computer Science'),
                      ),
                      DropdownMenuItem(
                        value: 'Information Systems',
                        child: Text('Information Systems'),
                      ),
                      DropdownMenuItem(
                        value: 'Engineering',
                        child: Text('Engineering'),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _department = value ?? _department,
                    ),
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<StudentEnrollmentStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final status in StudentEnrollmentStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => _status = value ?? _status),
                  ),
                ),
                TextFormField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
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
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              (widget.existing ??
                      StudentProfile(
                        id: '',
                        studentNumber: '',
                        fullName: '',
                        year: 1,
                        department: '',
                        className: '',
                        contact: const StudentContactInfo(
                          email: '',
                          phone: '',
                          address: '',
                        ),
                        emergencyContact: const StudentEmergencyContact(
                          name: '',
                          relationship: 'Guardian',
                          phone: '',
                        ),
                        enrollmentStatus: StudentEnrollmentStatus.active,
                        gpa: 0,
                        attendanceRate: 0,
                        averageGrade: 0,
                        registrationApproved: false,
                        courses: const [],
                        documents: const [],
                        activities: const [],
                        memberships: const [],
                        createdAt: DateTime.now(),
                        lastLoginAt: DateTime.now(),
                      ))
                  .copyWith(
                    studentNumber: _studentIdController.text.trim(),
                    fullName: _nameController.text.trim(),
                    year: _year,
                    department: _department,
                    className:
                        '${_department.split(' ').first.toUpperCase()}-${_year}A',
                    contact: widget.existing?.contact.copyWith(
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                        ) ??
                        StudentContactInfo(
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                        ),
                    emergencyContact: widget.existing?.emergencyContact.copyWith(
                          name: _emergencyNameController.text.trim(),
                          phone: _emergencyPhoneController.text.trim(),
                        ) ??
                        StudentEmergencyContact(
                          name: _emergencyNameController.text.trim(),
                          relationship: 'Guardian',
                          phone: _emergencyPhoneController.text.trim(),
                        ),
                    enrollmentStatus: _status,
                    gpa: double.parse(_gpaController.text.trim()),
                    attendanceRate: double.parse(
                      _attendanceController.text.trim(),
                    ),
                    averageGrade: max(
                      55,
                      double.parse(_gpaController.text.trim()) * 24,
                    ),
                    notes: _notesController.text.trim(),
                  ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: validator ??
            (value) => (value == null || value.trim().isEmpty)
                ? 'Required'
                : null,
      ),
    );
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    if (!text.contains('@')) return 'Enter a valid email';
    return null;
  }
}

class _CampaignDialog extends StatefulWidget {
  const _CampaignDialog({
    required this.snapshot,
    required this.selectedStudentIds,
    this.group,
  });

  final StudentModuleSnapshot snapshot;
  final Set<String> selectedStudentIds;
  final StudentGroupRecord? group;

  @override
  State<_CampaignDialog> createState() => _CampaignDialogState();
}

class _CampaignDialogState extends State<_CampaignDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  StudentCommunicationChannel _channel = StudentCommunicationChannel.inApp;
  String _audience = 'Selected students';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.group == null ? '' : '${widget.group!.name} update',
    );
    _bodyController = TextEditingController();
    if (widget.group != null) {
      _audience = widget.group!.name;
    } else if (widget.selectedStudentIds.isEmpty) {
      _audience = 'All students';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipients = widget.group != null
        ? widget.group!.memberIds
        : widget.selectedStudentIds.isEmpty
        ? widget.snapshot.students.map((item) => item.id).toList()
        : widget.selectedStudentIds.toList();

    return AlertDialog(
      title: const Text('Compose campaign'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _bodyController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Message body'),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<StudentCommunicationChannel>(
              initialValue: _channel,
              decoration: const InputDecoration(labelText: 'Channel'),
              items: [
                for (final channel in StudentCommunicationChannel.values)
                  DropdownMenuItem(
                    value: channel,
                    child: Text(channel.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _channel = value ?? _channel),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _audience,
              decoration: const InputDecoration(labelText: 'Audience'),
              items: [
                DropdownMenuItem(
                  value: widget.group?.name ?? 'Selected students',
                  child: Text(widget.group?.name ?? 'Selected students'),
                ),
                if (widget.group == null)
                  const DropdownMenuItem(
                    value: 'All students',
                    child: Text('All students'),
                  ),
              ],
              onChanged: (value) => setState(() => _audience = value ?? _audience),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty ||
                _bodyController.text.trim().isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              _CampaignDialogResult(
                title: _titleController.text.trim(),
                body: _bodyController.text.trim(),
                channel: _channel,
                audienceLabel: _audience,
                recipientStudentIds: recipients,
                groupId: widget.group?.id,
              ),
            );
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _CampaignDialogResult {
  const _CampaignDialogResult({
    required this.title,
    required this.body,
    required this.channel,
    required this.audienceLabel,
    required this.recipientStudentIds,
    this.groupId,
  });

  final String title;
  final String body;
  final StudentCommunicationChannel channel;
  final String audienceLabel;
  final List<String> recipientStudentIds;
  final String? groupId;
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

List<StudentProfile> _filterStudents(
  List<StudentProfile> students,
  StudentFilters filters,
) {
  return students.where((student) {
    final query = filters.query.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        student.fullName.toLowerCase().contains(query) ||
        student.studentNumber.toLowerCase().contains(query) ||
        student.contact.email.toLowerCase().contains(query) ||
        student.department.toLowerCase().contains(query) ||
        student.courses.any((course) => course.title.toLowerCase().contains(query));

    final matchesDepartment =
        filters.department == 'All departments' ||
        student.department == filters.department;
    final matchesYear =
        filters.year == 'All years' || student.year.toString() == filters.year;
    final matchesStatus =
        filters.enrollmentStatus == 'All statuses' ||
        student.enrollmentStatus.label == filters.enrollmentStatus;
    final matchesGpa = switch (filters.gpaBand) {
      'High (3.5+)' => student.gpa >= 3.5,
      'Stable (2.5-3.49)' => student.gpa >= 2.5 && student.gpa < 3.5,
      'Low (<2.5)' => student.gpa < 2.5,
      _ => true,
    };
    final matchesAttendance = switch (filters.attendanceBand) {
      'Excellent (90%+)' => student.attendanceRate >= 90,
      'Stable (80-89%)' =>
        student.attendanceRate >= 80 && student.attendanceRate < 90,
      'At risk (<80%)' => student.attendanceRate < 80,
      _ => true,
    };
    final matchesCourse =
        filters.course == 'All courses' ||
        student.courses.any((course) => course.title == filters.course);
    return matchesQuery &&
        matchesDepartment &&
        matchesYear &&
        matchesStatus &&
        matchesGpa &&
        matchesAttendance &&
        matchesCourse;
  }).toList(growable: false);
}

List<StudentActivityRecord> _filterActivities(
  StudentModuleSnapshot? snapshot,
  StudentFilters filters,
  List<StudentProfile> visibleStudents,
) {
  final visibleIds = visibleStudents.map((item) => item.id).toSet();
  return (snapshot?.allActivities ?? const []).where((activity) {
    final matchesVisibleStudent = visibleIds.contains(activity.studentId);
    final matchesType =
        filters.activityType == 'All activity' ||
        activity.type.label == filters.activityType;
    final matchesCourse =
        filters.course == 'All courses' ||
        activity.courseTitle == null ||
        activity.courseTitle == filters.course;
    return matchesVisibleStudent && matchesType && matchesCourse;
  }).toList(growable: false);
}

List<StudentProfile> _sortStudents(
  List<StudentProfile> students,
  String sortColumn,
  bool ascending,
) {
  final items = [...students];
  items.sort((left, right) {
    final factor = ascending ? 1 : -1;
    final result = switch (sortColumn) {
      'department' => left.department.compareTo(right.department),
      'attendance' => left.attendanceRate.compareTo(right.attendanceRate),
      'gpa' => left.gpa.compareTo(right.gpa),
      'status' => left.enrollmentStatus.label.compareTo(right.enrollmentStatus.label),
      _ => left.fullName.compareTo(right.fullName),
    };
    return result * factor;
  });
  return items;
}

StudentProfile? _resolveSelectedStudent(
  StudentModuleSnapshot? snapshot,
  List<StudentProfile> visibleStudents,
  String? selectedStudentId,
) {
  if (visibleStudents.isEmpty) return null;
  final selected = visibleStudents.where((item) => item.id == selectedStudentId);
  if (selected.isNotEmpty) return selected.first;
  return snapshot?.findStudent(selectedStudentId) ?? visibleStudents.first;
}

String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

extension<T> on List<T> {
  T? get singleOrNull => length == 1 ? this[0] : null;

  T? get firstOrNull => isEmpty ? null : first;
}
