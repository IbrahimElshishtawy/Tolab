import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/mock_staff_portal_repository.dart';
import '../../domain/models/staff_portal_models.dart';
import '../providers/staff_portal_providers.dart';

class AddLecturePage extends ConsumerWidget {
  const AddLecturePage({
    super.key,
    required this.subjectId,
    this.initialSession,
  });

  final String subjectId;
  final StaffSessionLink? initialSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SessionEditorPage(
      subjectId: subjectId,
      kind: StaffSessionKind.lecture,
      initialSession: initialSession,
    );
  }
}

class SessionEditorPage extends ConsumerStatefulWidget {
  const SessionEditorPage({
    super.key,
    required this.subjectId,
    required this.kind,
    this.initialSession,
  });

  final String subjectId;
  final StaffSessionKind kind;
  final StaffSessionLink? initialSession;

  @override
  ConsumerState<SessionEditorPage> createState() => _SessionEditorPageState();
}

class _SessionEditorPageState extends ConsumerState<SessionEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _meetingController;
  late final TextEditingController _locationController;
  late final TextEditingController _attachmentController;
  late StaffSessionMode _mode;
  late DateTime _startsAt;
  late DateTime _endsAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialSession?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialSession?.description ?? '',
    );
    _meetingController = TextEditingController(
      text: widget.initialSession?.meetingLink ?? '',
    );
    _locationController = TextEditingController(
      text: widget.initialSession?.locationLabel ?? '',
    );
    _attachmentController = TextEditingController(
      text: widget.initialSession?.attachmentLabel ?? '',
    );
    _mode = widget.initialSession?.mode ?? StaffSessionMode.online;
    _startsAt =
        widget.initialSession?.startsAt ??
        DateTime.now().add(const Duration(hours: 2));
    _endsAt =
        widget.initialSession?.endsAt ??
        DateTime.now().add(const Duration(hours: 3, minutes: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingController.dispose();
    _locationController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLecture = widget.kind == StaffSessionKind.lecture;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLecture
              ? context.tr('إضافة محاضرة', 'Add lecture')
              : context.tr('إضافة سكشن', 'Add section'),
        ),
      ),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: isLecture
                            ? context.tr('عنوان المحاضرة', 'Lecture title')
                            : context.tr('عنوان السكشن', 'Section title'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: context.tr('الوصف', 'Description'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<StaffSessionMode>(
                      initialValue: _mode,
                      decoration: InputDecoration(
                        labelText: context.tr('نوع الحضور', 'Session mode'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: StaffSessionMode.online,
                          child: Text(context.tr('أونلاين', 'Online')),
                        ),
                        DropdownMenuItem(
                          value: StaffSessionMode.offline,
                          child: Text(context.tr('أوفلاين', 'Offline')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _mode = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _DateInput(
                            label: context.tr('البداية', 'Start'),
                            value: _dateTimeLabel(_startsAt),
                            onTap: () async {
                              final value = await _pickDateTime(
                                context,
                                _startsAt,
                              );
                              if (value != null) {
                                setState(() => _startsAt = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _DateInput(
                            label: context.tr('النهاية', 'End'),
                            value: _dateTimeLabel(_endsAt),
                            onTap: () async {
                              final value = await _pickDateTime(
                                context,
                                _endsAt,
                              );
                              if (value != null) {
                                setState(() => _endsAt = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _meetingController,
                      decoration: InputDecoration(
                        labelText: context.tr('رابط الاجتماع', 'Meeting link'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: context.tr(
                          'الموقع أو القاعة',
                          'Location or room',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _attachmentController,
                      decoration: InputDecoration(
                        labelText: context.tr(
                          'مرفق اختياري',
                          'Optional attachment',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: AppButton(
          label: _isSaving
              ? context.tr('جارٍ الحفظ...', 'Saving...')
              : context.tr('حفظ', 'Save'),
          onPressed: _isSaving ? null : () => _save(context),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('العنوان مطلوب', 'Title is required')),
        ),
      );
      return;
    }
    if (_mode == StaffSessionMode.online &&
        _meetingController.text.trim().isNotEmpty) {
      final uri = Uri.tryParse(_meetingController.text.trim());
      if (uri == null || !(uri.isAbsolute && uri.hasScheme)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('أدخل رابطًا صحيحًا', 'Enter a valid meeting URL'),
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    await ref
        .read(staffPortalRepositoryProvider)
        .saveSession(
          subjectId: widget.subjectId,
          session: StaffSessionLink(
            id: widget.initialSession?.id ?? '',
            subjectId: widget.subjectId,
            kind: widget.kind,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            mode: _mode,
            startsAt: _startsAt,
            endsAt: _endsAt,
            createdBy: '',
            meetingLink: _meetingController.text.trim().isEmpty
                ? null
                : _meetingController.text.trim(),
            locationLabel: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            attachmentLabel: _attachmentController.text.trim().isEmpty
                ? null
                : _attachmentController.text.trim(),
          ),
        );
    ref.invalidate(staffSubjectWorkspaceProvider(widget.subjectId));
    ref.invalidate(staffDashboardProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(this.context).pop();
  }

  String _dateTimeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}/${value.month}/${value.day}  $hour:$minute';
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime initial,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value),
      ),
    );
  }
}
