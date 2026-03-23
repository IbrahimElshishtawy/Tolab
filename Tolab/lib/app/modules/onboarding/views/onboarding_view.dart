import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/glass_panel.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _OnboardingPage(
        title: 'Track every academic signal.',
        body:
            'From your daily timetable to urgent notifications, the app keeps your university flow calm and clear.',
      ),
      _OnboardingPage(
        title: 'Move through courses faster.',
        body:
            'Content, files, grades, posts, and schedules stay aligned in a premium navigation shell.',
      ),
      _OnboardingPage(
        title: 'Built for real backend scale.',
        body:
            'Secure auth, token refresh, pagination, uploads, and near real-time ready architecture.',
      ),
    ];

    return AppScaffold(
      safeAreaTop: false,
      body: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 420,
            child: PageView.builder(
              itemCount: pages.length,
              onPageChanged: (index) => controller.pageIndex.value = index,
              itemBuilder: (_, index) => pages[index],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: controller.pageIndex.value == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: controller.pageIndex.value == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.primary(
            label: 'Get started',
            onPressed: controller.complete,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
