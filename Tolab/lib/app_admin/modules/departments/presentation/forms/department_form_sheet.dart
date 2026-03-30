import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/department_models.dart';
import '../../state/departments_state.dart';

class DepartmentFormSheet extends StatefulWidget {
  const DepartmentFormSheet({
    super.key,
    this.initialDepartment,
    required this.faculties,
  });

  final DepartmentRecord? initialDepartment;
  final List<String> faculties;

  static Future<void> show(
    BuildContext context, {
    DepartmentRecord? initialDepartment,
    required List<String> faculties,
  }) async {
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(const ResetDepartmentMutationAction());

    final child = DepartmentFormSheet(
      initialDepartment: initialDepartment,
      faculties: faculties,
    );

    if (AppBreakpoints.isMobile(context)) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: FractionallySizedBox(heightFactor: 0.94, child: child),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: child,
        ),
      ),
    );
  }

  @override
  State<DepartmentFormSheet> createState() => _DepartmentFormSheetState();
}

class _DepartmentFormSheetState extends State<DepartmentFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  late String? _faculty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialDepartment?.name ?? '',
    );
    _codeController = TextEditingController(
      text: widget.initialDepartment?.code ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialDepartment?.description ?? '',
    );
    _isActive = widget.initialDepartment?.isActive ?? true;
    _faculty =
        widget.initialDepartment?.faculty ??
        (widget.faculties.isEmpty ? null : widget.faculties.first);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DepartmentFormViewModel>(
      converter: (store) => _DepartmentFormViewModel.fromStore(
        store,
        currentDepartmentId: widget.initialDepartment?.id,
      ),
      distinct: true,
      onDidChange: (previous, current) {
        if (!mounted || previous == null) return;
        if (previous.mutationStatus == LoadStatus.loading &&
            current.mutationStatus == LoadStatus.success) {
          Navigator.of(context).pop();
          if (current.message != null && current.message!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(current.message!)));
          }
          StoreProvider.of<AppState>(
            context,
          ).dispatch(const ResetDepartmentMutationAction());
        }
      },
      builder: (context, vm) {
        final isEditing = widget.initialDepartment != null;
        return AppCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
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
                            isEditing ? 'Edit department' : 'Create department',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Compact admin form with validation, loading, and production-safe updates.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: vm.isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Department name',
                            hintText: 'Computer Science',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Department name is required.';
                            }
                            if (value.trim().length < 3) {
                              return 'Use at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Department code',
                            hintText: 'CS',
                          ),
                          validator: (value) {
                            final code = value?.trim().toUpperCase() ?? '';
                            if (code.isEmpty) {
                              return 'Department code is required.';
                            }
                            if (code.length < 2) {
                              return 'Use at least 2 characters.';
                            }
                            final exists = vm.existingCodes.any(
                              (existing) => existing == code,
                            );
                            if (exists) {
                              return 'This code is already in use.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: _faculty,
                          onChanged: vm.isSaving
                              ? null
                              : (value) => setState(() => _faculty = value),
                          decoration: const InputDecoration(
                            labelText: 'Faculty',
                          ),
                          items: [
                            for (final faculty in widget.faculties)
                              DropdownMenuItem(
                                value: faculty,
                                child: Text(faculty),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText:
                                'Research focus, academic structure, and operational notes.',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Description is required.';
                            }
                            if (value.trim().length < 16) {
                              return 'Provide a slightly richer description.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Department status',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isActive
                                          ? 'Department is visible and operational.'
                                          : 'Department is disabled but kept in the system.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: vm.isSaving
                                    ? null
                                    : (value) =>
                                          setState(() => _isActive = value),
                              ),
                            ],
                          ),
                        ),
                        if (vm.message != null &&
                            vm.message!.isNotEmpty &&
                            vm.mutationStatus == LoadStatus.failure) ...[
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              vm.message!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        label: 'Cancel',
                        icon: Icons.close_rounded,
                        isSecondary: true,
                        onPressed: vm.isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: PremiumButton(
                        label: vm.isSaving
                            ? 'Saving...'
                            : isEditing
                            ? 'Save changes'
                            : 'Create department',
                        icon: isEditing
                            ? Icons.check_circle_outline_rounded
                            : Icons.apartment_rounded,
                        onPressed: vm.isSaving ? null : () => _submit(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final payload = DepartmentUpsertPayload(
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      description: _descriptionController.text.trim(),
      isActive: _isActive,
      faculty: _faculty,
    );
    final store = StoreProvider.of<AppState>(context);
    if (widget.initialDepartment == null) {
      store.dispatch(CreateDepartmentRequestedAction(payload));
      return;
    }
    store.dispatch(
      UpdateDepartmentRequestedAction(
        departmentId: widget.initialDepartment!.id,
        payload: payload,
      ),
    );
  }
}

class _DepartmentFormViewModel {
  const _DepartmentFormViewModel({
    required this.mutationStatus,
    required this.isSaving,
    required this.existingCodes,
    this.message,
  });

  final LoadStatus mutationStatus;
  final bool isSaving;
  final Set<String> existingCodes;
  final String? message;

  factory _DepartmentFormViewModel.fromStore(
    Store<AppState> store, {
    String? currentDepartmentId,
  }) {
    final existingCodes = store.state.departmentsState.items
        .where((department) => department.id != currentDepartmentId)
        .map((department) => department.code.toUpperCase())
        .toSet();
    return _DepartmentFormViewModel(
      mutationStatus: store.state.departmentsState.mutationStatus,
      isSaving:
          store.state.departmentsState.mutationStatus == LoadStatus.loading,
      existingCodes: existingCodes,
      message: store.state.departmentsState.mutationMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _DepartmentFormViewModel &&
        other.mutationStatus == mutationStatus &&
        other.isSaving == isSaving &&
        other.message == message &&
        other.existingCodes.length == existingCodes.length &&
        other.existingCodes.containsAll(existingCodes);
  }

  @override
  int get hashCode =>
      Object.hash(mutationStatus, isSaving, message, existingCodes.length);
}
