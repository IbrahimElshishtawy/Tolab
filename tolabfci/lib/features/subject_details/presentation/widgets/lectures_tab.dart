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

class LecturesTab extends ConsumerWidget {
  const LecturesTab({
    super.key,
    required this.subjectId,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturesAsync = ref.watch(lecturesProvider(subjectId));

    return lecturesAsync.when(
      data: (lectures) {
        if (lectures.isEmpty) {
          return const EmptyStateWidget(
            title: 'لا توجد محاضرات',
            subtitle: 'ستظهر محاضرات المادة هنا فور إضافتها.',
          );
        }

        final upcoming = lectures.where((lecture) {
          final startsAt = lecture.startsAt;
          return startsAt != null && startsAt.isAfter(DateTime.now());
        }).toList()..sort((a, b) => a.startsAt!.compareTo(b.startsAt!));
        final previous = lectures.where((lecture) {
          final startsAt = lecture.startsAt;
          return startsAt != null && !startsAt.isAfter(DateTime.now());
        }).toList()..sort((a, b) => b.startsAt!.compareTo(a.startsAt!));

        return ListView(
          shrinkWrap: usePageScroll,
          physics: usePageScroll ? const NeverScrollableScrollPhysics() : null,
          children: [
            if (upcoming.isNotEmpty) ...[
              const _SectionHeader(
                title: 'المحاضرة القادمة',
                subtitle: 'أقرب محاضرات المادة الجاهزة للحضور أو المتابعة.',
              ),
              const SizedBox(height: AppSpacing.md),
              _LectureCard(lecture: upcoming.first, highlight: true),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (upcoming.length > 1) ...[
              const _SectionHeader(
                title: 'المحاضرات القادمة',
                subtitle: 'جدول المحاضرات التالية داخل هذه المادة.',
              ),
              const SizedBox(height: AppSpacing.md),
              ...upcoming
                  .skip(1)
                  .map(
                    (lecture) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _LectureCard(lecture: lecture),
                    ),
                  ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (previous.isNotEmpty) ...[
              const _SectionHeader(
                title: 'محاضرات سابقة أو مسجلة',
                subtitle:
                    'يمكنك مراجعة ما فاتك أو فتح المواد المسجلة إن كانت متاحة.',
              ),
              const SizedBox(height: AppSpacing.md),
              ...previous.map(
                (lecture) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LectureCard(lecture: lecture),
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

class _LectureCard extends StatelessWidget {
  const _LectureCard({required this.lecture, this.highlight = false});

  final LectureItem lecture;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final status = _lectureStatus(lecture);
    final accent = switch (status) {
      _LectureStatus.upcoming => AppColors.primary,
      _LectureStatus.soon => AppColors.warning,
      _LectureStatus.ended => AppColors.success,
      _LectureStatus.live => AppColors.error,
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
                      lecture.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      lecture.scheduleLabel,
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
                label: lecture.isOnline ? 'أونلاين' : 'حضوري',
                foregroundColor: accent,
                dense: true,
              ),
              AppBadge(
                label: lecture.locationLabel ?? 'قاعة المحاضرة',
                dense: true,
              ),
              if (lecture.instructorName != null)
                AppBadge(label: lecture.instructorName!, dense: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: status == _LectureStatus.ended ? 'عرض' : 'دخول',
            onPressed: () {},
            isExpanded: false,
            variant: highlight
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            icon: status == _LectureStatus.ended
                ? Icons.visibility_rounded
                : Icons.play_circle_outline_rounded,
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

_LectureStatus _lectureStatus(LectureItem lecture) {
  final now = DateTime.now();
  final startsAt = lecture.startsAt;
  final endsAt = lecture.endsAt;
  if (startsAt == null || endsAt == null) {
    return _LectureStatus.upcoming;
  }
  if (startsAt.isBefore(now) && endsAt.isAfter(now)) {
    return _LectureStatus.live;
  }
  if (startsAt.isBefore(now)) {
    return _LectureStatus.ended;
  }
  if (startsAt.difference(now).inHours <= 6) {
    return _LectureStatus.soon;
  }
  return _LectureStatus.upcoming;
}

String _statusLabel(_LectureStatus status) {
  return switch (status) {
    _LectureStatus.upcoming => 'متاحة لاحقًا',
    _LectureStatus.soon => 'قريبة',
    _LectureStatus.live => 'مباشرة الآن',
    _LectureStatus.ended => 'انتهت',
  };
}

enum _LectureStatus { upcoming, soon, live, ended }
