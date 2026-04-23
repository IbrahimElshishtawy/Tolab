import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../models/announcements_workspace_models.dart';

class PostComposerResult {
  const PostComposerResult({
    required this.title,
    required this.content,
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.type,
    required this.isPinned,
    required this.isUrgent,
    required this.saveAsDraft,
    this.attachmentLabel,
  });

  final String title;
  final String content;
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final String type;
  final bool isPinned;
  final bool isUrgent;
  final bool saveAsDraft;
  final String? attachmentLabel;
}

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({
    super.key,
    required this.subjects,
    required this.onSubmit,
  });

  final List<AnnouncementSubjectOption> subjects;
  final ValueChanged<PostComposerResult> onSubmit;

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _attachmentController = TextEditingController();
  late AnnouncementSubjectOption _selectedSubject = widget.subjects.first;
  String _type = 'Announcement';
  bool _pinPost = false;
  bool _urgent = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  void _submit(bool saveAsDraft) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onSubmit(
      PostComposerResult(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        subjectId: _selectedSubject.id,
        subjectCode: _selectedSubject.code,
        subjectName: _selectedSubject.name,
        type: _type,
        isPinned: _pinPost,
        isUrgent: _urgent,
        saveAsDraft: saveAsDraft,
        attachmentLabel: _attachmentController.text.trim().isEmpty
            ? null
            : _attachmentController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: DoctorAssistantFormLayout(
          title: 'Create post / announcement',
          subtitle:
              'Publish an academic update, keep it urgent or pinned when needed, or save it as a draft for later review.',
          formKey: _formKey,
          primaryLabel: 'Publish now',
          secondaryLabel: 'Save draft',
          onSubmit: () => _submit(false),
          onSecondaryTap: () => _submit(true),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Add a title' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _contentController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Share the student-facing update, clarification, or alert.',
              ),
              validator: (value) =>
                  (value == null || value.trim().length < 12)
                      ? 'Add clearer post content'
                      : null,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<AnnouncementSubjectOption>(
              initialValue: _selectedSubject,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: widget.subjects
                  .map(
                    (subject) => DropdownMenuItem(
                      value: subject,
                      child: Text('${subject.code} • ${subject.name}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _selectedSubject = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'Announcement', child: Text('Announcement')),
                DropdownMenuItem(value: 'Lecture update', child: Text('Lecture update')),
                DropdownMenuItem(value: 'Quiz alert', child: Text('Quiz alert')),
                DropdownMenuItem(value: 'General post', child: Text('General post')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _type = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _attachmentController,
              decoration: const InputDecoration(
                labelText: 'Attach file / link / image',
                hintText: 'Example: lecture-notes.pdf or https://...',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _pinPost,
              title: const Text('Pin post'),
              subtitle: const Text('Keep the post visible at the top of the course feed.'),
              onChanged: (value) => setState(() => _pinPost = value),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _urgent,
              title: const Text('Mark as urgent / important'),
              subtitle: const Text('Use for deadline changes, room updates, and critical quiz alerts.'),
              onChanged: (value) => setState(() => _urgent = value),
            ),
          ],
        ),
      ),
    );
  }
}
