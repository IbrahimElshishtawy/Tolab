import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class SectionsTab extends ConsumerWidget {
  const SectionsTab({
    super.key,
    required this.subjectId,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(sectionsProvider(subjectId));

    return sectionsAsync.when(
      data: (sections) {
        if (sections.isEmpty) {
          return const EmptyStateWidget(
            title: 'لا توجد سكاشن',
            subtitle: 'ستظهر السكاشن العملية هنا عند توفرها.',
          );
        }

        final upcoming = sections.where((section) {
          final startsAt = section.startsAt;
          return startsAt != null && startsAt.isAfter(DateTime.now());
        }).toList()..sort((a, b) => a.startsAt!.compareTo(b.startsAt!));
        final previous = sections.where((section) {
          final startsAt = section.startsAt;
          return startsAt != null && !startsAt.isAfter(DateTime.now());
        }).toList()..sort((a, b) => b.startsAt!.compareTo(a.startsAt!));

        return ListView(
          shrinkWrap: usePageScroll,
          physics: usePageScroll ? const NeverScrollableScrollPhysics() : null,
          children: [
            if (upcoming.isNotEmpty) ...[
              const _SectionHeader(
                title: 'السكاشن القادمة',
                subtitle:
                    'كل سكشن موضح هل هو أونلاين أو حضوري مع مكانه أو رابط الاجتماع.',
              ),
              const SizedBox(height: AppSpacing.sm),
              ...upcoming.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SectionCard(
                    section: section,
                    highlight: section == upcoming.first,
                  ),
                ),
              ),
            ],
            if (previous.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const _SectionHeader(
                title: 'سكاشن سابقة',
                subtitle: 'مرجع سريع للحضور، المعمل، وحالة كل سكشن.',
              ),
              const SizedBox(height: AppSpacing.sm),
              ...previous.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SectionCard(section: section),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => Text(error.toString()),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, this.highlight = false});

  final SectionItem section;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final status = _sectionStatus(section);
    final accent = switch (status) {
      _SectionStatus.upcoming => AppColors.indigo,
      _SectionStatus.soon => AppColors.warning,
      _SectionStatus.live => AppColors.error,
      _SectionStatus.ended => AppColors.success,
    };
    final typeColor = section.isOnline ? AppColors.primary : AppColors.success;
    final locationLabel = section.isOnline
        ? (section.meetingUrl.isNotEmpty
              ? section.meetingUrl
              : section.location)
        : section.location;

    return AppCard(
      backgroundColor: context.appColors.surfaceElevated,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    section.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AppBadge(
                    label: section.isOnline
                        ? 'أونلاين / Online'
                        : 'حضوري / Offline',
                    backgroundColor: typeColor.withValues(alpha: 0.12),
                    foregroundColor: typeColor,
                    dense: true,
                  ),
                  AppBadge(
                    label: _statusLabel(status),
                    backgroundColor: accent.withValues(alpha: 0.12),
                    foregroundColor: accent,
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                section.subjectName ?? 'المادة',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  AppBadge(label: section.scheduleLabel, dense: true),
                  AppBadge(label: section.assistantName, dense: true),
                  AppBadge(
                    label: locationLabel,
                    dense: true,
                    foregroundColor: section.isOnline
                        ? AppColors.primary
                        : context.appColors.textPrimary,
                  ),
                ],
              ),
            ],
          );

          final action = AppButton(
            label: section.isOnline ? 'دخول الاجتماع' : 'عرض التفاصيل',
            onPressed: () {},
            isExpanded: compact,
            variant: highlight
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            icon: section.isOnline
                ? Icons.video_call_outlined
                : Icons.meeting_room_outlined,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: AppSpacing.sm),
                action,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: details),
              const SizedBox(width: AppSpacing.sm),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

_SectionStatus _sectionStatus(SectionItem section) {
  final now = DateTime.now();
  final startsAt = section.startsAt;
  final endsAt = section.endsAt;
  if (startsAt == null || endsAt == null) {
    return _SectionStatus.upcoming;
  }
  if (startsAt.isBefore(now) && endsAt.isAfter(now)) {
    return _SectionStatus.live;
  }
  if (startsAt.isBefore(now)) {
    return _SectionStatus.ended;
  }
  if (startsAt.difference(now).inHours <= 6) {
    return _SectionStatus.soon;
  }
  return _SectionStatus.upcoming;
}

String _statusLabel(_SectionStatus status) {
  return switch (status) {
    _SectionStatus.upcoming => 'قريب',
    _SectionStatus.soon => 'قريب جدًا',
    _SectionStatus.live => 'الآن',
    _SectionStatus.ended => 'انتهى',
  };
}

enum _SectionStatus { upcoming, soon, live, ended }
