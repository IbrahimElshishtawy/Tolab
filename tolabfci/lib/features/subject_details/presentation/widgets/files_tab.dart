import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class FilesTab extends ConsumerWidget {
  const FilesTab({super.key, required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(subjectFilesProvider(subjectId));

    return filesAsync.when(
      data: (files) => files.isEmpty
          ? const EmptyStateWidget(
              title: 'لا توجد ملفات',
              subtitle: 'ستظهر ملفات المادة الإضافية هنا عند توفرها.',
            )
          : ListView.separated(
              itemCount: files.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final file = files[index];
                return AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file_rounded),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(file.fileName),
                          ],
                        ),
                      ),
                      AppBadge(label: file.typeLabel),
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
