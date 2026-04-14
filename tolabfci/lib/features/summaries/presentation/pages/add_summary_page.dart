import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/summaries_providers.dart';
import '../widgets/summary_upload_section.dart';

class AddSummaryPage extends ConsumerStatefulWidget {
  const AddSummaryPage({super.key, required this.subjectId});

  final String subjectId;

  @override
  ConsumerState<AddSummaryPage> createState() => _AddSummaryPageState();
}

class _AddSummaryPageState extends ConsumerState<AddSummaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _videoController = TextEditingController();
  String? _attachmentName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add summary')),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: ListView(
            children: [
              AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _titleController,
                        label: 'Summary title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _videoController,
                        label: 'Optional video URL',
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SummaryUploadSection(
                attachmentName: _attachmentName,
                onFileSelected: (value) =>
                    setState(() => _attachmentName = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: _isSubmitting ? 'Saving...' : 'Save summary',
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final navigator = Navigator.of(context);
                        setState(() => _isSubmitting = true);
                        await ref
                            .read(
                              summariesControllerProvider(
                                widget.subjectId,
                              ).notifier,
                            )
                            .addSummary(
                              title: _titleController.text.trim(),
                              videoUrl: _videoController.text.trim().isEmpty
                                  ? null
                                  : _videoController.text.trim(),
                              attachmentName: _attachmentName,
                            );
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                          navigator.pop();
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
