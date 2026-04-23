import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../models/results_models.dart';
import '../state/results_actions.dart';
import 'widgets/grade_table_widget.dart';

class GradeEntryPage extends StatefulWidget {
  const GradeEntryPage({super.key, required this.subjectId});

  final int subjectId;

  @override
  State<GradeEntryPage> createState() => _GradeEntryPageState();
}

class _GradeEntryPageState extends State<GradeEntryPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};
  String? _selectedCategoryKey;

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _GradeEntryVm>(
      onInit: (store) => store.dispatch(LoadSubjectResultsAction(widget.subjectId)),
      converter: (store) => _GradeEntryVm.fromStore(store, widget.subjectId),
      builder: (context, vm) {
        if (vm.user == null) {
          return const SizedBox.shrink();
        }

        final result = vm.state.data;
        if (result != null &&
            (_selectedCategoryKey == null ||
                !result.categories.any((item) => item.key == _selectedCategoryKey))) {
          final editable = result.categories
              .where((category) => category.isEditable)
              .toList(growable: false);
          _selectedCategoryKey = editable.isEmpty ? null : editable.first.key;
        }

        return DoctorAssistantShell(
          user: vm.user!,
          activeRoute: '/workspace/results',
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: 'Grade Entry',
            subtitle:
                'Fast entry, draft save, validation, and publish review flow for role-allowed grading categories.',
            breadcrumbs: const ['Workspace', 'Results', 'Grade Entry'],
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _GradeEntryVm vm) {
    final result = vm.state.data;
    if (vm.state.status == ViewStatus.loading && result == null) {
      return const LoadingStateView(lines: 3);
    }
    if (vm.state.status == ViewStatus.failure && result == null) {
      return ErrorStateView(
        message: vm.state.error ?? 'Unable to load grade entry view.',
        onRetry: vm.reload,
      );
    }
    if (result == null) {
      return const EmptyStateView(
        title: 'No gradebook available',
        message: 'Grade rows will appear here once the selected subject is loaded.',
      );
    }

    final editableCategories =
        result.categories.where((category) => category.isEditable).toList();
    if (editableCategories.isEmpty) {
      return const EmptyStateView(
        title: 'View only',
        message:
            'This role can review the gradebook, but there are no editable categories in the current workflow.',
      );
    }
    final selectedCategory = editableCategories.firstWhere(
      (category) => category.key == _selectedCategoryKey,
      orElse: () => editableCategories.first,
    );
    final query = _searchController.text.trim().toLowerCase();
    final students = result.students
        .where((student) {
          if (query.isEmpty) {
            return true;
          }
          return student.studentName.toLowerCase().contains(query) ||
              student.studentCode.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                initialValue: selectedCategory.key,
                decoration: const InputDecoration(labelText: 'Category'),
                items: editableCategories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category.key,
                        child: Text(category.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryKey = value;
                    _controllers.clear();
                  });
                },
              ),
            ),
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search student by name or code',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GradeTableWidget(
          students: students,
          category: selectedCategory,
          controllers: _controllers,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            PremiumButton(
              label: 'Save draft',
              icon: Icons.save_outlined,
              isSecondary: true,
              onPressed: () => _submit(vm.store, selectedCategory, publish: false),
            ),
            PremiumButton(
              label: 'Publish grades',
              icon: Icons.publish_rounded,
              onPressed: () => _submit(vm.store, selectedCategory, publish: true),
            ),
          ],
        ),
      ],
    );
  }

  void _submit(
    Store<DoctorAssistantAppState> store,
    GradeCategoryModel category, {
    required bool publish,
  }) {
    final entries = _controllers.entries
        .map(
          (entry) => <String, dynamic>{
            'student_code': entry.key,
            'score': double.tryParse(entry.value.text.trim()),
          },
        )
        .toList(growable: false);
    final action = publish
        ? PublishGradesAction(
            subjectId: widget.subjectId,
            payload: <String, dynamic>{
              'category_key': category.key,
              'max_score': category.maxScore,
              'entries': entries,
            },
          )
        : SaveGradesDraftAction(
            subjectId: widget.subjectId,
            payload: <String, dynamic>{
              'category_key': category.key,
              'max_score': category.maxScore,
              'entries': entries,
            },
          );
    store.dispatch(action);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          publish ? 'Grades published for ${category.label}.' : 'Draft saved for ${category.label}.',
        ),
      ),
    );
  }
}

class _GradeEntryVm {
  const _GradeEntryVm({
    required this.user,
    required this.state,
    required this.reload,
    required this.store,
  });

  final dynamic user;
  final AsyncState<SubjectResultsModel> state;
  final VoidCallback reload;
  final Store<DoctorAssistantAppState> store;

  factory _GradeEntryVm.fromStore(Store<DoctorAssistantAppState> store, int subjectId) {
    return _GradeEntryVm(
      user: getCurrentUser(store.state),
      state: store.state.resultsState.subject,
      reload: () => store.dispatch(LoadSubjectResultsAction(subjectId)),
      store: store,
    );
  }
}
