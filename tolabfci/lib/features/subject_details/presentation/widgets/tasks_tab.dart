import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_list_tile.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class TasksTab extends ConsumerWidget {
  const TasksTab({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(subjectId));

    return tasksAsync.when(
      data: (tasks) => tasks.isEmpty
          ? const EmptyStateWidget(
              title: 'No tasks assigned',
              subtitle: 'Tasks and deadlines will appear here.',
            )
          : Column(
              children: tasks
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppListTile(
                        title: task.title,
                        subtitle: task.dueDateLabel,
                        leading: const Icon(Icons.task_alt_outlined),
                        trailing: AppBadge(label: task.status),
                      ),
                    ),
                  )
                  .toList(),
            ),
      loading: () => const LoadingWidget(),
      error: (error, stackTrace) => Text(error.toString()),
    );
  }
}
