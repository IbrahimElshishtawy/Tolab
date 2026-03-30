import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/upload_model.dart';

class DragDropArea extends StatefulWidget {
  const DragDropArea({super.key, required this.onFilesSelected, this.subtitle});

  final ValueChanged<List<UploadLocalFile>> onFilesSelected;
  final String? subtitle;

  @override
  State<DragDropArea> createState() => _DragDropAreaState();
}

class _DragDropAreaState extends State<DragDropArea> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final title =
        widget.subtitle ??
        'Drop PDFs, lecture images, policy sheets, and video assets here.';

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) async {
        setState(() => _isDragging = false);
        final files = await _mapDroppedFiles(details);
        if (files.isNotEmpty) {
          widget.onFilesSelected(files);
        }
      },
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
        child: AppCard(
          borderRadius: 30,
          backgroundColor: _isDragging
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).cardColor,
          borderColor: _isDragging
              ? AppColors.primary.withValues(alpha: 0.35)
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppMotion.fast,
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  color: (_isDragging ? AppColors.primary : AppColors.info)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Icon(
                  _isDragging
                      ? Icons.file_download_done_rounded
                      : Icons.cloud_upload_rounded,
                  color: _isDragging ? AppColors.primary : AppColors.info,
                  size: 34,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Desktop drag & drop, mobile file picker',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  PremiumButton(
                    label: 'Browse Files',
                    icon: Icons.attach_file_rounded,
                    onPressed: _pickFiles,
                  ),
                  PremiumButton(
                    label: 'Allowed: PDF, Images, Video',
                    icon: Icons.verified_rounded,
                    isSecondary: true,
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: const [
                  _FeatureChip(label: 'Chunked upload'),
                  _FeatureChip(label: 'Access permissions'),
                  _FeatureChip(label: 'Retry-safe queue'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: kIsWeb,
      lockParentWindow: true,
    );
    if (result == null) return;
    final files = result.files
        .map(
          (file) => UploadLocalFile(
            localId:
                'local-${DateTime.now().microsecondsSinceEpoch}-${file.name.hashCode}',
            name: file.name,
            sizeBytes: file.size,
            mimeType: _mimeTypeFor(file.name),
            path: file.path,
            bytes: file.bytes,
          ),
        )
        .toList(growable: false);
    widget.onFilesSelected(files);
  }

  Future<List<UploadLocalFile>> _mapDroppedFiles(
    DropDoneDetails details,
  ) async {
    final files = <UploadLocalFile>[];
    for (final dropped in details.files) {
      final dynamic file = dropped;
      final String name = file.name?.toString() ?? 'Upload';
      final String? path = file.path?.toString();
      final Uint8List? bytes = path == null ? await file.readAsBytes() : null;
      final int sizeBytes = path == null
          ? (bytes?.length ?? 0)
          : await file.length() as int;
      files.add(
        UploadLocalFile(
          localId:
              'local-${DateTime.now().microsecondsSinceEpoch}-${name.hashCode}',
          name: name,
          sizeBytes: sizeBytes,
          mimeType: _mimeTypeFor(name),
          path: path,
          bytes: bytes,
        ),
      );
    }
    return files;
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.slateSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

String _mimeTypeFor(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.mp4')) return 'video/mp4';
  if (lower.endsWith('.mov')) return 'video/quicktime';
  if (lower.endsWith('.xlsx')) {
    return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  }
  if (lower.endsWith('.xls')) return 'application/vnd.ms-excel';
  if (lower.endsWith('.csv')) return 'text/csv';
  if (lower.endsWith('.zip')) return 'application/zip';
  if (lower.endsWith('.docx')) {
    return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  }
  return 'application/octet-stream';
}
