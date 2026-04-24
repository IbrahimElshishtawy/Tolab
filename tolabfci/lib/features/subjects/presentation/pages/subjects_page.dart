import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/presentation/pages/staff_subjects_page.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
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
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStaff = ref.watch(isStaffUserProvider);
    if (isStaff) {
      return const StaffSubjectsPage();
    }

    final subjectsAsync = ref.watch(subjectsProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: subjectsAsync.when(
          data: (subjects) {
            final filtered = subjects
                .where(_matchesQuery)
                .where(_matchesFilter)
                .toList();

            return ListView(
              children: [
                _SubjectsHero(subjects: subjects),
                const SizedBox(height: AppSpacing.lg),
                AppSearchField(
                  controller: _searchController,
                  hintText: 'ابحث باسم المادة، الكود، الدكتور أو المعيد',
                  onChanged: (value) => setState(() => _query = value.trim()),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _FilterChip(
                      label: 'الكل',
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    _FilterChip(
                      label: 'نشطة',
                      selected: _filter == 'active',
                      onTap: () => setState(() => _filter = 'active'),
                    ),
                    _FilterChip(
                      label: 'جديد',
                      selected: _filter == 'new',
                      onTap: () => setState(() => _filter = 'new'),
                    ),
                    _FilterChip(
                      label: 'يحتاج متابعة',
                      selected: _filter == 'watch',
                      onTap: () => setState(() => _filter = 'watch'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد مواد مطابقة',
                    subtitle:
                        'جرّب تغيير البحث أو فلتر الحالة للوصول إلى المادة المطلوبة.',
                    icon: Icons.search_off_rounded,
                  )
                else
                  ResponsiveWrapGrid(
                    minItemWidth: 340,
                    children: [
                      for (final subject in filtered)
                        SubjectCard(
                          subject: subject,
                          onTap: () => context.goNamed(
                            RouteNames.subjectDetails,
                            pathParameters: {'subjectId': subject.id},
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جارٍ تحميل المواد...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }

  bool _matchesFilter(SubjectOverview subject) {
    switch (_filter) {
      case 'active':
        return subject.status == 'نشطة';
      case 'new':
        return subject.status == 'جديد';
      case 'watch':
        return subject.status == 'مطلوب تسليم' ||
            subject.progress < 0.55;
      default:
        return true;
    }
  }

  bool _matchesQuery(SubjectOverview subject) {
    if (_query.isEmpty) {
      return true;
    }

    return subject.name.contains(_query) ||
        subject.code.toLowerCase().contains(_query.toLowerCase()) ||
        subject.instructor.contains(_query) ||
        subject.assistantName.contains(_query);
  }
}

class _SubjectsHero extends StatelessWidget {
  const _SubjectsHero({required this.subjects});

  final List<SubjectOverview> subjects;

  @override
  Widget build(BuildContext context) {
    final active = subjects
        .where((subject) => subject.status == 'نشطة')
        .length;
    final watchList = subjects
        .where(
          (subject) =>
              subject.status == 'مطلوب تسليم' ||
              subject.progress < 0.55,
        )
        .length;
    final avgProgress = subjects.isEmpty
        ? 0.0
        : subjects.map((subject) => subject.progress).reduce((a, b) => a + b) /
              subjects.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المواد الدراسية',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Workspace منظّم لكل مادة: المحتوى، المحاضرات، الكويزات، الجروب والدرجات مع مؤشرات متابعة واضحة.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _HeroMetric(label: 'إجمالي المواد', value: '${subjects.length}'),
              _HeroMetric(
                label: 'نشطة',
                value: '$active',
                accent: AppColors.success,
              ),
              _HeroMetric(
                label: 'تحتاج متابعة',
                value: '$watchList',
                accent: AppColors.error,
              ),
              _HeroMetric(
                label: 'متوسط التقدم',
                value: '${(avgProgress * 100).round()}%',
                accent: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    this.accent = AppColors.primary,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
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
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
