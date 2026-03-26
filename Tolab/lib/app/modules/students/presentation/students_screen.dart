import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../models/student_admin_models.dart';
import '../state/students_state.dart';
import 'widgets/student_details_panel.dart';
import 'widgets/students_analytics_section.dart';
import 'widgets/students_bulk_action_bar.dart';
import 'widgets/students_feedback_state.dart';
import 'widgets/students_registry_section.dart';
import 'widgets/students_search_panel.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late final TextEditingController _searchController;
  String _query = '';
  String _department = 'All departments';
  String _batch = 'All batches';
  String _status = 'All statuses';
  String _segment = 'All students';
  String _gpaMode = 'Distribution';
  String _attendanceScope = 'All';
  String _subjectMode = 'Activity';
  String _interactionMode = 'Trend';
  bool _advancedOpen = false;
  String _sortBy = 'gpa';
  bool _sortAscending = false;
  String? _selectedStudentId;
  final Set<String> _selectedIds = <String>{};

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
    return StoreConnector<AppState, StudentsState>(
      onInit: (store) => store.dispatch(LoadStudentsAction()),
      converter: (store) => store.state.studentsState,
      builder: (context, state) {
        final filtered = _filteredStudents(state.items);
        final sorted = _sortedStudents(filtered);
        final selectedStudent = _resolveSelectedStudent(sorted);
        final showSidePanel = MediaQuery.sizeOf(context).width >= 1280;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Students Management',
              subtitle:
                  'Monitor academic health, attendance, permissions, credits, engagement, and course-registration readiness from one premium admin workspace.',
              breadcrumbs: ['Admin', 'Students Department', 'Students'],
              actions: [
                PremiumButton(
                  label: 'Import students',
                  icon: Icons.file_upload_outlined,
                  isSecondary: true,
                ),
                PremiumButton(
                  label: 'Add student',
                  icon: Icons.person_add_alt_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: _buildBody(
                context,
                state: state,
                students: sorted,
                selectedStudent: selectedStudent,
                showSidePanel: showSidePanel,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required StudentsState state,
    required List<StudentAdminRecord> students,
    required StudentAdminRecord? selectedStudent,
    required bool showSidePanel,
  }) {
    if (state.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.status == LoadStatus.failure) {
      return StudentsFeedbackState(
        title: 'Could not load students',
        subtitle: state.errorMessage ?? 'Try refreshing the module.',
        icon: Icons.error_outline_rounded,
        action: PremiumButton(
          label: 'Retry',
          icon: Icons.refresh_rounded,
          onPressed: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadStudentsAction()),
        ),
      );
    }

    if (students.isEmpty) {
      return StudentsFeedbackState(
        title: 'No students match these filters',
        subtitle:
            'Adjust the search terms or clear filters to bring students back into view.',
        icon: Icons.inbox_outlined,
        action: PremiumButton(
          label: 'Clear filters',
          icon: Icons.restart_alt_rounded,
          onPressed: _clearFilters,
        ),
      );
    }

    final mainColumn = ListView(
      children: [
        StudentsAnalyticsSection(
          students: students,
          gpaMode: _gpaMode,
          onGpaModeChanged: (value) => setState(() => _gpaMode = value),
          attendanceScope: _attendanceScope,
          onAttendanceScopeChanged: (value) =>
              setState(() => _attendanceScope = value),
          subjectMode: _subjectMode,
          onSubjectModeChanged: (value) => setState(() => _subjectMode = value),
          interactionMode: _interactionMode,
          onInteractionModeChanged: (value) =>
              setState(() => _interactionMode = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        StudentsSearchPanel(
          searchController: _searchController,
          query: _query,
          department: _department,
          batch: _batch,
          status: _status,
          segment: _segment,
          advancedOpen: _advancedOpen,
          onQueryChanged: (value) => setState(() => _query = value),
          onDepartmentChanged: (value) => setState(() => _department = value),
          onBatchChanged: (value) => setState(() => _batch = value),
          onStatusChanged: (value) => setState(() => _status = value),
          onSegmentChanged: (value) => setState(() => _segment = value),
          onToggleAdvanced: () =>
              setState(() => _advancedOpen = !_advancedOpen),
          onClear: _clearFilters,
        ),
        if (_selectedIds.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StudentsBulkActionBar(
            count: _selectedIds.length,
            onClear: () => setState(_selectedIds.clear),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        StudentsRegistrySection(
          students: students,
          selectedIds: _selectedIds,
          selectedStudentId: selectedStudent?.id,
          sortBy: _sortBy,
          sortAscending: _sortAscending,
          onSelectAll: (value) {
            setState(() {
              if (value) {
                _selectedIds
                  ..clear()
                  ..addAll(students.map((student) => student.id));
              } else {
                _selectedIds.clear();
              }
            });
          },
          onToggleSelection: (id, selected) {
            setState(() {
              if (selected) {
                _selectedIds.add(id);
              } else {
                _selectedIds.remove(id);
              }
            });
          },
          onSort: (column) {
            setState(() {
              if (_sortBy == column) {
                _sortAscending = !_sortAscending;
              } else {
                _sortBy = column;
                _sortAscending = column == 'student';
              }
            });
          },
          onOpenStudent: (student) =>
              _handleOpenStudent(student, showSidePanel),
        ),
      ],
    );

    if (!showSidePanel || selectedStudent == null) {
      return mainColumn;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: mainColumn),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 430,
          child: SingleChildScrollView(
            child: StudentDetailsPanel(
              student: selectedStudent,
              selectedCount: _selectedIds.length,
            ),
          ),
        ),
      ],
    );
  }

  void _handleOpenStudent(StudentAdminRecord student, bool showSidePanel) {
    setState(() => _selectedStudentId = student.id);
    if (showSidePanel) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final deviceType = AppBreakpoints.resolve(context);
        final maxHeight = deviceType == DeviceScreenType.mobile ? 0.92 : 0.82;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: maxHeight,
          maxChildSize: 0.96,
          minChildSize: 0.60,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: StudentDetailsPanel(
                student: student,
                selectedCount: _selectedIds.length,
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          },
        );
      },
    );
  }

  List<StudentAdminRecord> _filteredStudents(
    List<StudentAdminRecord> students,
  ) {
    return students.where((student) {
      final matchesQuery =
          _query.isEmpty ||
          student.fullName.toLowerCase().contains(_query.toLowerCase()) ||
          student.id.toLowerCase().contains(_query.toLowerCase()) ||
          student.nationalId.contains(_query) ||
          student.email.toLowerCase().contains(_query.toLowerCase());
      final matchesDepartment =
          _department == 'All departments' || student.department == _department;
      final matchesBatch = _batch == 'All batches' || student.batch == _batch;
      final matchesStatus =
          _status == 'All statuses' || student.status == _status;
      final matchesSegment = switch (_segment) {
        'At risk' => student.isAtRisk,
        'Graduation ready' => student.remainingCreditHours <= 30,
        _ => true,
      };
      return matchesQuery &&
          matchesDepartment &&
          matchesBatch &&
          matchesStatus &&
          matchesSegment;
    }).toList();
  }

  List<StudentAdminRecord> _sortedStudents(List<StudentAdminRecord> students) {
    final sorted = [...students];
    sorted.sort((left, right) {
      final factor = _sortAscending ? 1 : -1;
      final result = switch (_sortBy) {
        'student' => left.fullName.compareTo(right.fullName),
        'academic' => '${left.department}${left.academicLevel}'.compareTo(
          '${right.department}${right.academicLevel}',
        ),
        'attendance' => left.attendanceRate.compareTo(right.attendanceRate),
        'credits' => left.earnedCreditHours.compareTo(right.earnedCreditHours),
        _ => left.cumulativeGpa.compareTo(right.cumulativeGpa),
      };
      return result * factor;
    });
    return sorted;
  }

  StudentAdminRecord? _resolveSelectedStudent(
    List<StudentAdminRecord> students,
  ) {
    if (students.isEmpty) return null;
    final selected = students.where(
      (student) => student.id == _selectedStudentId,
    );
    if (selected.isNotEmpty) return selected.first;
    return students.first;
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _department = 'All departments';
      _batch = 'All batches';
      _status = 'All statuses';
      _segment = 'All students';
      _advancedOpen = false;
      _attendanceScope = 'All';
      _selectedIds.clear();
      _searchController.clear();
    });
  }
}
