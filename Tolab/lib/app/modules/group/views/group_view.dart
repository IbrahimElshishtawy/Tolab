import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../controllers/group_controller.dart';

class GroupView extends GetView<GroupController> {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        appBar: const PremiumAppBar(title: 'Group'),
        body: Obx(() {
          if (controller.isLoading.value && controller.group.value == null) {
            return const AppLoadingView(lines: 5);
          }
          if (controller.error.value.isNotEmpty &&
              controller.group.value == null) {
            return AppErrorView(
              message: controller.error.value,
              onRetry: controller.load,
            );
          }

          final group = controller.group.value!;
          return Column(
            children: [
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      group.description ?? 'Shared academic discussion space',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const TabBar(
                tabs: [
                  Tab(text: 'Posts'),
                  Tab(text: 'Messages'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView.separated(
                      itemCount: controller.posts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final post = controller.posts[index];
                        return GestureDetector(
                          onTap: () => Get.toNamed(
                            AppRoutes.postDetails,
                            arguments: {
                              'groupId': controller.groupId,
                              'postId': post.id,
                              'content': post.content,
                              'authorName': post.authorName,
                            },
                          ),
                          child: GlassPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.authorName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(post.content),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  DateFormat(
                                    'MMM d, h:mm a',
                                  ).format(post.createdAt),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    ListView.separated(
                      itemCount: controller.messages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        return Align(
                          alignment: message.isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GlassPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.senderName,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(message.content),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
