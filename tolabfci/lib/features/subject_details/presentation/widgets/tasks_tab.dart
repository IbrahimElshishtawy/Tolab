import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class TasksTab extends ConsumerWidget {
  const TasksTab({
    super.key,
    required this.subjectId,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(subjectId));

    return tasksAsync.when(
      data: (tasks) => tasks.isEmpty
          ? const EmptyStateWidget(
              title: 'لا توجد شيتات',
              subtitle: 'ستظهر تكليفات المادة هنا بمجرد نشرها.',
            )
          : ListView.separated(
              shrinkWrap: usePageScroll,
              physics: usePageScroll
                  ? const NeverScrollableScrollPhysics()
                  : null,
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final canResubmit =
                    task.allowResubmission && task.uploadedFileName != null;

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          AppBadge(
                            label: task.status,
                            backgroundColor: AppColors.surfaceAlt,
                            foregroundColor: task.status == 'تم التقييم'
                                ? AppColors.success
                                : task.status == 'لم يتم الرفع'
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        task.dueDateLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      if (task.uploadedFileName != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text('الملف المرفوع: ${task.uploadedFileName}'),
                      ],
                      if (task.gradeLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'التقييم: ${task.gradeLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          AppButton(
                            label: task.uploadedFileName == null
                                ? 'رفع الحل'
                                : 'مشاهدة الملف المرفوع',
                            onPressed: () => context.goNamed(
                              RouteNames.assignmentUpload,
                              pathParameters: {
                                'subjectId': subjectId,
                                'taskId': task.id,
                              },
                            ),
                            isExpanded: false,
                          ),
                          if (task.uploadedFileName != null)
                            AppButton(
                              label: canResubmit
                                  ? 'إعادة التسليم'
                                  : 'تعديل الرفع',
                              onPressed: canResubmit
                                  ? () => context.goNamed(
                                      RouteNames.assignmentUpload,
                                      pathParameters: {
                                        'subjectId': subjectId,
                                        'taskId': task.id,
                                      },
                                    )
                                  : null,
                              isExpanded: false,
                              variant: AppButtonVariant.secondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}
