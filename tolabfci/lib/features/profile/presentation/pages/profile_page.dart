import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/models/support_models.dart';
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
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../settings/presentation/widgets/settings_notifier.dart';
import '../../../staff_portal/presentation/pages/staff_profile_page.dart';
import '../../../support/presentation/providers/support_providers.dart';
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
    final ticketsAsync = ref.watch(supportTicketsProvider);
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
    final pendingTickets =
        ticketsAsync.value
            ?.where((ticket) => ticket.status != SupportTicketStatus.resolved)
            .length ??
        0;

    return SafeArea(
      child: AdaptivePageContainer(
        child: ListView(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                AppBadge(label: profile.department),
                                AppBadge(label: profile.level),
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
                  const SizedBox(height: AppSpacing.lg),
                  ResponsiveWrapGrid(
                    minItemWidth: 180,
                    spacing: AppSpacing.sm,
                    children: [
                      _StatCard(
                        label: 'GPA',
                        value: profile.gpa.toStringAsFixed(2),
                      ),
                      _StatCard(
                        label: 'الساعات المسجلة',
                        value: '${profile.registeredHours}',
                      ),
                      _StatCard(
                        label: 'المواد الحالية',
                        value: '${dashboard.subjects.length}',
                      ),
                      _StatCard(
                        label: 'التزامك',
                        value: '$adherence%',
                        accent: adherence >= 80
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ResponsiveWrapGrid(
              minItemWidth: 320,
              spacing: AppSpacing.md,
              children: [
                _InfoBlock(
                  title: 'البيانات الأساسية',
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
                    _InfoRow(label: 'رقم الجلوس', value: profile.seatNumber),
                  ],
                ),
                _InfoBlock(
                  title: 'ملخص أكاديمي',
                  children: [
                    _InfoRow(
                      label: 'المرشد الأكاديمي',
                      value: profile.academicAdvisor,
                    ),
                    _InfoRow(
                      label: 'الموقف الأكاديمي',
                      value: academicStandingLabel(profile.gpa),
                    ),
                    _InfoRow(
                      label: 'عدد المواد',
                      value: '${dashboard.subjects.length}',
                    ),
                    _InfoRow(
                      label: 'التنبيهات غير المقروءة',
                      value:
                          '${dashboard.notifications.where((item) => !item.isRead).length}',
                    ),
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
                    'اختصارات سريعة',
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
                        subtitle: 'الرفع ومتابعة التسليمات',
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
                    'الدعم الفني',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'كل ما يخص التواصل مع IT، إنشاء الطلبات، ومتابعة الحالات السابقة.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppBadge(
                        label: 'الطلبات المفتوحة: $pendingTickets',
                        backgroundColor: AppColors.support.withValues(
                          alpha: 0.12,
                        ),
                        foregroundColor: AppColors.support,
                      ),
                      AppBadge(
                        label: settings.notificationsEnabled
                            ? 'إشعارات الدعم مفعلة'
                            : 'إشعارات الدعم متوقفة',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ResponsiveWrapGrid(
                    minItemWidth: 220,
                    spacing: AppSpacing.sm,
                    children: [
                      _ShortcutTile(
                        icon: Icons.support_agent_rounded,
                        title: 'التحدث مع IT',
                        subtitle: 'رسالة مباشرة مع ربط بياناتك تلقائيًا',
                        onTap: () => context.goNamed(RouteNames.itSupport),
                      ),
                      _ShortcutTile(
                        icon: Icons.report_problem_outlined,
                        title: 'الشكاوى والطلبات',
                        subtitle: 'إنشاء تذكرة جديدة',
                        onTap: () => context.goNamed(RouteNames.complaints),
                      ),
                      _ShortcutTile(
                        icon: Icons.confirmation_number_outlined,
                        title: 'حالة الطلبات',
                        subtitle: 'عرض السجل والتحديثات',
                        onTap: () => context.goNamed(RouteNames.supportTickets),
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
                    'الإعدادات الحالية',
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.accent = AppColors.primary,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.children});

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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
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
