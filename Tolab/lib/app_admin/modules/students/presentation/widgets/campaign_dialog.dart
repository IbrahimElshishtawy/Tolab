import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_management_models.dart';

class CampaignDialog extends StatefulWidget {
  const CampaignDialog({
    super.key,
    required this.snapshot,
    required this.selectedStudentIds,
    this.group,
  });

  final StudentModuleSnapshot snapshot;
  final Set<String> selectedStudentIds;
  final StudentGroupRecord? group;

  @override
  State<CampaignDialog> createState() => _CampaignDialogState();
}

class _CampaignDialogState extends State<CampaignDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  StudentCommunicationChannel _channel = StudentCommunicationChannel.inApp;
  String _audience = 'Selected students';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.group == null ? '' : '${widget.group!.name} update',
    );
    _bodyController = TextEditingController();
    if (widget.group != null) {
      _audience = widget.group!.name;
    } else if (widget.selectedStudentIds.isEmpty) {
      _audience = 'All students';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipients = widget.group != null
        ? widget.group!.memberIds
        : widget.selectedStudentIds.isEmpty
            ? widget.snapshot.students.map((item) => item.id).toList()
            : widget.selectedStudentIds.toList();

    return AlertDialog(
      title: const Text('Compose campaign'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _bodyController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Message body'),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<StudentCommunicationChannel>(
              initialValue: _channel,
              decoration: const InputDecoration(labelText: 'Channel'),
              items: [
                for (final channel in StudentCommunicationChannel.values)
                  DropdownMenuItem(value: channel, child: Text(channel.label)),
              ],
              onChanged: (value) =>
                  setState(() => _channel = value ?? _channel),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _audience,
              decoration: const InputDecoration(labelText: 'Audience'),
              items: [
                DropdownMenuItem(
                  value: widget.group?.name ?? 'Selected students',
                  child: Text(widget.group?.name ?? 'Selected students'),
                ),
                if (widget.group == null)
                  const DropdownMenuItem(
                    value: 'All students',
                    child: Text('All students'),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _audience = value ?? _audience),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty ||
                _bodyController.text.trim().isEmpty) {
              return;
            }
            Navigator.of(context).pop(
              CampaignDialogResult(
                title: _titleController.text.trim(),
                body: _bodyController.text.trim(),
                channel: _channel,
                audienceLabel: _audience,
                recipientStudentIds: recipients,
                groupId: widget.group?.id,
              ),
            );
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class CampaignDialogResult {
  const CampaignDialogResult({
    required this.title,
    required this.body,
    required this.channel,
    required this.audienceLabel,
    required this.recipientStudentIds,
    this.groupId,
  });

  final String title;
  final String body;
  final StudentCommunicationChannel channel;
  final String audienceLabel;
  final List<String> recipientStudentIds;
  final String? groupId;
}
