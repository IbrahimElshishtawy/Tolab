import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../domain/models/staff_portal_models.dart';

class CourseStudentsPage extends StatefulWidget {
  const CourseStudentsPage({super.key, required this.students});

  final List<CourseStudentInsight> students;

  @override
  State<CourseStudentsPage> createState() => _CourseStudentsPageState();
}

class _CourseStudentsPageState extends State<CourseStudentsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'all';
  bool _sortByScore = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.students.where((student) {
          final matchesQuery =
              student.name.toLowerCase().contains(_query.toLowerCase()) ||
              student.code.contains(_query) ||
              student.email.toLowerCase().contains(_query.toLowerCase());

          final matchesFilter = switch (_filter) {
            'high' => student.engagementLevel == EngagementLevel.high,
            'medium' => student.engagementLevel == EngagementLevel.medium,
            'low' => student.engagementLevel == EngagementLevel.low,
            _ => true,
          };

          return matchesQuery && matchesFilter;
        }).toList()..sort(
          (a, b) => _sortByScore
              ? b.averageScore.compareTo(a.averageScore)
              : a.name.compareTo(b.name),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          controller: _searchController,
          hintText: context.tr(
            'ابحث بالاسم أو الكود أو البريد',
            'Search by name, code, or email',
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _FilterChip(
              label: context.tr('الكل', 'All'),
              selected: _filter == 'all',
              onTap: () => setState(() => _filter = 'all'),
            ),
            _FilterChip(
              label: context.tr('مرتفع', 'High'),
              selected: _filter == 'high',
              onTap: () => setState(() => _filter = 'high'),
            ),
            _FilterChip(
              label: context.tr('متوسط', 'Medium'),
              selected: _filter == 'medium',
              onTap: () => setState(() => _filter = 'medium'),
            ),
            _FilterChip(
              label: context.tr('ضعيف', 'Low'),
              selected: _filter == 'low',
              onTap: () => setState(() => _filter = 'low'),
            ),
            _FilterChip(
              label: _sortByScore
                  ? context.tr('ترتيب حسب الدرجة', 'Sort by score')
                  : context.tr('ترتيب أبجدي', 'Sort alphabetically'),
              selected: true,
              onTap: () => setState(() => _sortByScore = !_sortByScore),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...filtered.map(
          (student) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${student.code} • ${student.email}',
                              style: Theme.of(context).textTheme.bodySmall,
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
                          color: _engagementColor(
                            student.engagementLevel,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _engagementLabel(context, student.engagementLevel),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: _engagementColor(
                                  student.engagementLevel,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(student.activitySummary),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _MetricBadge(
                        label: context.tr('Quiz completion', 'Quiz completion'),
                        value: '${student.quizCompletion.round()}%',
                      ),
                      _MetricBadge(
                        label: context.tr('Submissions', 'Submissions'),
                        value: '${student.submissionsCount}',
                      ),
                      _MetricBadge(
                        label: context.tr('Average', 'Average'),
                        value: '${student.averageScore.round()}%',
                      ),
                      _MetricBadge(
                        label: context.tr('Last active', 'Last active'),
                        value: student.lastActiveLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _engagementLabel(BuildContext context, EngagementLevel level) {
    return switch (level) {
      EngagementLevel.high => context.tr('مرتفع', 'High'),
      EngagementLevel.medium => context.tr('متوسط', 'Medium'),
      EngagementLevel.low => context.tr('ضعيف', 'Low'),
    };
  }

  Color _engagementColor(EngagementLevel level) {
    return switch (level) {
      EngagementLevel.high => AppColors.success,
      EngagementLevel.medium => AppColors.warning,
      EngagementLevel.low => AppColors.error,
    };
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

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value});

  final String label;
  final String value;

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
      child: Text('$label: $value'),
    );
  }
}
