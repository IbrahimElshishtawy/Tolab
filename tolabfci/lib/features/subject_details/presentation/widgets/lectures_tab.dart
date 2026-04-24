import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/readable_text.dart';
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
                title: 'المحاضرات القادمة',
                subtitle:
                    'موعد المحاضرة، الدكتور، نوع الحضور، ورابط الدخول في بطاقة واحدة.',
              ),
              const SizedBox(height: AppSpacing.sm),
              ...upcoming.map(
                (lecture) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LectureCard(
                    lecture: lecture,
                    highlight: lecture == upcoming.first,
                  ),
                ),
              ),
            ],
            if (previous.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const _SectionHeader(
                title: 'محاضرات سابقة أو مسجلة',
                subtitle:
                    'النصوص المكسورة يتم استبدالها بعنوان مفهوم بدل عرض رموز غير مقروءة.',
              ),
              const SizedBox(height: AppSpacing.sm),
              ...previous.map(
                (lecture) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
    final typeColor = lecture.isOnline ? AppColors.primary : AppColors.success;
    final title = readableText(lecture.title, 'محاضرة المادة');
    final teacher = readableText(lecture.instructorName, 'دكتور المادة');
    final location = readableText(
      lecture.locationLabel,
      lecture.isOnline ? 'Tolab Meet' : 'قاعة المحاضرة',
    );
    final hasLink = lecture.meetingUrl.trim().isNotEmpty;

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
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
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
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  AppBadge(label: lecture.scheduleLabel, dense: true),
                  AppBadge(label: teacher, dense: true),
                  AppBadge(
                    label: lecture.isOnline
                        ? 'أونلاين / Online'
                        : 'حضوري / Offline',
                    backgroundColor: typeColor.withValues(alpha: 0.12),
                    foregroundColor: typeColor,
                    dense: true,
                  ),
                  AppBadge(label: location, dense: true),
                  if (hasLink)
                    AppBadge(
                      label: status == _LectureStatus.ended
                          ? 'تسجيل متاح'
                          : 'رابط متاح',
                      backgroundColor: AppColors.success.withValues(
                        alpha: 0.12,
                      ),
                      foregroundColor: AppColors.success,
                      dense: true,
                    ),
                ],
              ),
            ],
          );

          final action = AppButton(
            label: status == _LectureStatus.ended ? 'عرض' : 'دخول',
            onPressed: () {},
            isExpanded: compact,
            variant: highlight
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            icon: status == _LectureStatus.ended
                ? Icons.visibility_rounded
                : Icons.play_circle_outline_rounded,
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
    _LectureStatus.upcoming => 'قريب',
    _LectureStatus.soon => 'قريب جدًا',
    _LectureStatus.live => 'الآن',
    _LectureStatus.ended => 'انتهت',
  };
}

enum _LectureStatus { upcoming, soon, live, ended }
