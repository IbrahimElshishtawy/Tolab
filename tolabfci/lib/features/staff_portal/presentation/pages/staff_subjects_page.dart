import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/staff_portal_providers.dart';

class StaffSubjectsPage extends ConsumerStatefulWidget {
  const StaffSubjectsPage({super.key});

  @override
  ConsumerState<StaffSubjectsPage> createState() => _StaffSubjectsPageState();
}

class _StaffSubjectsPageState extends ConsumerState<StaffSubjectsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(staffCoursesProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectsAsync.when(
          data: (subjects) {
            final filtered = subjects.where((subject) {
              final q = _query.toLowerCase();
              return subject.name.toLowerCase().contains(q) ||
                  subject.code.toLowerCase().contains(q) ||
                  subject.department.toLowerCase().contains(q);
            }).toList();

            return ListView(
              children: [
                Text(
                  context.tr('مساحات المقررات', 'Course workspaces'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.tr(
                    'كل مادة تتحول إلى مساحة تشغيل أكاديمية للدكتور أو المعيد',
                    'Every course becomes an academic operating workspace for staff',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSearchField(
                  controller: _searchController,
                  hintText: context.tr(
                    'ابحث باسم المادة أو الكود أو القسم',
                    'Search by course name, code, or department',
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...filtered.map(
                  (subject) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => context.goNamed(
                        RouteNames.subjectDetails,
                        pathParameters: {'subjectId': subject.id},
                      ),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${subject.code} • ${subject.department}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      int.parse(
                                        'FF${subject.accentHex.replaceAll('#', '')}',
                                        radix: 16,
                                      ),
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(subject.roleLabel),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _Metric(
                                  text: context.tr(
                                    'طلاب: ${subject.studentCount}',
                                    'Students: ${subject.studentCount}',
                                  ),
                                ),
                                _Metric(
                                  text: context.tr(
                                    'نشطون: ${subject.activeStudents}',
                                    'Active: ${subject.activeStudents}',
                                  ),
                                ),
                                _Metric(
                                  text: context.tr(
                                    'كويزات: ${subject.quizCount}',
                                    'Quizzes: ${subject.quizCount}',
                                  ),
                                ),
                                _Metric(
                                  text: context.tr(
                                    'إعلانات: ${subject.announcementCount}',
                                    'Announcements: ${subject.announcementCount}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(subject.latestUpdate),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () =>
              const LoadingWidget(label: 'Loading course workspaces...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text),
    );
  }
}
