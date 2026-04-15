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

class AddAnnouncementPage extends ConsumerStatefulWidget {
  const AddAnnouncementPage({
    super.key,
    required this.subjectId,
    this.initialAnnouncement,
  });

  final String subjectId;
  final StaffAnnouncement? initialAnnouncement;

  @override
  ConsumerState<AddAnnouncementPage> createState() =>
      _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends ConsumerState<AddAnnouncementPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _attachmentController;
  late StaffAnnouncementPriority _priority;
  late bool _isPublished;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialAnnouncement?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.initialAnnouncement?.content ?? '',
    );
    _attachmentController = TextEditingController(
      text: widget.initialAnnouncement?.attachmentLabel ?? '',
    );
    _priority =
        widget.initialAnnouncement?.priority ??
        StaffAnnouncementPriority.normal;
    _isPublished = widget.initialAnnouncement?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('إضافة إعلان', 'Add announcement')),
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
                        labelText: context.tr(
                          'عنوان الخبر',
                          'Announcement title',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _contentController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: InputDecoration(
                        labelText: context.tr('المحتوى', 'Content'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child:
                              DropdownButtonFormField<
                                StaffAnnouncementPriority
                              >(
                                initialValue: _priority,
                                decoration: InputDecoration(
                                  labelText: context.tr('الأولوية', 'Priority'),
                                ),
                                items: StaffAnnouncementPriority.values
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          _priorityLabel(context, value),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _priority = value);
                                  }
                                },
                              ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(context.tr('منشور', 'Published')),
                            value: _isPublished,
                            onChanged: (value) =>
                                setState(() => _isPublished = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _attachmentController,
                      decoration: InputDecoration(
                        labelText: context.tr(
                          'اسم مرفق اختياري',
                          'Optional attachment label',
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
              : context.tr('حفظ الإعلان', 'Save announcement'),
          onPressed: _isSaving ? null : () => _save(context),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'العنوان والمحتوى مطلوبان',
              'Title and content are required',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await ref
        .read(staffPortalRepositoryProvider)
        .saveAnnouncement(
          subjectId: widget.subjectId,
          announcement: StaffAnnouncement(
            id: widget.initialAnnouncement?.id ?? '',
            subjectId: widget.subjectId,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            priority: _priority,
            isPublished: _isPublished,
            createdAt: DateTime.now(),
            authorName: '',
            attachmentLabel: _attachmentController.text.trim().isEmpty
                ? null
                : _attachmentController.text.trim(),
          ),
        );
    ref.invalidate(staffSubjectWorkspaceProvider(widget.subjectId));
    ref.invalidate(staffDashboardProvider);
    ref.invalidate(staffCoursesProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(this.context).pop();
  }

  String _priorityLabel(
    BuildContext context,
    StaffAnnouncementPriority priority,
  ) {
    return switch (priority) {
      StaffAnnouncementPriority.normal => context.tr('عادي', 'Normal'),
      StaffAnnouncementPriority.important => context.tr('مهم', 'Important'),
      StaffAnnouncementPriority.urgent => context.tr('عاجل', 'Urgent'),
    };
  }
}
