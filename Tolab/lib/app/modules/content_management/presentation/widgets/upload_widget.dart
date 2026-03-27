import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/content_models.dart';

class UploadWidget extends StatefulWidget {
  const UploadWidget({
    super.key,
    required this.attachments,
    required this.tasks,
    required this.onFilesSelected,
    required this.onRetry,
    required this.onRemoveAttachment,
  });

  final List<ContentAttachment> attachments;
  final List<ContentUploadTask> tasks;
  final ValueChanged<List<ContentUploadSource>> onFilesSelected;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onRemoveAttachment;

  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropTarget(
          onDragEntered: (_) => setState(() => _isDragging = true),
          onDragExited: (_) => setState(() => _isDragging = false),
          onDragDone: (details) async {
            setState(() => _isDragging = false);
            widget.onFilesSelected(
              await Future.wait(
                details.files.map((file) async {
                  final bytes = await file.readAsBytes();
                  return ContentUploadSource(
                    id: 'drop-${DateTime.now().microsecondsSinceEpoch}-${file.name}',
                    name: file.name,
                    sizeBytes: bytes.length,
                    mimeType: _detectMimeType(file.name),
                    bytes: bytes,
                  );
                }),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: _isDragging
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08)
                  : Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isDragging
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.cloud_upload_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drag and drop files or browse',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Supports desktop drag-and-drop with upload progress, retry, and metadata preview.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PremiumButton(
                  label: 'Select files',
                  icon: Icons.attach_file_rounded,
                  isSecondary: true,
                  onPressed: _pickFiles,
                ),
              ],
            ),
          ),
        ),
        if (widget.tasks.isNotEmpty || widget.attachments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload queue',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final task in widget.tasks) ...[
                  _TaskRow(task: task, onRetry: widget.onRetry),
                  const SizedBox(height: AppSpacing.sm),
                ],
                for (final attachment in widget.attachments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _AttachmentRow(
                      attachment: attachment,
                      onRemove: widget.onRemoveAttachment,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    widget.onFilesSelected(
      result.files.map(_fromPlatformFile).toList(growable: false),
    );
  }

  ContentUploadSource _fromPlatformFile(PlatformFile file) {
    return ContentUploadSource(
      id: 'pick-${DateTime.now().microsecondsSinceEpoch}-${file.name}',
      name: file.name,
      sizeBytes: file.size,
      mimeType: _detectMimeType(file.name),
      bytes: file.bytes != null ? Uint8List.fromList(file.bytes!) : null,
      path: file.path,
    );
  }

  String _detectMimeType(String fileName) {
    final parts = fileName.toLowerCase().split('.');
    final extension = parts.length > 1 ? parts.last : '';
    return switch (extension) {
      'pdf' => 'application/pdf',
      'doc' || 'docx' => 'application/msword',
      'ppt' || 'pptx' => 'application/vnd.ms-powerpoint',
      'zip' => 'application/zip',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'mp4' => 'video/mp4',
      _ => 'application/octet-stream',
    };
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onRetry});

  final ContentUploadTask task;
  final ValueChanged<String> onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(task.source.name)),
            Text(
              task.statusLabel,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            if (task.hasFailed) ...[
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: 'Retry',
                onPressed: () => onRetry(task.id),
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: task.hasFailed ? 0 : task.progress),
        if (task.errorMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            task.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment, required this.onRemove});

  final ContentAttachment attachment;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(attachment.extensionLabel)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${attachment.sizeLabel} • ${attachment.mimeType}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => onRemove(attachment.id),
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
