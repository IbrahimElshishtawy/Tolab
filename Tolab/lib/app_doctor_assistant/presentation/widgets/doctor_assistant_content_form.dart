import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../app_admin/core/responsive/app_breakpoints.dart';
import '../../../app_admin/core/spacing/app_spacing.dart';
import '../../core/models/session_user.dart';
import '../../core/navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../widgets/doctor_assistant_shell.dart';
import '../widgets/doctor_assistant_widgets.dart';
import '../../modules/auth/state/session_selectors.dart';

class DoctorAssistantContentFormScreen extends StatefulWidget {
  const DoctorAssistantContentFormScreen({
    super.key,
    required this.route,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.primaryActionLabel,
    required this.subjectHint,
    required this.scopeHint,
    required this.scheduleHint,
  });

  final String route;
  final String pageTitle;
  final String pageSubtitle;
  final String primaryActionLabel;
  final String subjectHint;
  final String scopeHint;
  final String scheduleHint;

  @override
  State<DoctorAssistantContentFormScreen> createState() =>
      _DoctorAssistantContentFormScreenState();
}

class _DoctorAssistantContentFormScreenState
    extends State<DoctorAssistantContentFormScreen> {
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
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) return const SizedBox.shrink();

        final isCompact = AppBreakpoints.isMobile(context);

        return DoctorAssistantShell(
          user: user,
          activeRoute: widget.route,
          child: DoctorAssistantPageScaffold(
            title: widget.pageTitle,
            subtitle: widget.pageSubtitle,
            breadcrumbs: const ['Workspace', 'Create'],
            child: DoctorAssistantFormLayout(
              title: widget.pageTitle,
              subtitle: widget.pageSubtitle,
              formKey: _formKey,
              primaryLabel: widget.primaryActionLabel,
              secondaryLabel: 'Back to subjects',
              onSecondaryTap: () => context.go(AppRoutes.subjects),
              onSubmit: _submit,
              children: [
                if (isCompact) ..._stackedFields() else ..._wideFields(),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText:
                        'Add compact internal notes or student instructions',
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.pageTitle} saved to local mock state.')),
    );
  }
}
