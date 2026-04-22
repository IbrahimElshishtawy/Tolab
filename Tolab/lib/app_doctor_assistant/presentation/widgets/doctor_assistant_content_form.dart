import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../app_admin/core/responsive/app_breakpoints.dart';
import '../../../app_admin/core/spacing/app_spacing.dart';
import '../../core/models/session_user.dart';
import '../../core/state/async_state.dart';
import '../../core/widgets/state_views.dart';
import '../../state/app_state.dart';
import '../../modules/auth/state/session_selectors.dart';
import '../widgets/doctor_assistant_shell.dart';
import '../widgets/doctor_assistant_widgets.dart';

typedef ContentStateSelector<T> =
    AsyncState<List<T>> Function(DoctorAssistantAppState state);
typedef ContentLoadDispatcher =
    void Function(Store<DoctorAssistantAppState> store);
typedef ContentSaveDispatcher = void Function(
  Store<DoctorAssistantAppState> store,
  Map<String, dynamic> payload,
);
typedef ContentTextBuilder<T> = String Function(T item);

class DoctorAssistantContentFormScreen<T> extends StatefulWidget {
  const DoctorAssistantContentFormScreen({
    super.key,
    required this.route,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.primaryActionLabel,
    required this.subjectHint,
    required this.scopeHint,
    required this.scheduleHint,
    required this.stateSelector,
    required this.onLoad,
    required this.onSave,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.itemMeta,
    required this.itemStatusLabel,
    required this.itemIcon,
    required this.existingPanelTitle,
    required this.existingPanelSubtitle,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final String route;
  final String pageTitle;
  final String pageSubtitle;
  final String primaryActionLabel;
  final String subjectHint;
  final String scopeHint;
  final String scheduleHint;
  final ContentStateSelector<T> stateSelector;
  final ContentLoadDispatcher onLoad;
  final ContentSaveDispatcher onSave;
  final ContentTextBuilder<T> itemTitle;
  final ContentTextBuilder<T> itemSubtitle;
  final ContentTextBuilder<T> itemMeta;
  final ContentTextBuilder<T> itemStatusLabel;
  final IconData itemIcon;
  final String existingPanelTitle;
  final String existingPanelSubtitle;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  State<DoctorAssistantContentFormScreen<T>> createState() =>
      _DoctorAssistantContentFormScreenState<T>();
}

class _DoctorAssistantContentFormScreenState<T>
    extends State<DoctorAssistantContentFormScreen<T>> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subjectController;
  late final TextEditingController _scopeController;
  late final TextEditingController _scheduleController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subjectController = TextEditingController();
    _scopeController = TextEditingController();
    _scheduleController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _scopeController.dispose();
    _scheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _ContentManagerVm<T>>(
      onInit: widget.onLoad,
      converter: (store) => _ContentManagerVm<T>(
        user: getCurrentUser(store.state),
        state: widget.stateSelector(store.state),
        save: (payload) => widget.onSave(store, payload),
        reload: () => widget.onLoad(store),
      ),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        final isCompact = AppBreakpoints.isMobile(context);

        return DoctorAssistantShell(
          user: user,
          activeRoute: widget.route,
          child: DoctorAssistantPageScaffold(
            title: widget.pageTitle,
            subtitle: widget.pageSubtitle,
            breadcrumbs: const ['Workspace', 'Create'],
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = !isCompact && constraints.maxWidth >= 1080;
                final listPanel = DoctorAssistantPanel(
                  title: widget.existingPanelTitle,
                  subtitle: widget.existingPanelSubtitle,
                  child: _buildRecordsPanel(vm),
                );
                final formPanel = DoctorAssistantPanel(
                  title: 'Compose',
                  subtitle:
                      'The form is backend-ready but currently persists only to the local mock repositories.',
                  child: DoctorAssistantFormLayout(
                    title: widget.pageTitle,
                    subtitle: widget.pageSubtitle,
                    formKey: _formKey,
                    primaryLabel: widget.primaryActionLabel,
                    secondaryLabel: 'Back to subjects',
                    onSecondaryTap: () => Navigator.of(context).maybePop(),
                    onSubmit: () => _submit(vm),
                    maxWidth: double.infinity,
                    children: [
                      if (isCompact) ..._stackedFields() else ..._wideFields(),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText:
                              'Add faculty notes, room details, or student-facing instructions',
                        ),
                      ),
                    ],
                  ),
                );

                if (!isWide) {
                  return Column(
                    children: [
                      formPanel,
                      const SizedBox(height: AppSpacing.md),
                      listPanel,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: formPanel),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(flex: 6, child: listPanel),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordsPanel(_ContentManagerVm<T> vm) {
    if (vm.state.status == ViewStatus.loading && (vm.state.data?.isEmpty ?? true)) {
      return const LoadingStateView(lines: 3);
    }

    if (vm.state.status == ViewStatus.failure && (vm.state.data?.isEmpty ?? true)) {
      return ErrorStateView(
        message: vm.state.error ?? 'Unable to load local mock records.',
        onRetry: vm.reload,
      );
    }

    final items = vm.state.data ?? <T>[];
    if (items.isEmpty) {
      return DoctorAssistantEmptyState(
        title: widget.emptyTitle,
        subtitle: widget.emptySubtitle,
      );
    }

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: DoctorAssistantItemCard(
            icon: widget.itemIcon,
            title: widget.itemTitle(item),
            subtitle: widget.itemSubtitle(item),
            meta: widget.itemMeta(item),
            statusLabel: widget.itemStatusLabel(item),
          ),
        );
      }).toList(growable: false),
    );
  }

  List<Widget> _wideFields() {
    return [
      Row(
        children: [
          Expanded(child: _buildTitleField()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildSubjectField()),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(child: _buildScopeField()),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildScheduleField()),
        ],
      ),
    ];
  }

  List<Widget> _stackedFields() {
    return [
      _buildTitleField(),
      const SizedBox(height: AppSpacing.md),
      _buildSubjectField(),
      const SizedBox(height: AppSpacing.md),
      _buildScopeField(),
      const SizedBox(height: AppSpacing.md),
      _buildScheduleField(),
    ];
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      validator: _requiredField,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'Enter a concise internal title',
      ),
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      validator: _requiredField,
      decoration: InputDecoration(
        labelText: 'Subject',
        hintText: widget.subjectHint,
      ),
    );
  }

  Widget _buildScopeField() {
    return TextFormField(
      controller: _scopeController,
      validator: _requiredField,
      decoration: InputDecoration(
        labelText: 'Audience / Scope',
        hintText: widget.scopeHint,
      ),
    );
  }

  Widget _buildScheduleField() {
    return TextFormField(
      controller: _scheduleController,
      validator: _requiredField,
      decoration: InputDecoration(
        labelText: 'Schedule',
        hintText: widget.scheduleHint,
      ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _submit(_ContentManagerVm<T> vm) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    vm.save(<String, dynamic>{
      'title': _titleController.text.trim(),
      'subject': _subjectController.text.trim(),
      'scope': _scopeController.text.trim(),
      'schedule': _scheduleController.text.trim(),
      'notes': _notesController.text.trim(),
    });

    _titleController.clear();
    _subjectController.clear();
    _scopeController.clear();
    _scheduleController.clear();
    _notesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.pageTitle} saved to local mock data.')),
    );
  }
}

class _ContentManagerVm<T> {
  const _ContentManagerVm({
    required this.user,
    required this.state,
    required this.save,
    required this.reload,
  });

  final SessionUser? user;
  final AsyncState<List<T>> state;
  final void Function(Map<String, dynamic> payload) save;
  final VoidCallback reload;
}
