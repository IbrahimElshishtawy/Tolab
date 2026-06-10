import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/page_header.dart';
import '../../../shared/forms/app_dropdown_field.dart';
import '../../../shared/forms/app_text_field.dart';
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
                          context.l10n.byValue('Posts controls opened for'),
                        ),
                        onManageGroup: _focusAndToast(
                          context.l10n.byValue('Group controls opened for'),
                        ),
                        onManageSummaries: _focusAndToast(
                          context.l10n.byValue('Summaries workspace opened for'),
                        ),
                        onViewStudents: _focusAndToast(
                          context.l10n.byValue('Student list opened for'),
                        ),
                        onGenerateAccess: _focusAndToast(
                          context.l10n.byValue('Access controls prepared for'),
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
              title: context.l10n.byValue('Subjects / Course Management'),
              subtitle: context.l10n.byValue(
                  'Premium university control center for subject setup, staff assignment, privacy-safe student visibility, groups, posts, summaries, and secure access flows.'),
              breadcrumbs: ['Admin', 'Academic', 'Subjects']
                  .map((b) => context.l10n.byValue(b))
                  .toList(),
              actions: [
                PremiumButton(
                  label: context.l10n.byValue('Create Group Space'),
                  icon: Icons.forum_outlined,
                  isSecondary: true,
                  onPressed: () => _openCreateGroupDialog(context, subjects),
                ),
                PremiumButton(
                  label: context.l10n.byValue('Add Subject'),
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
                        _toast(context.l10n.byValue('Select a subject first'));
                      }
                    },
                    onCreateGroup: () => _openCreateGroupDialog(context, subjects),
                    onManagePosts: () => _toast(context.l10n.byValue('Posts management opened')),
                    onManageSummaries: () =>
                        _toast(context.l10n.byValue('Summaries management opened')),
                    onGenerateCode: () =>
                        _toast(context.l10n.byValue('Access code regenerated preview')),
                    onGenerateLink: () =>
                        _toast(context.l10n.byValue('Access link regenerated preview')),
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
      _toast('$message ${context.l10n.byValue(subject.name)}');
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

  void _openCreateGroupDialog(BuildContext context, List<SubjectRecord> subjects) {
    if (subjects.isEmpty) {
      _toast(context.l10n.byValue('No subjects available to create group for'));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(28),
        backgroundColor: Colors.transparent,
        child: _CreateGroupFormDialog(
          subjects: subjects,
          onCreated: (subjectId, groupName) {
            StoreProvider.of<AppState>(context).dispatch(
              CreateGroupAction(subjectId: subjectId, groupName: groupName),
            );
            final sub = subjects.firstWhereOrNull((s) => s.id == subjectId);
            final subName = sub != null ? context.l10n.byValue(sub.name) : '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${context.l10n.byValue('Group space created successfully for')} $subName',
                ),
              ),
            );
          },
        ),
      ),
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

class _CreateGroupFormDialog extends StatefulWidget {
  const _CreateGroupFormDialog({required this.subjects, required this.onCreated});

  final List<SubjectRecord> subjects;
  final Function(String subjectId, String groupName) onCreated;

  @override
  State<_CreateGroupFormDialog> createState() => _CreateGroupFormDialogState();
}

class _CreateGroupFormDialogState extends State<_CreateGroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.subjects.firstOrNull?.id ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.byValue('Please select a subject'))),
      );
      return;
    }
    widget.onCreated(_selectedSubjectId, _nameController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 480),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Material(
                color: Theme.of(context).cardColor.withValues(alpha: 0.94),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.byValue('Create Group Space'),
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.l10n.byValue('Set up a discussion space for students in a specific subject.'),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: AppTextField(
                                    controller: _nameController,
                                    label: context.l10n.byValue('Group Name'),
                                    hint: context.l10n.byValue('Distributed Systems Study Lounge'),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return context.l10n.byValue('Group Name is required');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: AppDropdownField<String>(
                                    label: context.l10n.byValue('Subject'),
                                    value: _selectedSubjectId,
                                    onChanged: (val) => setState(() => _selectedSubjectId = val ?? _selectedSubjectId),
                                    items: [
                                      for (final sub in widget.subjects)
                                        AppDropdownItem(
                                          value: sub.id,
                                          label: '${sub.code} - ${context.l10n.byValue(sub.name)}',
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: AppTextField(
                                    controller: _descriptionController,
                                    label: context.l10n.byValue('Description'),
                                    hint: context.l10n.byValue('Group for homework, course announcements, and peer support.'),
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(context.l10n.byValue('Cancel')),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            PremiumButton(
                              label: context.l10n.byValue('Create Group'),
                              icon: Icons.check_circle_outline_rounded,
                              onPressed: _submitForm,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
