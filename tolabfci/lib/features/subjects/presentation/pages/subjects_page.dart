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
                      subject.name.contains(_query) ||
                      subject.code.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      subject.instructor.contains(_query),
                )
                .toList();

            return ListView(
              children: [
                const AppSectionHeader(
                  title: 'المواد الدراسية',
                  subtitle:
                      'بطاقات منظمة توضّح المحتوى، المتابعة، والتقدم داخل كل مادة.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSearchField(
                  controller: _searchController,
                  hintText: 'ابحث باسم المادة أو الكود أو اسم الدكتور',
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد مواد مطابقة',
                    subtitle: 'جرّب كلمة بحث مختلفة.',
                    icon: Icons.search_off_rounded,
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 1000
                          ? 2
                          : constraints.maxWidth >= 680
                          ? 2
                          : 1;
                      final spacing = AppSpacing.lg;
                      final itemWidth = columns == 1
                          ? constraints.maxWidth
                          : (constraints.maxWidth - spacing) / columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final subject in filtered)
                            SizedBox(
                              width: itemWidth,
                              child: SubjectCard(
                                subject: subject,
                                onTap: () => context.goNamed(
                                  RouteNames.subjectDetails,
                                  pathParameters: {'subjectId': subject.id},
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جاري تحميل المواد...'),
          error: (error, stackTrace) => ErrorStateWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(subjectsProvider),
          ),
        ),
      ),
    );
  }
}
