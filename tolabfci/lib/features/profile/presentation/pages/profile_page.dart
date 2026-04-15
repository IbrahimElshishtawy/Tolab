import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../staff_portal/presentation/pages/staff_profile_page.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
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
    final settings = ref.watch(settingsNotifierProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: profileAsync.when(
          data: (profile) => ListView(
            children: [
              AppCard(
                backgroundColor: context.appColors.surfaceElevated,
                child: Row(
                  children: [
                    AppAvatar(
                      name: profile.fullName,
                      imageUrl: profile.avatarUrl,
                      radius: 34,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            profile.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppBadge(label: profile.academicStatus),
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
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(title: 'اختصارات الحساب'),
                    const SizedBox(height: AppSpacing.md),
                    _ActionTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'النتائج والتحليل',
                      subtitle: 'GPA ودرجات المواد والرؤية الأكاديمية',
                      onTap: () => context.goNamed(RouteNames.results),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: Icons.language_rounded,
                      title: 'اللغة',
                      subtitle: settings.languageCode == 'ar'
                          ? 'العربية'
                          : 'English',
                      onTap: () => context.goNamed(RouteNames.settings),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'التنبيهات',
                      subtitle: settings.notificationsEnabled
                          ? 'مفعلة'
                          : 'متوقفة',
                      onTap: () => context.goNamed(RouteNames.settings),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ActionTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'المظهر',
                      subtitle: _themeModeLabel(settings.themeMode),
                      onTap: () => context.goNamed(RouteNames.settings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                title: 'البيانات الشخصية',
                items: {
                  'الاسم': profile.fullName,
                  'الرقم الجامعي': profile.studentNumber,
                  'البريد الجامعي': profile.email,
                  'الرقم القومي': maskNationalId(profile.nationalId),
                  'المؤهل السابق': profile.previousQualification,
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                title: 'البيانات الأكاديمية',
                items: {
                  'الكلية': profile.faculty,
                  'القسم': profile.department,
                  'المستوى': profile.level,
                  'GPA': profile.gpa.toStringAsFixed(2),
                  'المرشد الأكاديمي': profile.academicAdvisor,
                  'الساعات المنجزة': '${profile.completedHours}',
                  'الساعات المسجلة': '${profile.registeredHours}',
                  'رقم الجلوس': profile.seatNumber,
                },
              ),
            ],
          ),
          loading: () =>
              const LoadingWidget(label: 'جاري تحميل الملف الشخصي...'),
          error: (error, stackTrace) =>
              ErrorStateWidget(message: error.toString()),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.items});

  final String title;
  final Map<String, String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...items.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Expanded(
                      child: Text(entry.value, textAlign: TextAlign.end),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
    final palette = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primary),
            ),
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
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
