import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/core/widgets/app_card.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../models/results_models.dart';
import '../state/results_actions.dart';
import 'widgets/grading_summary_cards.dart';

class SubjectResultsPage extends StatelessWidget {
  const SubjectResultsPage({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SubjectResultsVm>(
      onInit: (store) => store.dispatch(LoadSubjectResultsAction(subjectId)),
      converter: (store) => _SubjectResultsVm.fromStore(store, subjectId),
      builder: (context, vm) {
        if (vm.user == null) {
          return const SizedBox.shrink();
        }

        return DoctorAssistantShell(
          user: vm.user!,
          activeRoute: AppRoutes.results,
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: context.l10n.byValue('Subject Results'),
            subtitle: context.l10n.byValue(
                'View grade structure, recent activity, and role-based grading controls for the selected subject.'),
            breadcrumbs: ['Workspace', 'Results', 'Subject'].map((s) => context.l10n.byValue(s)).toList(),
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _SubjectResultsVm vm) {
    final results = vm.state.data;
    if (vm.state.status == ViewStatus.loading && results == null) {
      return const LoadingStateView(lines: 3);
    }
    if (vm.state.status == ViewStatus.failure && results == null) {
      return ErrorStateView(
        message: context.l10n.byValue(vm.state.error ?? 'Unable to load subject results.'),
        onRetry: vm.reload,
      );
    }
    if (results == null) {
      return EmptyStateView(
        title: context.l10n.byValue('No subject results'),
        message: context.l10n.byValue('Grading categories will appear here once result data is available.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${results.subjectCode} · ${context.l10n.byValue(results.subjectName)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            PremiumButton(
              label: context.l10n.byValue('Manage grades'),
              icon: Icons.table_rows_rounded,
              onPressed: () => context.go(AppRoutes.gradeEntry(subjectId)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GradingSummaryCards(analytics: results.analytics),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: results.categories
              .map(
                (category) => SizedBox(
                  width: 280,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.byValue(category.label),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            StatusBadge(category.statusLabel),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${context.l10n.byValue('Average')} ${category.averageScore.toStringAsFixed(1)} / ${category.maxScore.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.l10n
                              .byValue('{graded} graded · {missing} missing')
                              .replaceAll('{graded}', category.gradedCount.toString())
                              .replaceAll('{missing}', category.missingCount.toString()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.l10n.byValue(category.isEditable ? 'Editable for this role' : 'View only for this role'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: AppSpacing.md),
        DoctorAssistantPanel(
          title: 'Uploaded Grade Sheets',
          subtitle: 'Official grades sheets, Excel, PDF or CSV files shared with students.',
          trailing: PremiumButton(
            label: context.l10n.byValue('Upload Grade File'),
            icon: Icons.upload_file_rounded,
            onPressed: () => _showUploadDialog(context, vm.store, results),
          ),
          child: results.uploadedSheets.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(
                    child: Text(
                      context.l10n.byValue('No files uploaded yet for this subject.'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ),
                )
              : Column(
                  children: results.uploadedSheets
                      .map(
                        (file) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: DoctorAssistantItemCard(
                            icon: Icons.insert_drive_file_outlined,
                            title: file.name,
                            subtitle: '${file.mimeType} · ${file.sizeLabel}',
                            meta: file.url,
                            statusLabel: 'Uploaded',
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        DoctorAssistantPanel(
          title: 'Recent grading activity',
          subtitle:
              'Recent draft, review, and published actions attached to this subject.',
          child: Column(
            children: results.recentActivity
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: DoctorAssistantItemCard(
                      icon: Icons.grading_rounded,
                      title: activity.title,
                      subtitle: activity.subtitle,
                      meta: activity.createdAt.toIso8601String(),
                      statusLabel: activity.statusLabel,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Future<void> _showUploadDialog(
    BuildContext context,
    Store<DoctorAssistantAppState> store,
    SubjectResultsModel results,
  ) async {
    final categories = results.categories;
    if (categories.isEmpty) return;

    String selectedKey = categories.first.key;

    final categoryKey = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.l10n.byValue('Select Category for Upload')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.byValue('Choose the grading category this sheet belongs to:')),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: selectedKey,
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat.key,
                            child: Text(context.l10n.byValue(cat.label)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedKey = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(context.l10n.byValue('Cancel')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, selectedKey),
                  child: Text(context.l10n.byValue('Proceed')),
                ),
              ],
            );
          },
        );
      },
    );

    if (categoryKey == null) return;

    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'csv', 'xlsx', 'xls'],
        withData: true,
      );

      if (pickerResult == null || pickerResult.files.isEmpty) return;

      final file = pickerResult.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      store.dispatch(UploadGradesFileAction(
        subjectId: results.subjectId,
        categoryKey: categoryKey,
        fileName: file.name,
        fileBytes: bytes,
      ));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.byValue('Uploading')} ${file.name}...'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.byValue('Failed to upload file')}: $e')),
      );
    }
  }
}

class _SubjectResultsVm {
  const _SubjectResultsVm({
    required this.user,
    required this.state,
    required this.reload,
    required this.store,
  });

  final dynamic user;
  final AsyncState<SubjectResultsModel> state;
  final VoidCallback reload;
  final Store<DoctorAssistantAppState> store;

  factory _SubjectResultsVm.fromStore(Store<DoctorAssistantAppState> store, int subjectId) {
    return _SubjectResultsVm(
      user: getCurrentUser(store.state),
      state: store.state.resultsState.subject,
      reload: () => store.dispatch(LoadSubjectResultsAction(subjectId)),
      store: store,
    );
  }
}
