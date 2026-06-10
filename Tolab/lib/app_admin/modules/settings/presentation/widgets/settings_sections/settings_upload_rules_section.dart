import 'package:flutter/material.dart';

import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/modules/settings/models/settings_models.dart';
import 'package:tolab_fci/app_admin/modules/settings/presentation/settings_screen.dart';
import 'package:tolab_fci/app_admin/modules/settings/widgets/settings_primitives.dart';

class SettingsUploadRulesSection extends StatelessWidget {
  const SettingsUploadRulesSection({
    super.key,
    required this.vm,
    required this.width,
    required this.onUpdateBundle,
  });

  final SettingsViewModel vm;
  final double width;
  final void Function(SettingsBundle Function(SettingsBundle) update) onUpdateBundle;

  @override
  Widget build(BuildContext context) {
    final uploadRules = vm.settingsState.bundle.uploadRules;
    return SettingsGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsBlockHeader(
            title: 'Upload Controls',
            subtitle:
                'Define file validation, storage target, and upload safeguards for academic assets.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _fieldWrap(
            width: width,
            children: [
              SettingsNumberInput(
                value: uploadRules.maxFileSizeMb,
                label: 'Max file size (MB)',
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    uploadRules: uploadRules.copyWith(maxFileSizeMb: value),
                  ),
                ),
              ),
              SettingsDropdownField<StorageLocation>(
                value: uploadRules.storageLocation,
                label: 'Storage location',
                items: StorageLocation.values,
                labelBuilder: (value) => value.label,
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    uploadRules: uploadRules.copyWith(storageLocation: value),
                  ),
                ),
              ),
              SettingsTextInput(
                value: uploadRules.basePath,
                label: 'Base path',
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    uploadRules: uploadRules.copyWith(basePath: value),
                  ),
                ),
              ),
              SettingsTextInput(
                value: uploadRules.allowedFileTypes.join(', '),
                label: 'Allowed types',
                hintText: 'pdf, docx, png, zip',
                onChanged: (value) => onUpdateBundle(
                  (b) => b.copyWith(
                    uploadRules: uploadRules.copyWith(
                      allowedFileTypes: value
                          .split(',')
                          .map((item) => item.trim().toLowerCase())
                          .where((item) => item.isNotEmpty)
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsSwitchTile(
            title: 'Validate MIME type',
            subtitle:
                'Verify content signatures instead of trusting only the file extension.',
            value: uploadRules.validateMimeType,
            onChanged: (value) => onUpdateBundle(
              (b) => b.copyWith(
                uploadRules: uploadRules.copyWith(validateMimeType: value),
              ),
            ),
          ),
          SettingsSwitchTile(
            title: 'Virus scan uploads',
            subtitle:
                'Run server-side safety checks before files are released.',
            value: uploadRules.runVirusScan,
            onChanged: (value) => onUpdateBundle(
              (b) => b.copyWith(
                uploadRules: uploadRules.copyWith(runVirusScan: value),
              ),
            ),
          ),
          SettingsSwitchTile(
            title: 'Rename files on upload',
            subtitle:
                'Normalize stored filenames for safer downstream processing.',
            value: uploadRules.renameOnUpload,
            onChanged: (value) => onUpdateBundle(
              (b) => b.copyWith(
                uploadRules: uploadRules.copyWith(renameOnUpload: value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldWrap({required double width, required List<Widget> children}) {
    final tileWidth = width >= 920 ? (width - AppSpacing.md) / 2 : width;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final child in children)
          SizedBox(width: tileWidth.clamp(280, 640).toDouble(), child: child),
      ],
    );
  }
}
