import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class SummaryUploadSection extends StatelessWidget {
  const SummaryUploadSection({
    super.key,
    required this.attachmentName,
    required this.onFileSelected,
  });

  final String? attachmentName;
  final ValueChanged<String?> onFileSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attachment', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Attach an optional PDF or image to support your summary.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppButton(
                label: 'Choose file',
                onPressed: () async {
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                  );
                  onFileSelected(result?.files.single.name);
                },
                isExpanded: false,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  attachmentName ?? 'No file selected',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
