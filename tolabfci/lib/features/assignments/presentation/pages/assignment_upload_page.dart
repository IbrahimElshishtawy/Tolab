import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../providers/assignment_upload_controller.dart';

class AssignmentUploadPage extends ConsumerWidget {
  const AssignmentUploadPage({
    super.key,
    required this.subjectId,
    required this.taskId,
  });

  final String subjectId;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(subjectId));
    final key = (subjectId: subjectId, taskId: taskId);
    final uploadState = ref.watch(assignmentUploadStateProvider(key));
    final controller = ref.read(assignmentUploadControllerProvider.notifier);

    return SafeArea(
      child: AdaptivePageContainer(
        child: tasksAsync.when(
          data: (tasks) {
            final task = tasks.firstWhere((item) => item.id == taskId);

            return ListView(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(task.description, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          AppBadge(label: task.status),
                          AppBadge(
                            label: task.dueDateLabel,
                            backgroundColor: Colors.white,
                          ),
                          AppBadge(
                            label: 'الأنواع: ${task.supportedTypes.join(' / ')}',
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                      if (task.uploadedFileName != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'الملف الحالي: ${task.uploadedFileName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (task.gradeLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'التقييم: ${task.gradeLabel}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('رفع الحل', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          uploadState.selectedFileName ??
                              task.uploadedFileName ??
                              'لم يتم اختيار ملف بعد',
                        ),
                      ),
                      if (uploadState.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          uploadState.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
                        ),
                      ],
                      if (uploadState.isSuccess) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'تم رفع الحل بنجاح.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: uploadState.selectedFileName == null ? 'اختيار ملف' : 'تعديل الاختيار',
                        onPressed: () => controller.pickFile(key),
                        variant: AppButtonVariant.secondary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: uploadState.isUploading ? 'جارٍ الرفع...' : 'رفع الحل',
                        onPressed: uploadState.isUploading
                            ? null
                            : () async {
                                final updatedTask = await controller.upload(key);
                                if (updatedTask == null || !context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم تحديث حالة "${updatedTask.title}" إلى ${updatedTask.status}.'),
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جاري تحميل بيانات الشيت...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
