import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/models/timetable_item.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../providers/timetable_providers.dart';

class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<TimetablePage> {
  String _view = 'today';
  String _weekType = 'all';

  @override
  Widget build(BuildContext context) {
    final isStaff = ref.watch(isStaffUserProvider);
    if (isStaff) {}

    final itemsAsync = ref.watch(timetableItemsProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: itemsAsync.when(
          data: (items) {
            final filtered = _filterByWeekType(
              _filterItems(items, _view),
              _weekType,
            );
            final nextEvent = filtered.firstWhere(
              (item) => item.startsAt.isAfter(DateTime.now()),
              orElse: () => filtered.isEmpty ? _emptyItem : filtered.first,
            );
            final conflicts = _findConflicts(filtered);
            final grouped = _groupItems(filtered);

            return ListView(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الجدول الدراسي',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'عرض مريح لليوم أو الأسبوع مع next event واضح وتنبيه عند وجود تعارضات.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppSegmentedControl<String>(
                        groupValue: _view,
                        onValueChanged: (value) =>
                            setState(() => _view = value),
                        children: const {
                          'today': Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text('اليوم'),
                          ),
                          'tomorrow': Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text('غدًا'),
                          ),
                          'week': Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text('الأسبوع'),
                          ),
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final entry in const {
                            'all': 'All',
                            'odd': 'Odd week',
                            'even': 'Even week',
                          }.entries)
                            ChoiceChip(
                              label: Text(entry.value),
                              selected: _weekType == entry.key,
                              onSelected: (_) =>
                                  setState(() => _weekType = entry.key),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ResponsiveWrapGrid(
                        minItemWidth: 240,
                        spacing: AppSpacing.sm,
                        children: [
                          _HeroInfo(
                            title: 'Upcoming today',
                            body: '${grouped['اليوم']?.length ?? 0} عناصر',
                            color: AppColors.primary,
                          ),
                          _HeroInfo(
                            title: 'Next event',
                            body: nextEvent.id.isEmpty
                                ? 'لا يوجد'
                                : nextEvent.title,
                            color: AppColors.warning,
                          ),
                          _HeroInfo(
                            title: 'Warnings',
                            body: conflicts.isEmpty
                                ? 'لا يوجد تعارض'
                                : '${conflicts.length} تعارض',
                            color: conflicts.isEmpty
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (conflicts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تحذيرات الجدول',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...conflicts.map(
                          (warning) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Text('• $warning'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد عناصر في هذا العرض',
                    subtitle: 'سيظهر الجدول هنا عند وجود مواعيد مرتبطة بموادك.',
                    icon: Icons.calendar_month_outlined,
                  )
                else
                  ...grouped.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _TimetableGroup(
                        title: entry.key,
                        items: entry.value,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جارٍ تحميل الجدول...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({
    required this.title,
    required this.body,
    required this.color,
  });

  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableGroup extends StatelessWidget {
  const _TimetableGroup({required this.title, required this.items});

  final String title;
  final List<TimetableItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _TimetableCard(item: item),
          ),
        ),
      ],
    );
  }
}

class _TimetableCard extends StatelessWidget {
  const _TimetableCard({required this.item});

  final TimetableItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _typeColor(item.typeLabel);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () =>
          context.goNamed(item.routeName, pathParameters: item.pathParameters),
      child: AppCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    formatArabicTime(item.startsAt),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AppBadge(
                        label: item.typeLabel,
                        backgroundColor: accent.withValues(alpha: 0.12),
                        foregroundColor: accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subjectName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${item.locationLabel} • ${item.hostName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _statusLabel(item),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'فتح المادة',
                    onPressed: () => context.goNamed(
                      RouteNames.subjectDetails,
                      pathParameters: {'subjectId': item.subjectId},
                    ),
                    icon: Icons.open_in_new_rounded,
                    isExpanded: false,
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<TimetableItem> _filterItems(List<TimetableItem> items, String view) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final endOfWeek = today.add(const Duration(days: 7));

  if (view == 'today') {
    return items.where((item) {
      final itemDate = DateTime(
        item.startsAt.year,
        item.startsAt.month,
        item.startsAt.day,
      );
      return itemDate == today;
    }).toList();
  }

  if (view == 'tomorrow') {
    final tomorrow = today.add(const Duration(days: 1));
    return items.where((item) {
      final itemDate = DateTime(
        item.startsAt.year,
        item.startsAt.month,
        item.startsAt.day,
      );
      return itemDate == tomorrow;
    }).toList();
  }

  return items.where((item) => item.startsAt.isBefore(endOfWeek)).toList();
}

List<TimetableItem> _filterByWeekType(List<TimetableItem> items, String type) {
  if (type == 'all') {
    return items;
  }
  return items.where((item) {
    final weekNumber =
        ((item.startsAt.difference(DateTime(item.startsAt.year)).inDays) ~/ 7) +
        1;
    final isOdd = weekNumber.isOdd;
    return type == 'odd' ? isOdd : !isOdd;
  }).toList();
}

Map<String, List<TimetableItem>> _groupItems(List<TimetableItem> items) {
  final grouped = <String, List<TimetableItem>>{};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  for (final item in items) {
    final itemDate = DateTime(
      item.startsAt.year,
      item.startsAt.month,
      item.startsAt.day,
    );
    final key = itemDate == today
        ? 'اليوم'
        : itemDate == tomorrow
        ? 'غدًا'
        : formatArabicDate(item.startsAt, pattern: 'EEEE d MMM');
    grouped.putIfAbsent(key, () => []).add(item);
  }

  return grouped;
}

List<String> _findConflicts(List<TimetableItem> items) {
  final warnings = <String>[];
  final sorted = [...items]..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  for (var i = 0; i < sorted.length - 1; i++) {
    final current = sorted[i];
    final next = sorted[i + 1];
    if (current.endsAt.isAfter(next.startsAt)) {
      warnings.add('يوجد تعارض بين ${current.title} و${next.title}.');
    }
  }
  return warnings;
}

String _statusLabel(TimetableItem item) {
  final now = DateTime.now();
  if (item.startsAt.isBefore(now) && item.endsAt.isAfter(now)) {
    return 'يحدث الآن';
  }
  final diff = item.startsAt.difference(now);
  if (diff.inMinutes >= 0 && diff.inMinutes <= 60) {
    return 'بعد قليل';
  }
  if (diff.inDays == 0) {
    return 'اليوم';
  }
  if (diff.inDays == 1) {
    return 'غدًا';
  }
  return 'قادم';
}

Color _typeColor(String type) {
  if (type.contains('محاضرة') || type == 'Lecture') {
    return AppColors.primary;
  }
  if (type.contains('سكشن') || type == 'Section') {
    return AppColors.indigo;
  }
  if (type.contains('كويز') || type == 'Quiz') {
    return AppColors.error;
  }
  return AppColors.warning;
}

final _emptyItem = TimetableItem(
  id: '',
  subjectId: '',
  subjectName: '',
  title: 'لا يوجد حدث قادم',
  typeLabel: '',
  locationLabel: '',
  hostName: '',
  startsAt: DateTime.now(),
  endsAt: DateTime.now(),
  routeName: '',
  pathParameters: const {},
);
