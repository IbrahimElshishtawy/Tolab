import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/staff_admin_models.dart';
import '../design/staff_management_tokens.dart';
import '../widgets/staff_permissions_panel.dart';
import '../widgets/staff_status_badge.dart';

class StaffAccountFormSheet extends StatefulWidget {
  const StaffAccountFormSheet({
    super.key,
    this.record,
    this.rolePreset,
  });

  final StaffAdminRecord? record;
  final String? rolePreset;

  @override
  State<StaffAccountFormSheet> createState() => _StaffAccountFormSheetState();
}

class _StaffAccountFormSheetState extends State<StaffAccountFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _idController;
  late final TextEditingController _assignmentController;
  late final TextEditingController _notesController;

  late String _role;
  late String _doctorType;
  late String _department;
  late String _status;
  late List<StaffPermissionGroup> _groups;

  bool get _isDoctor => _role == 'Doctor';

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _nameController = TextEditingController(text: record?.fullName ?? '');
    _emailController = TextEditingController(text: record?.email ?? '');
    _idController = TextEditingController(text: record?.employeeId ?? '');
    _assignmentController = TextEditingController(
      text: record?.subjects
              .map((subject) => '${subject.code} ${subject.title}')
              .join(', ') ??
          '',
    );
    _notesController = TextEditingController(
      text: record?.recentActivity ?? 'Academic assignments and onboarding notes.',
    );
    _role = widget.rolePreset ?? record?.role ?? 'Doctor';
    _doctorType =
        record?.doctorType ?? 'Internal faculty doctor';
    _department = record?.department ?? 'Computer Science';
    _status = record?.status ?? 'Active';
    _groups = record?.permissionGroups ?? _defaultPermissionGroups();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _assignmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.record == null
        ? 'Create ${_isDoctor ? 'doctor' : 'assistant'} account'
        : 'Edit staff account';

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.dialogRadius),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
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
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure identity, role type, permissions, and academic assignments in one compact workflow.',
                            style: Theme.of(context).textTheme.bodySmall,
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
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StaffStatusBadge(_role),
                    StaffStatusBadge(_isDoctor ? _doctorType : 'Teaching assistant'),
                    StaffStatusBadge(_status),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _FormSection(
                  title: 'Identity',
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 820;
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          SizedBox(
                            width: compact ? constraints.maxWidth : 320,
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: compact ? constraints.maxWidth : 320,
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: compact ? constraints.maxWidth : 220,
                            child: TextField(
                              controller: _idController,
                              decoration: const InputDecoration(
                                labelText: 'Staff ID',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: compact ? constraints.maxWidth : 220,
                            child: _DropdownField(
                              label: 'Department',
                              value: _department,
                              items: const [
                                'Computer Science',
                                'Information Systems',
                                'Engineering',
                              ],
                              onChanged: (value) =>
                                  setState(() => _department = value),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FormSection(
                  title: 'Role and access',
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 820;
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          SizedBox(
                            width: compact ? constraints.maxWidth : 220,
                            child: _DropdownField(
                              label: 'Role type',
                              value: _role,
                              items: const ['Doctor', 'Assistant'],
                              onChanged: (value) => setState(() => _role = value),
                            ),
                          ),
                          if (_isDoctor)
                            SizedBox(
                              width: compact ? constraints.maxWidth : 280,
                              child: _DropdownField(
                                label: 'Doctor type',
                                value: _doctorType,
                                items: const [
                                  'Internal faculty doctor',
                                  'Delegated / external doctor',
                                ],
                                onChanged: (value) =>
                                    setState(() => _doctorType = value),
                              ),
                            ),
                          SizedBox(
                            width: compact ? constraints.maxWidth : 220,
                            child: _DropdownField(
                              label: 'Account status',
                              value: _status,
                              items: const ['Active', 'Inactive'],
                              onChanged: (value) => setState(() => _status = value),
                            ),
                          ),
                          SizedBox(
                            width: compact ? constraints.maxWidth : 360,
                            child: TextField(
                              controller: _assignmentController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Academic assignments',
                                hintText: 'Subjects, sections, labs, or teaching load',
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FormSection(
                  title: 'Initial permissions',
                  child: StaffPermissionsPanel(
                    groups: _groups,
                    editable: true,
                    onPermissionChanged: _togglePermission,
                    header: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: StaffManagementDecorations.tintedPanel(
                        context,
                        tint: StaffManagementPalette.doctor,
                        opacity: 0.07,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: StaffManagementPalette.doctor,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Define what this account can upload, schedule, moderate, and expose to students academically.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _FormSection(
                  title: 'Admin notes',
                  child: TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Onboarding notes',
                      hintText: 'Account review notes, allocation context, or internal remarks',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        label: 'Cancel',
                        icon: Icons.close_rounded,
                        isSecondary: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: PremiumButton(
                        label: widget.record == null ? 'Create account' : 'Save changes',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _togglePermission(String permissionId, bool enabled) {
    setState(() {
      _groups = [
        for (final group in _groups)
          group.copyWith(
            permissions: [
              for (final permission in group.permissions)
                permission.id == permissionId
                    ? permission.copyWith(enabled: enabled)
                    : permission,
            ],
          ),
      ];
    });
  }

  List<StaffPermissionGroup> _defaultPermissionGroups() {
    return const [
      StaffPermissionGroup(
        id: 'content',
        title: 'Content delivery',
        subtitle: 'Lectures, sections, and academic uploads.',
        icon: Icons.play_lesson_outlined,
        permissions: [
          StaffPermission(
            id: 'create_lectures',
            title: 'Create lectures',
            description: 'Publish lecture sessions and structured lecture entries.',
            enabled: true,
          ),
          StaffPermission(
            id: 'upload_lecture_files',
            title: 'Upload lecture files',
            description: 'Attach slides, recordings, and lecture assets.',
            enabled: true,
          ),
          StaffPermission(
            id: 'manage_sections',
            title: 'Manage sections',
            description: 'Create sections and upload related section content.',
            enabled: true,
          ),
        ],
      ),
      StaffPermissionGroup(
        id: 'assessment',
        title: 'Assessment flow',
        subtitle: 'Tasks, deadlines, and academic evaluation setup.',
        icon: Icons.assignment_outlined,
        permissions: [
          StaffPermission(
            id: 'upload_tasks',
            title: 'Upload tasks',
            description: 'Create tasks and supporting task resources.',
            enabled: true,
          ),
          StaffPermission(
            id: 'set_due_dates',
            title: 'Add task due dates',
            description: 'Define deadlines and schedule assessment windows.',
            enabled: true,
          ),
          StaffPermission(
            id: 'view_progress',
            title: 'View student progress',
            description: 'Track academic completion and student progress metrics.',
            enabled: false,
          ),
        ],
      ),
      StaffPermissionGroup(
        id: 'community',
        title: 'Community and schedule',
        subtitle: 'Posts, communication, and schedule coordination.',
        icon: Icons.forum_outlined,
        permissions: [
          StaffPermission(
            id: 'post_course_updates',
            title: 'Post in course/community',
            description: 'Create posts and academic announcements for students.',
            enabled: true,
          ),
          StaffPermission(
            id: 'manage_subject_posts',
            title: 'Manage subject posts',
            description: 'Edit, pin, and moderate subject-related posts.',
            enabled: true,
          ),
          StaffPermission(
            id: 'update_schedule',
            title: 'Update schedule',
            description: 'Adjust classes or academic schedule items when allowed.',
            enabled: false,
          ),
        ],
      ),
    ];
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: StaffManagementDecorations.outline(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
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
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in items)
          DropdownMenuItem<String>(value: item, child: Text(item)),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}
