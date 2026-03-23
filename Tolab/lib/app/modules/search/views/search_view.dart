import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routes/app_routes.dart';
import '../controllers/search_controller.dart' as search_controller;

class SearchView extends GetView<search_controller.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const PremiumAppBar(title: 'Search'),
      body: Column(
        children: [
          TextField(
            onChanged: controller.onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Search courses',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoadingView(lines: 5);
              }
              if (controller.results.isEmpty) {
                return const AppEmptyView(
                  title: 'Search for something',
                  subtitle: 'Try a course title, code, or keyword.',
                );
              }

              return ListView.separated(
                itemCount: controller.results.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final course = controller.results[index];
                  return GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.courseDetails,
                      arguments: {'id': course.id},
                    ),
                    child: GlassPanel(
                      child: Row(
                        children: [
                          const Icon(Icons.menu_book_rounded),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(course.code),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
