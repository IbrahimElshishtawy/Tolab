import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../subject_details/presentation/providers/community_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';
import '../widgets/community_post_card.dart';

class CourseCommunityPage extends ConsumerWidget {
  const CourseCommunityPage({
    super.key,
    required this.subjectId,
    this.embedded = false,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool embedded;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityControllerProvider(subjectId));
    final subjectAsync = ref.watch(subjectByIdProvider(subjectId));

    final body = postsAsync.when(
      data: (posts) {
        final pinned = posts.where((post) => post.isPinned).toList();
        final regular = posts.where((post) => !post.isPinned).toList();
        final importantCount = posts.where((post) => post.isImportant).length;

        final content = LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1000;
            final feed = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pinned.isNotEmpty) ...[
                  const _SectionTitle(
                    title: 'إعلانات مثبتة',
                    subtitle: 'أحدث التنبيهات المهمة من الدكتور والمعيد.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...pinned.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CommunityPostCard(
                        post: post,
                        subjectId: subjectId,
                        subjectName: subjectAsync.value?.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const _SectionTitle(
                  title: 'آخر النشاط',
                  subtitle:
                      'أسئلة الطلاب، منشورات الطاقم الأكاديمي، والتعليقات الحديثة.',
                ),
                const SizedBox(height: AppSpacing.md),
                ...regular.map(
                  (post) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: CommunityPostCard(
                      post: post,
                      subjectId: subjectId,
                      subjectName: subjectAsync.value?.name,
                    ),
                  ),
                ),
                if (posts.isEmpty)
                  const AppCard(
                    child: Text(
                      'لا توجد منشورات بعد. ستظهر الإعلانات والأسئلة هنا عند نشرها.',
                    ),
                  ),
              ],
            );

            final sidePanel = Column(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملخص المجتمع',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          AppBadge(label: 'إجمالي المنشورات ${posts.length}'),
                          AppBadge(
                            label: 'المثبت ${pinned.length}',
                            backgroundColor: AppColors.warning.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.warning,
                          ),
                          AppBadge(
                            label: 'المهم $importantCount',
                            backgroundColor: AppColors.support.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: AppColors.support,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طبيعة المجتمع',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _HintLine(
                        text: 'اقرأ الإعلانات المثبتة أولًا قبل طرح سؤال جديد.',
                      ),
                      const _HintLine(
                        text: 'التعليقات والمرفقات تظهر من نفس البطاقة مباشرة.',
                      ),
                      const _HintLine(
                        text: 'المنشورات المهمة والعاجلة عليها badges واضحة.',
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (!isDesktop) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sidePanel,
                  const SizedBox(height: AppSpacing.md),
                  feed,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 300, child: sidePanel),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: feed),
              ],
            );
          },
        );

        final children = <Widget>[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectAsync.value == null
                      ? 'مجتمع المقرر'
                      : 'مجتمع ${subjectAsync.value!.name}',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'نمط feed أكاديمي احترافي للإعلانات والأسئلة والردود والمرفقات.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          content,
        ];

        if (usePageScroll) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        }

        return ListView(children: children);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );

    if (embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('مجتمع المقرر')),
      body: SafeArea(child: AdaptivePageContainer(child: body)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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

class _HintLine extends StatelessWidget {
  const _HintLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle_outline_rounded, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
