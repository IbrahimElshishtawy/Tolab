import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/upload_service.dart';
import '../../../core/values/app_spacing.dart';
import '../app_button.dart';

class UploadPanel extends StatefulWidget {
  const UploadPanel({super.key, required this.title, this.allowedExtensions});

  final String title;
  final List<String>? allowedExtensions;

  @override
  State<UploadPanel> createState() => _UploadPanelState();
}

class _UploadPanelState extends State<UploadPanel> {
  UploadSelection? selection;
  bool picking = false;

  Future<void> _pick() async {
    setState(() => picking = true);
    try {
      selection = await Get.find<UploadService>().pickFile(
        allowedExtensions: widget.allowedExtensions,
      );
      if (mounted) setState(() {});
    } catch (error) {
      Get.snackbar('Upload', error.toString());
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            selection == null
                ? 'Choose a file to prepare for upload.'
                : '${selection!.name} • ${(selection!.size / 1024).toStringAsFixed(0)} KB',
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: selection == null ? 'Select File' : 'Replace File',
            icon: Icons.upload_file_rounded,
            isLoading: picking,
            onPressed: _pick,
          ),
        ],
      ),
    );
  }
}
