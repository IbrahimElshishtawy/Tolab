import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/subjects_providers.dart';
import '../widgets/subject_card.dart';

class SubjectsPage extends ConsumerStatefulWidget {
  const SubjectsPage({super.key});

  @override
  ConsumerState<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends ConsumerState<SubjectsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectsAsync.when(
          data: (subjects) {
            final filtered = subjects
                .where(
                  (subject) =>
                      subject.name.toLowerCase().contains(_query.toLowerCase()) ||
                      subject.code.toLowerCase().contains(_query.toLowerCase()),
                )
                .toList();

            return ListView(
              children: [
                const AppSectionHeader(
                  title: 'Subjects',
                  subtitle: 'Browse all enrolled courses and open each subject workspace.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'No subjects found',
                    subtitle: 'Try a different search keyword.',
                    icon: Icons.search_off_rounded,
                  )
                else
                  ...filtered.map(
                    (subject) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: SubjectCard(
                        subject: subject,
                        onTap: () => context.goNamed(
                          RouteNames.subjectDetails,
                          pathParameters: {'subjectId': subject.id},
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'Loading subjects...'),
          error: (error, stackTrace) => ErrorStateWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(subjectsProvider),
          ),
        ),
      ),
    );
  }
}
