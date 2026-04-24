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
                title: 'السكشن القادم',
                subtitle: 'أقرب سكشن عملي يمكنك الاستعداد له أو الدخول إليه.',
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(section: upcoming.first, highlight: true),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (upcoming.length > 1) ...[
              const _SectionHeader(
                title: 'السكاشن القادمة',
                subtitle: 'باقي مواعيد السكاشن داخل هذه المادة.',
              ),
              const SizedBox(height: AppSpacing.md),
              ...upcoming
                  .skip(1)
                  .map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _SectionCard(section: section),
                    ),
                  ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (previous.isNotEmpty) ...[
              const _SectionHeader(
                title: 'سكاشن سابقة',
                subtitle: 'مرجع سريع للسكاشن السابقة وحالة كل سكشن.',
              ),
              const SizedBox(height: AppSpacing.md),
              ...previous.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
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

    return AppCard(
      backgroundColor: context.appColors.surfaceElevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      section.scheduleLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: _statusLabel(status),
                backgroundColor: accent.withValues(alpha: 0.12),
                foregroundColor: accent,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(
                label: section.isOnline ? 'أونلاين' : 'حضوري',
                foregroundColor: accent,
                dense: true,
              ),
              AppBadge(label: section.location, dense: true),
              AppBadge(label: section.assistantName, dense: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: status == _SectionStatus.ended ? 'عرض' : 'دخول',
            onPressed: () {},
            isExpanded: false,
            variant: highlight
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            icon: status == _SectionStatus.ended
                ? Icons.visibility_rounded
                : Icons.meeting_room_outlined,
          ),
        ],
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
    _SectionStatus.upcoming => 'متاح لاحقًا',
    _SectionStatus.soon => 'قريب',
    _SectionStatus.live => 'مباشر الآن',
    _SectionStatus.ended => 'انتهى',
  };
}

enum _SectionStatus { upcoming, soon, live, ended }
