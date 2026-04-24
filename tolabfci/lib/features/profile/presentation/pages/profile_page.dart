import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../staff_portal/presentation/pages/staff_profile_page.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../../../settings/presentation/widgets/settings_notifier.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = ref.watch(isStaffUserProvider);
    if (isStaff) {
      return const StaffProfilePage();
    }

    final profileAsync = ref.watch(profileProvider);
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final settings = ref.watch(settingsNotifierProvider);

    if (profileAsync.isLoading || dashboardAsync.isLoading) {
      return const SafeArea(
        child: AdaptivePageContainer(
          child: LoadingWidget(label: 'جارٍ تحميل الملف الشخصي...'),
        ),
      );
    }

    if (profileAsync.hasError || dashboardAsync.hasError) {
      return SafeArea(
        child: AdaptivePageContainer(
          child: ErrorStateWidget(
            message:
                profileAsync.error?.toString() ??
                dashboardAsync.error.toString(),
          ),
        ),
      );
    }

    final profile = profileAsync.value;
    final dashboard = dashboardAsync.value;
    if (profile == null || dashboard == null) {
      return const SafeArea(
        child: AdaptivePageContainer(
          child: ErrorStateWidget(message: 'تعذر تحميل بيانات الملف الشخصي.'),
        ),
      );
    }

    final adherence = dashboard.tasks.isEmpty
        ? 100
        : ((dashboard.tasks.where((task) => task.isCompleted).length /
                      dashboard.tasks.length) *
                  100)
              .round();

    return SafeArea(
      child: AdaptivePageContainer(
        child: ListView(
          children: [
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    name: profile.fullName,
                    imageUrl: profile.avatarUrl,
                    radius: 36,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.fullName,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          profile.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            AppBadge(label: profile.academicStatus),
                            AppBadge(
                              label: profile.department,
                              backgroundColor: Colors.white,
                            ),
                            AppBadge(
                              label: profile.level,
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => context.goNamed(RouteNames.settings),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ResponsiveWrapGrid(
              minItemWidth: 280,
              children: [
                _ProfileBlock(
                  title: 'ملخص الحساب',
                  children: [
                    _InfoRow(
                      label: 'الرقم الجامعي',
                      value: profile.studentNumber,
                    ),
                    _InfoRow(label: 'القسم', value: profile.department),
                    _InfoRow(label: 'المستوى', value: profile.level),
                    _InfoRow(
                      label: 'الرقم القومي',
                      value: maskNationalId(profile.nationalId),
                    ),
                  ],
                ),
                _ProfileBlock(
                  title: 'البيانات الأكاديمية',
                  children: [
                    _InfoRow(
                      label: 'GPA',
                      value: profile.gpa.toStringAsFixed(2),
                    ),
                    _InfoRow(
                      label: 'عدد المواد',
                      value: '${dashboard.subjects.length}',
                    ),
                    _InfoRow(
                      label: 'الساعات المسجلة',
                      value: '${profile.registeredHours}',
                    ),
                    _InfoRow(label: 'نسبة الالتزام', value: '$adherence%'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اختصارات',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ResponsiveWrapGrid(
                    minItemWidth: 220,
                    spacing: AppSpacing.sm,
                    children: [
                      _ShortcutTile(
                        icon: Icons.bar_chart_rounded,
                        title: 'النتائج والتحليل',
                        subtitle: 'GPA والدرجات والرؤى',
                        onTap: () => context.goNamed(RouteNames.results),
                      ),
                      _ShortcutTile(
                        icon: Icons.assignment_outlined,
                        title: 'التكليفات',
                        subtitle: 'رفع ومتابعة التسليمات',
                        onTap: () => context.goNamed(RouteNames.assignments),
                      ),
                      _ShortcutTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'التنبيهات',
                        subtitle:
                            '${dashboard.notifications.where((n) => !n.isRead).length} غير مقروء',
                        onTap: () => context.goNamed(RouteNames.notifications),
                      ),
                      _ShortcutTile(
                        icon: Icons.quiz_outlined,
                        title: 'الكويزات',
                        subtitle: 'المفتوح والقادم',
                        onTap: () => context.goNamed(RouteNames.quizzes),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإعدادات',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    label: 'اللغة',
                    value: settings.languageCode == 'ar'
                        ? 'العربية'
                        : 'English',
                  ),
                  _InfoRow(
                    label: 'الإشعارات',
                    value: settings.notificationsEnabled ? 'مفعلة' : 'متوقفة',
                  ),
                  _InfoRow(
                    label: 'المظهر',
                    value: _themeModeLabel(settings.themeMode),
                  ),
                  _InfoRow(label: 'الأمان', value: 'جلسة مفعلة وآمنة'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'تلقائي',
      ThemeMode.light => 'فاتح',
      ThemeMode.dark => 'داكن',
    };
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.appColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
