import 'package:flutter/material.dart';

import '../../../../core/models/support_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({
    super.key,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final Future<void> Function(SupportTicketDraft draft) onSubmit;
  final bool isSubmitting;

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  SupportTicketCategory _category = SupportTicketCategory.technical;
  SupportTicketPriority _priority = SupportTicketPriority.medium;
  String? _attachmentName;

  @override
  void dispose() {
    _subjectController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إرسال شكوى أو طلب دعم',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'سيتم توجيه الطلب إلى فريق IT/الإدارة مع بيانات الطالب تلقائيًا.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<SupportTicketCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'الفئة'),
              items: SupportTicketCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: widget.isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _category = value);
                    },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _subjectController,
              label: 'المادة (اختياري)',
              hintText: 'مثال: تطوير تطبيقات الهاتف المتقدمة',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _titleController,
              label: 'العنوان',
              hintText: 'اكتب عنوانًا واضحًا للمشكلة',
              validator: (value) {
                if (value == null || value.trim().length < 4) {
                  return 'اكتب عنوانًا أوضح';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _descriptionController,
              label: 'الوصف',
              hintText: 'اشرح المشكلة أو الطلب بالتفصيل',
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().length < 12) {
                  return 'أضف تفاصيل أكثر حتى يتمكن الفريق من المساعدة';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<SupportTicketPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'الأولوية'),
              items: SupportTicketPriority.values
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.label),
                    ),
                  )
                  .toList(),
              onChanged: widget.isSubmitting
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _priority = value);
                    },
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppButton(
                  label: _attachmentName == null ? 'إرفاق ملف' : 'تغيير المرفق',
                  onPressed: widget.isSubmitting ? null : _pickAttachment,
                  isExpanded: false,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.attach_file_rounded,
                ),
                if (_attachmentName != null)
                  Chip(
                    label: Text(_attachmentName!),
                    onDeleted: widget.isSubmitting
                        ? null
                        : () => setState(() => _attachmentName = null),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: widget.isSubmitting ? 'جارٍ الإرسال...' : 'إرسال الطلب',
              onPressed: widget.isSubmitting ? null : _submit,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final controller = TextEditingController(text: _attachmentName ?? '');
    final fileName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اسم الملف المرفق'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'مثال: screenshot.png'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('إرفاق'),
          ),
        ],
      ),
    );
    if (!mounted || fileName == null || fileName.isEmpty) {
      return;
    }
    setState(() => _attachmentName = fileName);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSubmit(
      SupportTicketDraft(
        category: _category,
        priority: _priority,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subjectName: _subjectController.text.trim().isEmpty
            ? null
            : _subjectController.text.trim(),
        attachmentName: _attachmentName,
      ),
    );

    if (!mounted) {
      return;
    }

    _formKey.currentState!.reset();
    _subjectController.clear();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _attachmentName = null;
      _category = SupportTicketCategory.technical;
      _priority = SupportTicketPriority.medium;
    });
  }
}
