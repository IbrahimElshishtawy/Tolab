import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/presentation/pages/staff_schedule_page.dart';
import '../../../../core/models/timetable_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/timetable_providers.dart';

class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends ConsumerState<TimetablePage> {
  String _view = 'today';

  @override
  Widget build(BuildContext context) {
    final isStaff = ref.watch(isStaffUserProvider);
    if (isStaff) {
      return const StaffSchedulePage();
    }

    final itemsAsync = ref.watch(timetableItemsProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: itemsAsync.when(
          data: (items) {
            final filtered = _filterItems(items);
            final grouped = _groupItems(filtered);

            return ListView(
              children: [
                const AppSectionHeader(
                  title: 'الجدول الدراسي',
                  subtitle:
                      'عرض اليوم أو الأسبوع مع فتح الوجهة المرتبطة مباشرة.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSegmentedControl<String>(
                  groupValue: _view,
                  onValueChanged: (value) => setState(() => _view = value),
                  children: const {
                    'today': Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text('اليوم'),
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
          loading: () => const LoadingWidget(label: 'جاري تحميل الجدول...'),
          error: (error, stackTrace) =>
              ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }

  List<TimetableItem> _filterItems(List<TimetableItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(const Duration(days: 7));

    if (_view == 'today') {
      return items.where((item) {
        final date = DateTime(
          item.startsAt.year,
          item.startsAt.month,
          item.startsAt.day,
        );
        return date == today;
      }).toList();
    }

    return items.where((item) => item.startsAt.isBefore(endOfWeek)).toList();
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
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => _TimetableTile(item: item)),
      ],
    );
  }
}

class _TimetableTile extends StatelessWidget {
  const _TimetableTile({required this.item});

  final TimetableItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () =>
          context.goNamed(item.routeName, pathParameters: item.pathParameters),
      child: AppCard(
        backgroundColor: palette.surfaceElevated,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                formatArabicTime(item.startsAt),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AppBadge(
                        label: item.typeLabel,
                        backgroundColor: palette.surfaceAlt,
                        foregroundColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subjectName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${item.locationLabel} • ${item.hostName}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _statusBadge(item),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.indigo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusBadge(TimetableItem item) {
    final now = DateTime.now();
    if (item.startsAt.isBefore(now) && item.endsAt.isAfter(now)) {
      return 'الآن';
    }
    final difference = item.startsAt.difference(now);
    if (difference.inMinutes <= 60 && difference.inMinutes >= 0) {
      return 'بعد قليل';
    }
    if (difference.inDays == 0) {
      return 'اليوم';
    }
    if (difference.inDays == 1) {
      return 'غدًا';
    }
    return item.typeLabel;
  }
}
