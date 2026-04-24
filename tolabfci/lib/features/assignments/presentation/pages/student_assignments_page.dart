import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../home/presentation/providers/home_providers.dart';

class StudentAssignmentsPage extends ConsumerStatefulWidget {
  const StudentAssignmentsPage({super.key});

  @override
  ConsumerState<StudentAssignmentsPage> createState() =>
      _StudentAssignmentsPageState();
}

class _StudentAssignmentsPageState
    extends ConsumerState<StudentAssignmentsPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(homeDashboardProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: dashboardAsync.when(
          data: (dashboard) {
            final tasks = [...dashboard.tasks]..sort(_compareTaskDates);
            final filtered = _filterTasks(tasks, _filter);

            return ListView(
              children: [
                _AssignmentsHero(
                  tasks: tasks,
                  onFilterChanged: (value) => setState(() => _filter = value),
                  currentFilter: _filter,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد تكليفات ضمن هذا العرض',
                    subtitle:
                        'جرّب تغيير التصنيف أو راجع المواد لعرض كل التكليفات.',
                    icon: Icons.assignment_outlined,
                  )
                else
                  ..._buildGroups(filtered).entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _AssignmentsGroup(
                        title: entry.key,
                        tasks: entry.value,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جارٍ تحميل التكليفات...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _AssignmentsHero extends StatelessWidget {
  const _AssignmentsHero({
    required this.tasks,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final List<TaskItem> tasks;
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final overdue = tasks.where(_isTaskOverdue).length;
    final uploaded = tasks
        .where((task) => task.uploadedFileName != null)
        .length;
    final graded = tasks.where((task) => task.gradeLabel != null).length;
    final open = tasks.where((task) => !task.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الشيتات والتكليفات',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'واجهة عملية لرفع الحلول، متابعة المواعيد النهائية، ومعرفة ما الذي يحتاج تدخلك فورًا.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _SummaryMetric(
                    label: 'مفتوحة',
                    value: '$open',
                    accentColor: AppColors.primary,
                  ),
                  _SummaryMetric(
                    label: 'متأخرة',
                    value: '$overdue',
                    accentColor: AppColors.error,
                  ),
                  _SummaryMetric(
                    label: 'مرفوعة',
                    value: '$uploaded',
                    accentColor: AppColors.warning,
                  ),
                  _SummaryMetric(
                    label: 'مقيمة',
                    value: '$graded',
                    accentColor: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSegmentedControl<String>(
          groupValue: currentFilter,
          onValueChanged: onFilterChanged,
          children: const {
            'all': Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('الكل'),
            ),
            'action': Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('يحتاج إجراء'),
            ),
            'uploaded': Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('تم الرفع'),
            ),
            'graded': Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('تم التقييم'),
            ),
          },
        ),
      ],
    );
  }
}

class _AssignmentsGroup extends StatelessWidget {
  const _AssignmentsGroup({required this.title, required this.tasks});

  final String title;
  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _AssignmentCard(task: task),
          ),
        ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final accent = _taskAccent(task);
    final statusLabel = _taskStatusLabel(task);
    final primaryActionLabel = task.uploadedFileName == null
        ? 'رفع الحل'
        : 'مشاهدة الملف';
    final secondaryActionLabel = task.uploadedFileName == null
        ? 'تفاصيل'
        : task.allowResubmission
        ? 'إعادة التسليم'
        : 'رفع مغلق';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      task.subjectName ?? 'المادة',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: statusLabel,
                backgroundColor: accent.withValues(alpha: 0.14),
                foregroundColor: accent,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(task.description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaBadge(
                icon: Icons.schedule_rounded,
                label: task.dueDateLabel,
              ),
              if (task.uploadedFileName != null)
                _MetaBadge(
                  icon: Icons.attach_file_rounded,
                  label: task.uploadedFileName!,
                ),
              if (task.gradeLabel != null)
                _MetaBadge(
                  icon: Icons.verified_outlined,
                  label: 'التقييم ${task.gradeLabel}',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: primaryActionLabel,
                onPressed: () => _openTask(context),
                isExpanded: false,
                icon: task.uploadedFileName == null
                    ? Icons.upload_file_rounded
                    : Icons.visibility_rounded,
              ),
              AppButton(
                label: secondaryActionLabel,
                onPressed:
                    task.uploadedFileName == null || task.allowResubmission
                    ? () => _openTask(context)
                    : null,
                isExpanded: false,
                variant: AppButtonVariant.secondary,
                icon: Icons.assignment_turned_in_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openTask(BuildContext context) {
    context.goNamed(
      RouteNames.assignmentUpload,
      pathParameters: {'subjectId': task.subjectId, 'taskId': task.id},
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

List<TaskItem> _filterTasks(List<TaskItem> tasks, String filter) {
  switch (filter) {
    case 'action':
      return tasks
          .where((task) => !task.isCompleted || _isTaskOverdue(task))
          .toList();
    case 'uploaded':
      return tasks.where((task) => task.uploadedFileName != null).toList();
    case 'graded':
      return tasks.where((task) => task.gradeLabel != null).toList();
    default:
      return tasks;
  }
}

Map<String, List<TaskItem>> _buildGroups(List<TaskItem> tasks) {
  final grouped = <String, List<TaskItem>>{
    'يتطلب منك الآن': [],
    'قادمة هذا الأسبوع': [],
    'مكتملة أو مقيمة': [],
  };

  for (final task in tasks) {
    if (_isTaskOverdue(task) || !task.isCompleted) {
      if ((task.dueAt?.difference(DateTime.now()).inDays ?? 7) <= 2) {
        grouped['يتطلب منك الآن']!.add(task);
      } else {
        grouped['قادمة هذا الأسبوع']!.add(task);
      }
      continue;
    }
    grouped['مكتملة أو مقيمة']!.add(task);
  }

  grouped.removeWhere((key, value) => value.isEmpty);
  return grouped;
}

int _compareTaskDates(TaskItem first, TaskItem second) {
  final firstDate = first.dueAt;
  final secondDate = second.dueAt;

  if (firstDate == null && secondDate == null) {
    return 0;
  }
  if (firstDate == null) {
    return 1;
  }
  if (secondDate == null) {
    return -1;
  }
  return firstDate.compareTo(secondDate);
}

bool _isTaskOverdue(TaskItem task) {
  final dueAt = task.dueAt;
  if (dueAt == null) {
    return false;
  }
  return !task.isCompleted && dueAt.isBefore(DateTime.now());
}

String _taskStatusLabel(TaskItem task) {
  if (task.gradeLabel != null) {
    return 'تم التقييم';
  }
  if (_isTaskOverdue(task)) {
    return 'متأخر';
  }
  if (task.uploadedFileName != null) {
    return 'تم الرفع';
  }
  return 'لم يتم الرفع';
}

Color _taskAccent(TaskItem task) {
  if (task.gradeLabel != null) {
    return AppColors.success;
  }
  if (_isTaskOverdue(task)) {
    return AppColors.error;
  }
  if (task.uploadedFileName != null) {
    return AppColors.warning;
  }
  return AppColors.primary;
}
