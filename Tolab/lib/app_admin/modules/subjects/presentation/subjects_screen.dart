import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/widgets/async_state_view.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../state/app_state.dart';
import '../models/subject_management_models.dart';
import 'forms/subject_form_sheet.dart';
import 'responsive/subjects_layout.dart';
import 'widgets/grouped_subjects_section.dart';
import 'widgets/subject_details_panel.dart';
import 'widgets/subject_primitives.dart';
import 'widgets/subjects_analytics_section.dart';
import 'widgets/subjects_list_section.dart';
import 'widgets/subjects_search_actions_panel.dart';
import '../state/subjects_state.dart';
import 'design/subjects_management_tokens.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _searchQuery = '';
  String? _department;
  String? _academicYear;
  String? _status;
  String? _doctor;
  String? _assistant;
  String? _selectedSubjectId;
  SubjectsViewMode _viewMode = SubjectsViewMode.table;
  SubjectsGroupBy _groupBy = SubjectsGroupBy.department;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SubjectsState>(
      onInit: (store) => store.dispatch(LoadSubjectsAction()),
      converter: (store) => store.state.subjectsState,
      builder: (context, state) {
        final subjects = state.items;
        final filteredSubjects = _filterSubjects(subjects);
        final selectedSubject =
            filteredSubjects.firstWhereOrNull(
              (subject) => subject.id == _selectedSubjectId,
            ) ??
            filteredSubjects.firstOrNull;

        final departments =
            subjects.map((subject) => subject.department).toSet().toList()
              ..sort();
        final academicYears =
            subjects.map((subject) => subject.academicYear).toSet().toList()
              ..sort();
        final statuses =
            subjects.map((subject) => subject.status).toSet().toList()..sort();
        final doctors =
            subjects.map((subject) => subject.doctor.name).toSet().toList()
              ..sort();
        final assistants =
            subjects.map((subject) => subject.assistant.name).toSet().toList()
              ..sort();

        final content = AsyncStateView(
          status: state.status,
          errorMessage: state.errorMessage,
          onRetry: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LoadSubjectsAction()),
          isEmpty: subjects.isEmpty,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showSidePanel = SubjectsLayout.showSidePanel(context);
              final mainSection = SubjectAnimatedSwitch(
                switchKey: _viewMode,
                child: _viewMode == SubjectsViewMode.table
                    ? SubjectsListSection(
                        subjects: filteredSubjects,
                        selectedSubject: selectedSubject,
                        onSubjectSelected: _selectSubject,
                        onEditSubject: _openEditSubject,
                        onManagePermissions: _focusSubject,
                        onManagePosts: _focusAndToast(
                          'Posts controls opened for',
                        ),
                        onManageGroup: _focusAndToast(
                          'Group controls opened for',
                        ),
                        onManageSummaries: _focusAndToast(
                          'Summaries workspace opened for',
                        ),
                        onViewStudents: _focusAndToast(
                          'Student list opened for',
                        ),
                        onGenerateAccess: _focusAndToast(
                          'Access controls prepared for',
                        ),
                      )
                    : GroupedSubjectsSection(
                        subjects: filteredSubjects,
                        groupBy: _groupBy,
                        onGroupByChanged: (value) =>
                            setState(() => _groupBy = value),
                        onSubjectSelected: _selectSubject,
                      ),
              );

              final details = SubjectDetailsPanel(
                subject: selectedSubject,
                onEdit: selectedSubject == null
                    ? null
                    : () => _openEditSubject(selectedSubject),
              );

              if (!showSidePanel) {
                return ListView(
                  children: [
                    mainSection,
                    const SizedBox(height: AppSpacing.lg),
                    details,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 8, child: mainSection),
                  const SizedBox(width: AppSpacing.lg),
                  SizedBox(
                    width: SubjectsManagementSpacing.detailsPanelWidth,
                    child: details,
                  ),
                ],
              );
            },
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Subjects / Course Management',
              subtitle:
                  'Premium university control center for subject setup, staff assignment, privacy-safe student visibility, groups, posts, summaries, and secure access flows.',
              breadcrumbs: const ['Admin', 'Academic', 'Subjects'],
              actions: [
                PremiumButton(
                  label: 'Create Group Space',
                  icon: Icons.forum_outlined,
                  isSecondary: true,
                  onPressed: () =>
                      _toast('Subject group/community flow opened'),
                ),
                PremiumButton(
                  label: 'Add Subject',
                  icon: Icons.add_rounded,
                  onPressed: () => _openSubjectForm(
                    departments: departments,
                    academicYears: academicYears,
                    doctors: doctors,
                    assistants: assistants,
                    statuses: statuses,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: ListView(
                children: [
                  SubjectsAnalyticsSection(subjects: subjects),
                  const SizedBox(height: AppSpacing.lg),
                  SubjectsSearchActionsPanel(
                    searchQuery: _searchQuery,
                    department: _department,
                    academicYear: _academicYear,
                    status: _status,
                    doctor: _doctor,
                    assistant: _assistant,
                    departments: departments,
                    academicYears: academicYears,
                    statuses: statuses,
                    doctors: doctors,
                    assistants: assistants,
                    viewMode: _viewMode,
                    onSearchChanged: (value) =>
                        setState(() => _searchQuery = value),
                    onDepartmentChanged: (value) =>
                        setState(() => _department = value),
                    onAcademicYearChanged: (value) =>
                        setState(() => _academicYear = value),
                    onStatusChanged: (value) => setState(() => _status = value),
                    onDoctorChanged: (value) => setState(() => _doctor = value),
                    onAssistantChanged: (value) =>
                        setState(() => _assistant = value),
                    onViewModeChanged: (value) =>
                        setState(() => _viewMode = value),
                    onAddSubject: () => _openSubjectForm(
                      departments: departments,
                      academicYears: academicYears,
                      doctors: doctors,
                      assistants: assistants,
                      statuses: statuses,
                    ),
                    onEditSubject: () {
                      if (selectedSubject != null) {
                        _openEditSubject(selectedSubject);
                      } else {
                        _toast('Select a subject first');
                      }
                    },
                    onCreateGroup: () =>
                        _toast('Group/community creation flow opened'),
                    onManagePosts: () => _toast('Posts management opened'),
                    onManageSummaries: () =>
                        _toast('Summaries management opened'),
                    onGenerateCode: () =>
                        _toast('Access code regenerated preview'),
                    onGenerateLink: () =>
                        _toast('Access link regenerated preview'),
                    onClearFilters: _clearFilters,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  content,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<SubjectRecord> _filterSubjects(List<SubjectRecord> subjects) {
    final query = _searchQuery.trim().toLowerCase();
    return subjects.where((subject) {
      final matchesQuery =
          query.isEmpty ||
          subject.name.toLowerCase().contains(query) ||
          subject.code.toLowerCase().contains(query) ||
          subject.department.toLowerCase().contains(query) ||
          subject.academicYear.toLowerCase().contains(query) ||
          subject.doctor.name.toLowerCase().contains(query) ||
          subject.assistant.name.toLowerCase().contains(query);
      final matchesDepartment =
          _department == null || subject.department == _department;
      final matchesAcademicYear =
          _academicYear == null || subject.academicYear == _academicYear;
      final matchesStatus = _status == null || subject.status == _status;
      final matchesDoctor = _doctor == null || subject.doctor.name == _doctor;
      final matchesAssistant =
          _assistant == null || subject.assistant.name == _assistant;

      return matchesQuery &&
          matchesDepartment &&
          matchesAcademicYear &&
          matchesStatus &&
          matchesDoctor &&
          matchesAssistant;
    }).toList();
  }

  void _selectSubject(SubjectRecord subject) {
    setState(() => _selectedSubjectId = subject.id);
  }

  void _focusSubject(SubjectRecord subject) {
    setState(() {
      _selectedSubjectId = subject.id;
    });
  }

  ValueChanged<SubjectRecord> _focusAndToast(String message) {
    return (subject) {
      _focusSubject(subject);
      _toast('$message ${subject.name}');
    };
  }

  Future<void> _openEditSubject(SubjectRecord subject) async {
    _focusSubject(subject);
    final state = StoreProvider.of<AppState>(context).state.subjectsState;
    await _openSubjectForm(
      subject: subject,
      departments: state.items.map((item) => item.department).toSet().toList()
        ..sort(),
      academicYears:
          state.items.map((item) => item.academicYear).toSet().toList()..sort(),
      doctors: state.items.map((item) => item.doctor.name).toSet().toList()
        ..sort(),
      assistants:
          state.items.map((item) => item.assistant.name).toSet().toList()
            ..sort(),
      statuses: state.items.map((item) => item.status).toSet().toList()..sort(),
    );
  }

  Future<void> _openSubjectForm({
    SubjectRecord? subject,
    required List<String> departments,
    required List<String> academicYears,
    required List<String> doctors,
    required List<String> assistants,
    required List<String> statuses,
  }) async {
    await SubjectFormSheet.open(
      context,
      subject: subject,
      departments: departments,
      academicYears: academicYears,
      doctors: doctors,
      assistants: assistants,
      statuses: statuses,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _department = null;
      _academicYear = null;
      _status = null;
      _doctor = null;
      _assistant = null;
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
