import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_list_tile.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class LecturesTab extends ConsumerWidget {
  const LecturesTab({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturesAsync = ref.watch(lecturesProvider(subjectId));

    return lecturesAsync.when(
      data: (lectures) => lectures.isEmpty
          ? const EmptyStateWidget(
              title: 'No lectures yet',
              subtitle: 'Upcoming lectures will appear here.',
            )
          : Column(
              children: lectures
                  .map(
                    (lecture) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppListTile(
                        title: lecture.title,
                        subtitle: lecture.scheduleLabel,
                        leading: Icon(
                          lecture.isOnline ? Icons.videocam_outlined : Icons.room_outlined,
                        ),
                        trailing: Text(lecture.isOnline ? 'Online' : 'Campus'),
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
