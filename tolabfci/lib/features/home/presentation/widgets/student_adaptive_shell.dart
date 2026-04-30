import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'student_mobile_nav.dart';
import 'student_shell_brand_card.dart';
import 'student_sidebar.dart';

class StudentShellDestination {
  const StudentShellDestination({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;
}

class StudentAdaptiveShell extends StatelessWidget {
  const StudentAdaptiveShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    required this.isStaff,
    required this.onSelect,
  });

  final StatefulNavigationShell navigationShell;
  final List<StudentShellDestination> destinations;
  final bool isStaff;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    if (MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop) {
      return Scaffold(
        body: Row(
          children: [
            StudentSidebar(
              destinations: destinations,
              currentIndex: navigationShell.currentIndex,
              isStaff: isStaff,
              onSelect: onSelect,
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      endDrawer: isStaff
          ? null
          : StudentMobileDrawer(
              currentIndex: navigationShell.currentIndex,
              onOpenRoute: (routeName) => context.goNamed(routeName),
            ),
      body: navigationShell,
      floatingActionButton: isStaff
          ? null
          : Builder(
              builder: (context) => SafeArea(
                left: false,
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    right: AppSpacing.sm,
                  ),
                  child: FloatingActionButton.small(
                    heroTag: 'student-drawer-toggle',
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    backgroundColor: palette.surfaceElevated,
                    foregroundColor: AppColors.primary,
                    elevation: 8,
                    highlightElevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.grid_view_rounded),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      bottomNavigationBar: StudentMobileNav(
        destinations: destinations,
        currentIndex: navigationShell.currentIndex,
        onSelect: onSelect,
      ),
    );
  }
}

class StudentMobileDrawer extends StatelessWidget {
  const StudentMobileDrawer({
    super.key,
    required this.currentIndex,
    required this.onOpenRoute,
  });

  final int currentIndex;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppColorsScheme>()!;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const StudentShellBrandCard(
              subtitle: 'مساحة الطالب • اختصارات أكاديمية ودعم سريع',
              compact: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            const _DrawerSectionTitle(label: 'المزيد'),
            const SizedBox(height: AppSpacing.sm),
            _DrawerTile(
              icon: Icons.quiz_outlined,
              title: 'الكويزات',
              subtitle: 'المفتوح والقادم',
              onTap: () => _go(context, RouteNames.quizzes),
            ),
            _DrawerTile(
              icon: Icons.assignment_outlined,
              title: 'التكليفات',
              subtitle: 'الرفع والمواعيد النهائية',
              onTap: () => _go(context, RouteNames.assignments),
            ),
            _DrawerTile(
              icon: Icons.bar_chart_rounded,
              title: 'النتائج',
              subtitle: 'الدرجات والتحليل',
              onTap: () => _go(context, RouteNames.results),
            ),
            const Divider(height: AppSpacing.xxl),
            const _DrawerSectionTitle(label: 'الدعم'),
            const SizedBox(height: AppSpacing.sm),
            _DrawerTile(
              icon: Icons.support_agent_rounded,
              title: 'التحدث مع IT',
              subtitle: 'محادثة ودعم مباشر',
              onTap: () => _go(context, RouteNames.itSupport),
            ),
            _DrawerTile(
              icon: Icons.report_problem_outlined,
              title: 'الشكاوى والطلبات',
              subtitle: 'إنشاء تذكرة جديدة',
              onTap: () => _go(context, RouteNames.complaints),
            ),
            _DrawerTile(
              icon: Icons.confirmation_number_outlined,
              title: 'حالة الطلبات',
              subtitle: 'متابعة التذاكر السابقة',
              onTap: () => _go(context, RouteNames.supportTickets),
            ),
            const Divider(height: AppSpacing.xxl),
            const _DrawerSectionTitle(label: 'الإعدادات'),
            const SizedBox(height: AppSpacing.sm),
            _DrawerTile(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              subtitle: 'الثيم واللغة والتنبيهات',
              onTap: () => _go(context, RouteNames.settings),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: palette.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.navigation_rounded,
                    color: currentIndex == 4
                        ? AppColors.primary
                        : AppColors.support,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'العناصر الأساسية ثابتة في الشريط السفلي: الرئيسية، المواد، الجدول، التنبيهات، الملف الشخصي.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String routeName) {
    Navigator.of(context).pop();
    onOpenRoute(routeName);
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: Theme.of(
          context,
        ).extension<AppColorsScheme>()!.surfaceElevated,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _DrawerSectionTitle extends StatelessWidget {
  const _DrawerSectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}
