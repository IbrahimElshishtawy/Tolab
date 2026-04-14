import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final profileAsync = ref.watch(profileProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: profileAsync.when(
          data: (profile) => ListView(
            children: [
              AppCard(
                backgroundColor: AppColors.surfaceAlt,
                child: Row(
                  children: [
                    AppAvatar(name: profile.fullName, imageUrl: profile.avatarUrl, radius: 34),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.fullName, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
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
              _InfoCard(
                title: 'البيانات الأساسية',
                items: {
                  'الاسم': profile.fullName,
                  'الرقم الجامعي': profile.studentNumber,
                  'القسم': profile.department,
                  'المستوى': profile.level,
                  'البريد الجامعي': profile.email,
                  'المرشد الأكاديمي': profile.academicAdvisor,
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                title: 'ملفي الأكاديمي',
                items: {
                  'GPA': profile.gpa.toStringAsFixed(2),
                  'الحالة الأكاديمية': profile.academicStatus,
                  'عدد الساعات المنجزة': '${profile.completedHours}',
                  'عدد الساعات المسجلة': '${profile.registeredHours}',
                  'رقم الجلوس': profile.seatNumber,
                  'الرقم القومي': maskNationalId(profile.nationalId),
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(title: 'الإعدادات السريعة'),
                    const SizedBox(height: AppSpacing.md),
                    _SettingTile(
                      title: 'إعدادات اللغة',
                      subtitle: settings.languageCode == 'ar' ? 'العربية' : settings.languageCode,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingTile(
                      title: 'إعدادات التنبيهات',
                      subtitle: settings.notificationsEnabled ? 'مفعلة' : 'متوقفة',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _SettingTile(
                      title: 'الأمان',
                      subtitle: 'يمكنك تحديث كلمة المرور من الإعدادات',
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const LoadingWidget(label: 'جاري تحميل الملف الشخصي...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.items,
  });

  final String title;
  final Map<String, String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...items.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
