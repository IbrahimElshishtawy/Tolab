import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_list_tile.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class SectionsTab extends ConsumerWidget {
  const SectionsTab({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(sectionsProvider(subjectId));

    return sectionsAsync.when(
      data: (sections) => sections.isEmpty
          ? const EmptyStateWidget(
              title: 'No sections available',
              subtitle: 'Section details will appear here.',
            )
          : Column(
              children: sections
                  .map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppListTile(
                        title: section.title,
                        subtitle: '${section.scheduleLabel} • ${section.location}',
                        leading: const Icon(Icons.layers_outlined),
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
